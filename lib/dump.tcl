##############################################################################
#
# dump.tcl - procedures to export widget information
#
# Copyright (C) 1996-1998 Stewart Allen
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

##############################################################################
#

proc vTcl:save_vars {} {
    global vTcl
    set output ""
    set list $vTcl(vars)
    vTcl:list add widget list
    foreach i $list {
        catch {
            if {[vTcl:valid_varname $i]} {
                global $i
                append output "global $i; "
                if {[array exists $i] == 1} {
                    append output "\n"
                    set names [lsort [array names $i]]
                    foreach j $names {
                        set value "[subst $$i\($j\)]"
                        if {$vTcl(pr,saveglob) == 1} {
                            append output "$vTcl(tab)set $i\($j\) \{$value\}\n"
                        }
                    }
                } else {
                    if {$vTcl(pr,saveglob) == 1} {
                        append output "set $i \{[subst $\{$i\}]\}"
                    }
                    append output "\n"
                }
            }
        }
    }
    return "$output"
}

proc vTcl:save_procs {} {
    global vTcl
    set output ""
    set list $vTcl(procs)
    foreach i $list {
        if {[vTcl:ignore_procname_when_saving $i] == 0} {
            set args ""
            foreach j [info args $i] {
                if {[info default $i $j value]} {
                    lappend args [list $j $value]
                } else {
                    lappend args $j
                }
            }
            set body [string trim [info body $i]]
            if {($body != "" || $i == "main") && $i != "init"} {

                if {[regexp (.*):: $i matchAll context] } {
                   append output "\nnamespace eval ${context} \{\n"
                }

                append output "\nproc \{$i\} \{$args\} \{\n$body\n\}\n"

                if {[regexp (.*):: $i]} {
                   append output "\n\}\n"
                }
            }
        }
    }
    return $output
}

proc vTcl:export_procs {} {
    global vTcl classes

    set output ""
    vTcl:dump:not_sourcing_header output
    set children [vTcl:list_widget_tree .]

    foreach child $children {
        lappend classList [vTcl:get_class $child]
    }

    foreach class [vTcl:lrmdups $classList] {
        if {[info exists classes($class,exportCmds)]} {
            eval lappend list $classes($class,exportCmds)
        }
        if {[info exists classes($class,widgetProc)]} {
            eval lappend list $classes($class,widgetProc)
        }
    }

    foreach i [vTcl:lrmdups $list] {

        set args ""
        foreach j [info args $i] {
            if {[info default $i $j value]} {
                lappend args [list $j $value]
            } else {
                lappend args $j
            }
        }
        set body [string trim [info body $i] "\n"]
	if {(![lempty $body] || [vTcl:streq $i "main"]) \
	    && ![vTcl:streq $i "init"]} {

            if {[regexp (.*):: $i matchAll context] } {
               append output "\nnamespace eval ${context} \{\n"
            }

            append output "\nproc \{$i\} \{$args\} \{\n$body\n\}\n"

            if {[regexp (.*):: $i]} {
               append output "\n\}\n"
            }
        }
    }
    vTcl:dump:sourcing_footer output
    return $output
}

proc vTcl:vtcl_library_procs {} {
    global vTcl classes tcl_platform

    set list {
        Window
    }

    if {[vTcl:streq $tcl_platform(platform) "windows"]} {
	lappend list vTcl:WindowsCleanup
    }
	
    vTcl:dump:not_sourcing_header output
    foreach proc $list {
        append output [vTcl:maybe_dump_proc $proc]
    }
    vTcl:dump:sourcing_footer output
    return $output
}

proc vTcl:dump:get_multifile_project_dir {project_name} {

    return [file rootname $project_name]_
}

proc vTcl:dump:get_top_filename {target basedir project_name} {

    return [file join $basedir \
                      [vTcl:dump:get_multifile_project_dir $project_name] \
                      f$target.tcl]
}

proc vTcl:dump:get_files_list {basedir project_name} {

    global vTcl

    if {![info exists vTcl(pr,projecttype)]} { return }
    if {$vTcl(pr,projecttype) == "single"}   { return }

    set result ""
    set tops ". $vTcl(tops)"

    foreach i $tops {
        lappend result [vTcl:dump:get_top_filename $i $basedir $project_name]
    }

    return $result
}

