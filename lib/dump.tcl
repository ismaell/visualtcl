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

proc vTcl:dump_proc {i {type ""}} {
    if {[info procs $i] == ""} {return ""}

    set output ""
    set args ""
    foreach j [info args $i] {
        if {[info default $i $j value]} {
            lappend args [list $j $value]
        } else {
            lappend args $j
        }
    }

    set body [info body $i]

    append output {#############################################################################}
    append output "\n\#\# ${type}Procedure:  $i\n"

    if {[regexp (.*):: $i matchAll context] } {
        append output "\nnamespace eval [list ${context}] \{\n"
    }

    append output "\nproc \{$i\} \{$args\} \{$body\}\n"

    if {[regexp (.*):: $i]} {
        append output "\n\}\n"
    }

    return $output
}

proc vTcl:save_procs {} {
    global vTcl
    set output ""
    set list $vTcl(procs)
    foreach i $list {
        if {[vTcl:ignore_procname_when_saving $i] == 0 && $i != "init"} {
            append output [vTcl:dump_proc $i]
        }
    }
    return $output
}

proc vTcl:export_procs {} {
    global vTcl classes

    set output ""
    vTcl:dump:not_sourcing_header output
    set children [vTcl:complete_widget_tree . 0]

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

    foreach i [concat Window [vTcl:lrmdups $list]] {
        append output [vTcl:dump_proc $i "Library "]
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

# if basename is not empty then the -in option will have the
# value specified by basename
#
# example: -in .top27.fra32
#       => -in $base.fra32

proc vTcl:get_mgropts {opts {basename {}}} {
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
                    if {$basename != ""} {
                    	set v $basename
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

## This proc works as get_opts_special but is intended for widget
## subcomponents (pages, columns, childsites) where the user cannot
## save or not save an option.
proc vTcl:get_subopts_special {opts w} {
    if {[info exists ::widgets::${w}::subOptions::save]} {
        ## if there is a list of options to save, use it, and delegate
	## to sister function to do so
        return [vTcl:get_subopts_special_save $opts $w]
    }

    global vTcl
    set ret ""
    foreach i $opts {
        ## avoid option shortcuts (like -bg)
        if {[llength $i] != 5} {continue}

	lassign $i opt x x def val
        if {[vTcl:streq $opt "-class"] || [vTcl:streq $val $def]} { continue }
        if {[info exists vTcl(option,translate,$opt)]} {
            set val [$vTcl(option,translate,$opt) $val]
        }
        lappend ret $opt $val
    }
    return $ret
}

proc vTcl:get_subopts_special_save {opts w} {
    upvar ::widgets::${w}::subOptions::save subSave

    global vTcl
    set ret ""
    foreach i $opts {
        ## avoid option shortcuts (like -bg)
        if {[llength $i] != 5} {continue}

	lassign $i opt x x def val
        if {[vTcl:streq $opt "-class"]} {continue}
	if {![info exists subSave($opt)]} {continue}
	if {!$subSave($opt)} {continue}
        if {[info exists vTcl(option,translate,$opt)]} {
            set val [$vTcl(option,translate,$opt) $val]
        }
        lappend ret $opt $val
    }
    return $ret
}

## This proc does option translation:
## - converts image names to filenames before saving
## - converts font object names to font keys before saving
## - etc.
proc vTcl:get_opts_special {opts w {save_always ""}} {
    global vTcl
    vTcl:WidgetVar $w save

    set ret {}
    foreach i $opts {
        lassign $i opt x x def val
        if {[vTcl:streq $opt "-class"]} { continue }
        if {![info exists save($opt)]} { set save($opt) 0 }
        if {!$save($opt) && [lsearch -exact $save_always $opt] == -1} {continue}
        if {[info exists vTcl(option,translate,$opt)]} {
            set val [$vTcl(option,translate,$opt) $val]
        }
        lappend ret $opt $val
    }
    return $ret
}

proc vTcl:dump_widget_quick {target} {
    global vTcl
    vTcl:update_widget_info $target
    set result "$target configure $vTcl(w,options)\n"
    append result "$vTcl(w,manager) $target $vTcl(w,info)\n"
    return $result
}

proc vTcl:dump_widget_opt {target basename} {
    global vTcl classes

    set result ""
    set mgr [winfo manager $target]
    set class [vTcl:get_class $target]
    set opt [$target configure]

    set result "$vTcl(tab)$classes($class,createCmd) "
    append result "$basename"

    if {$mgr == "wm" && $class != "Menu"} {
        append result " -class [winfo class $target]"
    }

    # use special proc to convert image names to filenames before saving to disk
    set p [vTcl:get_opts_special $opt $target]

    if {$p != ""} {
        append result " \\\n[vTcl:clean_pairs $p]\n"
    } else {
        append result "\n"
    }

    if {$mgr == "menubar"} then {
        return ""
    }

    append result [vTcl:dump_widget_alias $target $basename]
    append result [vTcl:dump_widget_bind $target $basename]
    return $result
}

proc vTcl:dump_widget_alias {target basename} {
    global vTcl widget classes
    if {![info exists widget(rev,$target)]} {
        return ""
    }
    set alias $widget(rev,$target)
    set top_or_alias [vTcl:get_top_level_or_alias $target]

    if {[winfo toplevel $target] == $target} {
        set top_or_alias ""
    }

    set c [vTcl:get_class $target]
    append output $vTcl(tab)
    append output "vTcl:DefineAlias \"[vTcl:base_name $target]\" \"$alias\""
    append output " $classes($c,widgetProc)"
    append output " \"[vTcl:base_name $top_or_alias]\" $vTcl(pr,cmdalias)\n"

    return $output
}

proc vTcl:dump_widget_geom {target basename} {
    global vTcl classes
    if {$target == "."} {
        set mgr wm
    } else {
        set mgr [winfo manager $target]
    }
    if {$mgr == ""} {return}
    set class [winfo class $target]

    ## Let's be safe and force wm for toplevel windows.  Just incase...
    if {$class == "Toplevel"} { set mgr wm }

    ## That shouldn't be necessary any more. Doesn't hurt anyway.
    if {$class == "Menu" && $mgr == "place"} {return ""}

    set result ""
    if {[lsearch -exact {wm menubar tixGeometry tixForm busy} $mgr] == -1} {
        set result ""
        if {(($mgr == "pack") && (![pack propagate $target])) ||
            (($mgr == "grid") && (![grid propagate $target]))} {
            # Do them both!  Important when mixing geometery managers
            append result "$vTcl(tab)pack propagate $basename 0\n"
            append result "$vTcl(tab)grid propagate $basename 0\n"
        }
        set opts [$mgr info $target]
        append result "$vTcl(tab)$mgr $basename \\\n"
        set basesplit  [split $basename .]
        set length     [llength $basesplit]
        set parentname [join [lrange $basesplit 0 [expr $length - 2]] .]
        append result "[vTcl:clean_pairs [vTcl:get_mgropts $opts $parentname]]\n"
    }

    ## Megawidgets are like blackboxes. We don't want to know what's inside,
    ## and besides, they are supposed to configure themselves on construction.
    if {[info exists classes($class,megaWidget)] &&
        $classes($class,megaWidget)} {return $result}

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
        append result {#############################################################################}
        append result "\n\#\# Binding tag:  $tag\n\n"
        if {$tag == "_vTclBalloon"} {
            vTcl:dump:not_sourcing_header result
        }
        set bindlist [lsort [bind $tag]]
        foreach event $bindlist {
            set command [bind $tag $event]
            append result "bind \"$tag\" $event \{\n"
            append result "$vTcl(tab)[string trim $command]\n\}\n"
        }
        if {$tag == "_vTclBalloon"} {
            vTcl:dump:sourcing_footer result
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
                    set tag \$top
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
	## replace occurences of widget path by %W to avoid absolute widget paths
	regsub -all $target $command %W command
	## dump it
        if {"$vTcl(bind,ignore)" == "" || ![regexp "^($vTcl(bind,ignore))" [string trim $command]]} {
            append result "$vTcl(tab)bind $basename $i \{\n"
            append result "$vTcl(tab2)[string trim $command]\n    \}\n"
        }
    }
    bindtags $target vTcl(b)
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
                    set dump_origin 1
                    set dump_size 1
                    if {[info exists ::widgets::${target}::set,origin]} {
                        set dump_origin [vTcl:at ::widgets::${target}::set,origin]
                    }
                    if {[info exists ::widgets::${target}::set,size]} {
                        set dump_size [vTcl:at ::widgets::${target}::set,size]
                    }
                    set geom_list [split [wm $i $target] x+]
                    set geom_dump ""
                    if {$dump_size} {
                        append geom_dump [join [lrange $geom_list 0 1] x]
                    }
                    if {$dump_origin} {
                        append geom_dump +[join [lrange $geom_list 2 3] +]
                    }
                    if {$geom_dump != ""} {
                        append result "$vTcl(tab)wm $i $basename $geom_dump"
                        append result "\; update\n"
                    }
                }
                default {
                    ## Let's get the current values of the target.
                    append result "$vTcl(tab)wm $i $basename [wm $i $target]\n"
                }
            }
        }
    }

    return $result
}

proc vTcl:dump_top {target} {
    return [vTcl::widgets::core::toplevel::dumpTop $target]
}

proc vTcl:dump:aliases {target} {

    if {$target == "."} {
    	return ""
    }

    global widget classes
    global vTcl

    set output "\n$vTcl(tab)global widget\n"
    set aliases [lsort [array names widget rev,$target*] ]

    foreach name $aliases {
        set value $widget($name)

        # don't dump aliases to non-existing widgets
        if {![winfo exists $widget($value)]} continue

        set alias $value
        set top_or_alias [vTcl:get_top_level_or_alias $target]

        if {[info exists widget($top_or_alias,$alias)]} {
            set value $widget($top_or_alias,$alias)
        } else {
            set value $widget($alias)
        }

        if {$value == $target} {
            set top_or_alias ""
        }

        set c [vTcl:get_class $value]
        append output $vTcl(tab)
        append output "vTcl:DefineAlias \"[vTcl:base_name $value]\" \"$alias\""
        append output " $classes($c,widgetProc)"
        append output " \"[vTcl:base_name $top_or_alias]\" $vTcl(pr,cmdalias)\n"
    }

    return "$output\n"
}

proc vTcl:dump:widgets {target} {
    global vTcl classes

    set output ""
    # append output "[vTcl:dump:aliases $target]"

    # for dumping widgets recursively using relative paths
    set classes(Frame,dumpChildren) 0
    set classes(Menu,dumpChildren) 0
    set tree [vTcl:widget_tree $target]

    append output $vTcl(head,proc,widgets)
    foreach i $tree {
        set basename [vTcl:base_name $i]
        set class [vTcl:get_class $i]

        append output [$classes($class,dumpCmd) $i $basename]

        if {[string tolower $class] == "toplevel"} {
            append output "$vTcl(tab)vTcl:FireEvent $basename <<Create>>\n"
            append output "$vTcl(tab)wm protocol $basename WM_DELETE_WINDOW \""
            append output "vTcl:FireEvent $basename <<DeleteWindow>>\"\n\n"
        }

        incr vTcl(num,index)
        vTcl:statbar [expr {($vTcl(num,index) * 100) / $vTcl(num,total)}]
    }
    append output $vTcl(head,proc,geometry)
    foreach i $tree {
        set basename [vTcl:base_name $i]
        append output [vTcl:dump_widget_geom $i $basename]
    }

    # end of dumping widgets with relative paths
    set classes(Frame,dumpChildren) 1
    set classes(Menu,dumpChildren) 1

    return $output
}

## These are commands we want executed when we re-source the project.
proc vTcl:dump:save_tops {} {
    global vTcl

    foreach top [concat . $vTcl(tops)] {
        append string "Window show $top\n"
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

        foreach resource {image font} {
            set used_${resource} {}
            set value {}
            catch {set value [$child cget -$resource]}
            if {$value != ""} {
                lappend used_${resource} $value
            }
            set cmd get[string totitle $resource]sCmd
            if {[info exists classes($c,$cmd)]} {
                set used_${resource} \
                  [concat [vTcl:at used_${resource}] [$classes($c,$cmd) $child]]
            }
            foreach type {stock user} {
                foreach object [vTcl:at used_${resource}] {
                    if {[lsearch [vTcl:at vTcl(${resource}s,$type)] $object] > -1} {
                       lappend vTcl(dump,$type[string totitle $resource]s) $object
                    }
                }
            } ; # foreach type ...
        } ; # foreach resource ...
    } ; # foreach child ...

    foreach var $vars { set vTcl(dump,$var) [vTcl:lrmdups $vTcl(dump,$var)] }
    set vTcl(dump,libraries) [vTcl:lrmdups $vTcl(dump,libraries)]
}

proc vTcl:dump:widget_info {target basename} {
    global vTcl

    set testing [namespace children ::widgets ::widgets::${target}]
    if {$testing == ""} { return }

    vTcl:WidgetVar $target save
    set list {}
    foreach var [lsort [array names save]] {
       if {!$save($var)} { continue }
       lappend list $var $save($var)
    }

    append out $vTcl(tab)
    append out "namespace eval ::widgets::$basename \{\n"
    append out $vTcl(tab2)
    append out "array set save [list $list]\n"

    ## suboptions for megawidgets
    if {[info exists ::widgets::${target}::subOptions::save]} {
        upvar ::widgets::${target}::subOptions::save subSave
        set list {}
        foreach var [lsort [array names subSave]] {
            if {!$subSave($var)} { continue }
            lappend list $var $subSave($var)
        }
        if {![lempty $list]} {
            append out $vTcl(tab2)
            append out "namespace eval subOptions \{\n"
            append out $vTcl(tab)$vTcl(tab2)
            append out "array set save [list $list]\n"
            append out $vTcl(tab2)\}\n
        }
    }

    append out "$vTcl(tab)\}\n"
    return $out
}

proc vTcl:dump:project_info {basedir project} {
    global vTcl classes

    set out   {}
    set multi 0
    if {![vTcl:streq $vTcl(pr,projecttype) "single"]} { set multi 1 }

    ## It's a single project without a project file.
    if {!$multi && !$vTcl(pr,projfile)} {
    	vTcl:dump:sourcing_header out
	append out "\n"
    }

    append out "proc vTcl:project:info \{\} \{\n"

    foreach i $vTcl(tops) {
        append out "$vTcl(tab)set base $i\n"
        append out [$classes(Toplevel,dumpInfoCmd) $i {$base}]
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
    append var "\nif {\[info exists vTcl(sourcing)\]} \{\n"
}

proc vTcl:dump:not_sourcing_header {varName} {
    upvar 1 $varName var
    append var "\nif {!\[info exists vTcl(sourcing)\]} \{\n"
}

proc vTcl:dump:sourcing_footer {varName} {
    upvar 1 $varName var
    if {![vTcl:streq [string index $var end] "\n"]} { append var "\n" }
    append var "\}\n"
}