proc vTcl:dump_top_tofile {target basedir project_name} {

    global vTcl

    catch {
        file mkdir [file join $basedir [vTcl:dump:get_multifile_project_dir $project_name] ]
    }

    set filename [vTcl:dump:get_top_filename $target $basedir $project_name]
    set id [open $filename w]
    puts $id "[subst $vTcl(head,projfile)]\n\n"
    puts $id [vTcl:dump_top $target]
    close $id

    set output ""

    append output "if \[info exists _freewrap_progsrc\] \{\n"
    append output \
       "    source \"[vTcl:dump:get_top_filename $target $basedir $project_name]\"\n"
    append output "\} else \{\n"
    append output \
       "    source \"\[file join \[file dirname \[info script\] \] [vTcl:dump:get_multifile_project_dir $project_name] f$target.tcl\]\"\n"
    append output "\}\n"

    return $output
}

proc vTcl:save_tree {target {basedir ""} {project_name ""}} {
    global vTcl

    if {! [info exists vTcl(pr,projecttype)]} {
        set vTcl(pr,projecttype) single
    }

    set output ""
    set vTcl(dumptops) ""
    set vTcl(showtops) ""
    set vTcl(var_update) "no"
    set vTcl(num,index) 0
    set tops ". $vTcl(tops)"

    vTcl:status "Saving: collecting data"
    set vTcl(num,total) [llength [vTcl:list_widget_tree $target]]

    foreach i $tops {
        switch $vTcl(pr,projecttype) {
            single {
                append output [vTcl:dump_top $i]
            }
            multiple {
                append output [vTcl:dump_top_tofile $i $basedir $project_name]
            }
            default {
                append output [vTcl:dump_top $i]
            }
        }
    }
    append output "\n"

    vTcl:status "Saving: collecting options"

    append output [vTcl:dump:dump_user_bind]
    append output [vTcl:dump:save_tops]

    set vTcl(var_update) "yes"
    vTcl:statbar 0
    vTcl:status "Saving: writing data"
    return $output
}

proc vTcl:valid_class {class} {
    global vTcl
    if {[lsearch $vTcl(classes) $class] >= 0} {
        return 1
    } else {
        return 0
    }
}

proc vTcl:get_class {target {lower 0}} {
    set class [winfo class $target]

    if {![vTcl:valid_class $class]} { set class Toplevel }
    if {$lower == 1} { set class [vTcl:lower_first $class] }
    return $class
}

# if basename is 1 then the -in option will have the
# first path component replaced by $base
#
# example: -in .top27.fra32
#       => -in $base.fra32

proc vTcl:get_mgropts {opts {basename 0}} {
#    if {[lindex $opts 0] == "-in"} {
#        set opts [lrange $opts 2 end]
#    }
    set nopts ""
    set spot a
    foreach i $opts {
        if {$spot == "a"} {
            set o $i
            set spot b
        } else {
            set v $i
            switch -- $o {
                -ipadx -
                -ipady -
                -padx -
                -pady -
                -relx -
                -rely {
                    if {$v != "" && $v != 0} {
                        lappend nopts $o $v
                    }
                }
                -in {
                    if {$basename} {
                    	set v [vTcl:base_name $v]
                    	vTcl:log "Base name $v!"
                    }

                    if {$v != ""} {
                        lappend nopts $o $v
                    }
                }
                default {
                    if {$v != ""} {
                        lappend nopts $o $v
                    }
                }
            }
            set spot a
        }
    }
    return $nopts
}

proc vTcl:get_opts {opts} {
    set ret ""
    foreach i $opts {
        lassign $i opt x x def val
        if {[vTcl:streq $opt "-class"] || [vTcl:streq $val $def]} { continue }
        lappend ret $opt $val
    }
    return $ret
}

# @@change by Christian Gavin 3/18/2000
# converts image names to filenames before saving
# converts font object names to font keys before saving

proc vTcl:get_opts_special {opts w {save_always ""}} {
    global vTcl
    vTcl:WidgetVar $w save

    set ret {}
    foreach i $opts {
        lassign $i opt x x def val
        if {[vTcl:streq $opt "-class"]} { continue }
        if {![info exists save($opt)]} { set save($opt) 0 }
        if {!$save($opt) &&
          [lsearch -exact $save_always $opt] == -1} { continue }

        if [info exists vTcl(option,translate,$opt)] {
            set val [$vTcl(option,translate,$opt) $val]
            vTcl:log "Translated option: $opt value: $val"
        }
        lappend ret $opt $val
    }
    return $ret
}

# @@end_change

proc vTcl:dump_widget_quick {target} {
    global vTcl
    vTcl:update_widget_info $target
    set result "$target configure $vTcl(w,options)\n"
    append result "$vTcl(w,manager) $target $vTcl(w,info)\n"
    return $result
}

proc vTcl:dump_widget_opt {target basename} {
    global vTcl classes
    if {$target == "."} {
        vTcl:log "root widget manager = [winfo manager .]"
        set mgr wm
    } else {
        set mgr [winfo manager $target]
    }

    set result ""
    set class [vTcl:get_class $target]
    set opt [$target configure]

    ## Let's be safe and force wm for toplevel windows.  Just incase...
    if {$class == "Toplevel"} { set mgr wm }

    if {$target != "."} {
        if {$class == "Menu" && [string first .# $target] >= 0} { return }
        set result "$vTcl(tab)$classes($class,createCmd) "
        append result "$basename"

        if {$mgr == "wm" && $class != "Menu"} {
            append result " -class [winfo class $target]"
        }

        # use special proc to convert image names to filenames before
        # saving to disk
        set p [vTcl:get_opts_special $opt $target]

        if {$p != ""} {
            append result " \\\n[vTcl:clean_pairs $p]\n"
        } else {
            append result "\n"
        }

        if {$class == "Toplevel"} {
            if {![lempty [wm transient $target]]} {
                append result $vTcl(tab)
                append result "wm transient $target [wm transient $target]"
                append result "\; update\n"
            }
            if {[wm state $target] == "withdrawn"} {
                append result $vTcl(tab)
                append result "wm withdraw $target\n"
            }
        }
    }
    if {$mgr == "wm"} then {
        if {$class == "Menu"} then {
            append result [vTcl:dump_menu_widget $target $basename]
        } else {
            append result [vTcl:dump_top_widget $target $basename]
        }
    } elseif {$mgr == "menubar"} then {
        return ""
    } elseif {$mgr == "place" && $class == "Menu"} then {

        # this is a weird bug where the window manager switches
        # from 'wm' to 'place' for a menu, so we need to save the
        # menu anyway
        append result [vTcl:dump_menu_widget $target $basename]
    }

    append result [vTcl:dump_widget_bind $target $basename]
    return $result
}

proc vTcl:dump_widget_geom {target basename} {
    global vTcl
    if {$target == "."} {
        set mgr wm
    } else {
        set mgr [winfo manager $target]
    }
    if {$mgr == ""} {return}
    set class [winfo class $target]

    ## Let's be safe and force wm for toplevel windows.  Just incase...
    if {$class == "Toplevel"} { set mgr wm }

    ## Weird totally I mean like confusing kinda bug: the window manager
    ## switches from 'wm' for a menu to 'place' which messed up the saved
    ## file.
    if {$class == "Menu" && $mgr == "place"} {return ""}

    set result ""
    if {$mgr != "wm" \
        && $mgr != "menubar" \
        && $mgr != "tixGeometry" \
        && $mgr != "tixForm"} {
        set opts [$mgr info $target]
        set result "$vTcl(tab)$mgr $basename \\\n"
        append result "[vTcl:clean_pairs [vTcl:get_mgropts $opts 1]]\n"
    }
    set pre g
    set gcolumn [lindex [grid size $target] 0]
    set grow [lindex [grid size $target] 1]
    foreach a {column row} {
        foreach b {weight minsize} {
            set num [subst $$pre$a]
            for {set i 0} {$i < $num} {incr i} {
                if {[catch {
                    set x [expr {round([grid ${a}conf $target $i -$b])}]
                }]} {set x 0}
                if {$x} {
                    append result "$vTcl(tab)grid ${a}conf $basename $i -$b $x\n"
                }
            }
        }
    }
    return $result
}

proc vTcl:dump:dump_user_bind {} {

    global vTcl

    # are there any user defined tags at all?
    set tags $::widgets_bindings::tagslist
    if {$tags == ""} {
        return ""
    }

    set result ""

    foreach tag $tags {
        set bindlist [lsort [bind $tag]]
        foreach event $bindlist {
            set command [bind $tag $event]
            append result "bind \"$tag\" $event \{\n"
            append result "$vTcl(tab)[string trim $command]\n\}\n"
        }
    }

    append result "\n"
    return $result
}

proc vTcl:dump_widget_bind {target basename} {
    global vTcl
    set result ""
    if {[catch {bindtags $target \{$vTcl(bindtags,$target)\}}]} {
        return ""
    }
    # well, let's see if we have to save the bindtags
    set tags $vTcl(bindtags,$target)
    lremove tags vTcl(a) vTcl(b)
    if {$tags !=
        [::widgets_bindings::get_standard_bindtags $target]} {
            set reltags ""
            foreach tag $tags {
                if {"$tag" == "$target"} {
                    set tag [vTcl:base_name $target]
                } elseif {"$tag" == "[winfo toplevel $target]"} {
                    set tag \$base
                }
                if {[string match "* *" $tag]} {
                    set tag "\{$tag\}"
                }
                if {$reltags == ""} {
                    set reltags $tag
                } else {
                    append reltags " $tag"
                }
            }
            append result "$vTcl(tab)bindtags [vTcl:base_name $target] \"$reltags\"\n"
    }

    set bindlist [lsort [bind $target]]
    foreach i $bindlist {
        set command [bind $target $i]
        if {"$vTcl(bind,ignore)" == "" || ![regexp "^($vTcl(bind,ignore))" [string trim $command]]} {
            append result "$vTcl(tab)bind $basename $i \{\n"
            append result "$vTcl(tab2)[string trim $command]\n    \}\n"
        }
    }
    bindtags $target vTcl(b)
    return $result
}

proc vTcl:dump_menu_widget {target basename} {
    global vTcl tk_version
    set entries [$target index end]
    if {$entries == "none"} {return}
    set result ""
    for {set index 0} {$index <= $entries} {incr index} {
        set conf [$target entryconf $index]
        set type [$target type $index]
        switch $type {
            tearoff {}
            separator {
                append result "$vTcl(tab)$basename add separator\n"
            }
            default {
                # set pairs [vTcl:conf_to_pairs $conf ""]

                # to allow option translation
                set pairs [vTcl:get_opts_special $conf $target \
                    "-menu -label -image -command -tearoff -accelerator -value -onvalue -offvalue -variable"]

                append result "$vTcl(tab)$basename add $type \\\n"
                append result "[vTcl:clean_pairs $pairs]\n"
            }
        }
    }
    return $result
}

proc vTcl:dump_top_widget {target basename} {
    global vTcl
    set result ""
    foreach i $vTcl(attr,tops) {
        if { $vTcl(w,wm,$i) != "" } {
            switch $i {
                class {}
                title {
                    append result "$vTcl(tab)wm $i $basename"
                    # append result " \"$vTcl(w,wm,$i)\"\n"
                    append result " \"[wm title $target]\"\n"
                }
                state {
                    # switch $vTcl(w,wm,state) { }
                    switch [wm state $target] {
                        iconic {
                            append result "$vTcl(tab)wm iconify $basename\n"
                        }
                        normal {
                            append result "$vTcl(tab)wm deiconify $basename\n"
                        }
                        withdrawn {
                            if {$target == "."} {
                                append result "$vTcl(tab)wm withdraw $basename\n"
                            }
                        }
                    }
                }
                geometry {
                    append result "$vTcl(tab)wm $i $basename [wm $i $target]"
                    append result "\; update\n"
                }
                default {
                    ## Let's get the current values of the target.
                    # append result "$vTcl(tab)wm $i $basename $vTcl(w,wm,$i)\n"

                    append result "$vTcl(tab)wm $i $basename [wm $i $target]\n"
                }
            }
        }
    }

    return $result
}

# kc: dump all procs in the same manner, including support of default
# arguments.
# returns: definition of proc if it exists, empty string otherwise
proc vTcl:maybe_dump_proc {i} {
    global vTcl
    if {[info procs $i] != ""} {
        set args ""
        foreach j [info args $i] {
            if {[info default $i $j value]} {
                lappend args [list $j $value]
            } else {
                lappend args $j
            }
        }
        set body [string trim [info body $i]]
        return "\nproc $i \{$args\} \{\n$vTcl(tab)$body\n\}\n"
    }
    return ""
}


proc vTcl:dump_top {target} {
    global vTcl
    set output ""
    set proc_base $vTcl(winname)$target
    foreach i "$vTcl(winname)(pre)$target $vTcl(winname)(post)$target" {
        append output [vTcl:maybe_dump_proc $i]
    }
    if {![winfo exists $target]} {
        if {[info procs $proc_base] == ""} {
            return ""
        }
        append output [vTcl:maybe_dump_proc $proc_base]
        return $output
    }
    if {[winfo class $target] != "Toplevel" && $target != "."} {
        return
    }
    vTcl:update_widget_info $target
    append output "\nproc $vTcl(winname)$target \{base \{container 0\}\} \{\n"
    append output "$vTcl(tab)if {\$base == \"\"} {\n"
    append output "$vTcl(tab2)set base $target\n$vTcl(tab)}\n"
    if { $target != "." } {
        append output "$vTcl(tab)if \{\[winfo exists \$base\] && (!\$container)\} \{\n"
        append output "$vTcl(tab2)wm deiconify \$base; return\n"
        append output "$vTcl(tab)\}\n"
    }
    if {[wm state $target] == "normal" ||
        [wm state $target] == "iconic" ||
        $target == "."} {
        lappend vTcl(showtops) $target
    }
    incr vTcl(num,index)
    vTcl:statbar [expr {($vTcl(num,index) * 100) / $vTcl(num,total)}]

    append output [vTcl:dump:widgets $target]

    append output "\}\n"
    return $output
}

proc vTcl:dump:aliases {target} {

    if {$target == "."} {
    	return ""
    }

    global widget
    global vTcl

    set output "\n$vTcl(tab)global widget\n"
    set aliases [lsort [array names widget rev,$target*] ]

    foreach name $aliases {
        set value $widget($name)

        # don't dump aliases to non-existing widgets
        if {![winfo exists $widget($value)]} continue

        regexp {rev,(.*)} $name matchAll namenorev

        append output $vTcl(tab)
        append output "set widget(rev,[vTcl:base_name $namenorev]) \{$value\}\n"

        set alias $value
        if {[info exists widget([vTcl:get_top_level_or_alias $target],$alias)]} {
            set value $widget([vTcl:get_top_level_or_alias $target],$alias)
        } else {
            set value $widget($alias)
        }

        append output $vTcl(tab)
        append output "set \{widget($alias)\} \"[vTcl:base_name $value]\"\n"

        append output $vTcl(tab)
        append output "set widget([vTcl:base_name [vTcl:get_top_level_or_alias $value]],$alias) \"[vTcl:base_name $value]\"\n"

        if {$vTcl(pr,cmdalias)} {
            append output $vTcl(tab)
            set cmd [lindex [interp alias {} $alias] 0]
            set widg [vTcl:base_name $value]
            append output "interp alias {} $alias {} $cmd $widg\n"

            if {[winfo toplevel $target] != $namenorev} {
                append output $vTcl(tab)
                set newalias [vTcl:get_top_level_or_alias $namenorev].$alias
                if {[string match .top* $newalias]} {
                    set newalias [vTcl:base_name $newalias]
                }
                append output "interp alias {} $newalias {} $cmd $widg\n"
            }
        }
    }

    return "$output\n"
}

proc vTcl:dump:widgets {target} {
    global vTcl classes

    set output ""
    append output "[vTcl:dump:aliases $target]"

    set tree [vTcl:widget_tree $target]
    append output $vTcl(head,proc,widgets)
    foreach i $tree {
        set basename [vTcl:base_name $i]
        set class [vTcl:get_class $i]

        if {[string tolower $class] == "toplevel"} {
            append output "$vTcl(tab)if \{!\$container\} \{\n"
        }

            append output [$classes($class,dumpCmd) $i $basename]

        if {[string tolower $class] == "toplevel"} {
            append output "$vTcl(tab)\}\n"
        }

        incr vTcl(num,index)
        vTcl:statbar [expr {($vTcl(num,index) * 100) / $vTcl(num,total)}]
    }
    append output $vTcl(head,proc,geometry)
    foreach i $tree {
        set basename [vTcl:base_name $i]
        append output [vTcl:dump_widget_geom $i $basename]
    }
    return $output
}

## These are commands we want executed when we re-source the project.
proc vTcl:dump:save_tops {} {
    global vTcl

    foreach top [concat . $vTcl(tops)] {
        append string "Window show $top\n"
        continue

        if {[lsearch $vTcl(showtops) $top] > -1} {
           append string "Window show $top\n"
            continue
        }
	vTcl:dump:not_sourcing_header string
        append string "Window show $top; update; Window hide $top"
	vTcl:dump_sourcing_footer string
    }

    return $string
}

proc vTcl:dump:gather_widget_info {} {
    global vTcl classes

    if {[info exists vTcl(images,stock)]} { lappend vars stockImages }
    if {[info exists vTcl(images,user)]}  { lappend vars userImages  }
    if {[info exists vTcl(fonts,stock)]}  { lappend vars stockFonts  }
    if {[info exists vTcl(fonts,user)]}   { lappend vars userFonts   }

    if {[lempty $vars]} { return }

    set vTcl(dump,libraries) {}
    foreach var $vars { set vTcl(dump,$var) {} }

    set children [vTcl:complete_widget_tree . 0]

    foreach child $children {
	set c [vTcl:get_class $child]
    	lappend vTcl(dump,libraries) $classes($c,lib)
        foreach type [list stock user] {
            if {![catch {$child cget -image} image]
                && [lsearch $vTcl(images,$type) $image] > -1} {
                lappend vTcl(dump,${type}Images) $image
            }
            if {![catch {$child cget -font} font]
                && [lsearch $vTcl(fonts,$type) $font] > -1} {
                lappend vTcl(dump,${type}Fonts) $font
            }

            if {[vTcl:get_class $child] == "Menu"} {
                set size [$child index end]
		if {[vTcl:streq $size "none"]} { continue }
		for {set i 0} {$i <= $size} {incr i} {
		    if {![catch {$child entrycget $i -image} image]
			&& [lsearch $vTcl(images,$type) $image] > -1} {
			lappend vTcl(dump,${type}Images) $image
		    }
		}
            }
        } ; # foreach type [...]
    }

    set vTcl(dump,libraries) [vTcl:lrmdups $vTcl(dump,libraries)]
}

proc vTcl:dump:project_info {basedir project} {
    global vTcl

    set out   {}
    set multi 0
    if {![vTcl:streq $vTcl(pr,projecttype) "single"]} { set multi 1 }

    # We don't want information for the displayed widget tree
    #                                        v
    set widgets [vTcl:complete_widget_tree . 0]

    ## It's a single project without a project file.
    if {!$multi && !$vTcl(pr,projfile)} {
    	vTcl:dump:sourcing_header out
	append out "\n"
    }

    append out "proc vTcl:project:info \{\} \{\n"

    foreach widget $widgets {
        if {[vTcl:streq $widget "."]} { continue }
        set testing [namespace children ::widgets ::widgets::${widget}]
        if {$testing == ""} { continue }

	vTcl:WidgetVar $widget save
        set list {}
        foreach var [lsort [array names save]] {
            if {!$save($var)} { continue }
            lappend list $var $save($var)
        }

        append out $vTcl(tab)
        append out "namespace eval ::widgets::$widget \{\n"
        append out $vTcl(tab2)
        append out "array set save [list $list]\n"
        append out "$vTcl(tab)\}\n"
    }

    append out $vTcl(tab)
    append out "namespace eval ::widgets_bindings \{\n"
    append out $vTcl(tab2)
    append out "set tagslist [list $::widgets_bindings::tagslist]\n"
    append out "$vTcl(tab)\}\n"

    append out "\}\n"

    if {!$multi} {
        if {!$vTcl(pr,projfile)} {
	    vTcl:dump:sourcing_footer out
	    return $out
	}
        set file [file root $project].vtp
    } else {
        set file [file root $project].vtp
        set dir [vTcl:dump:get_multifile_project_dir $project]
        file mkdir [file join $basedir $dir]
        set file [file join $basedir $dir $file]
    }

    set fp [open $file w]
    puts $fp $out
    close $fp
    return
}

proc vTcl:dump:sourcing_header {varName} {
    upvar 1 $varName var
    append var "\nif {\[info exists vTcl(sourcing)\]} \{"
}

proc vTcl:dump:not_sourcing_header {varName} {
    upvar 1 $varName var
    append var "\nif {!\[info exists vTcl(sourcing)\]} \{"
}

proc vTcl:dump:sourcing_footer {varName} {
    upvar 1 $varName var
    if {![vTcl:streq [string index $var end] "\n"]} { append var "\n" }
    append var "\}"
}
