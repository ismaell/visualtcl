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
    set children [vTcl:list_widget_tree .]

    foreach child $children {
    	lappend classList [vTcl:get_class $child]
    }

    foreach class [vTcl:lrmdups $classList] {
	eval lappend list $classes($class,exportCmds)
	eval lappend list $classes($class,widgetProc)
    }

    foreach i [vTcl:lrmdups $list] {
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

proc vTcl:vtcl_library_procs {} {
    global vTcl classes

    set list {
	Window
    }

    foreach proc $list {
	append output [vTcl:maybe_dump_proc $proc]
    }
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

    if {! [info exists vTcl(pr,projecttype)]} {
	return ""
    }

    if {$vTcl(pr,projecttype) == "single"} {
        return ""
    }

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
        set o [lindex $i 0]
        set v [lindex $i 4]
        if {$o != "-class" && $v != [lindex $i 3]} {
            lappend ret $o $v
        }
    }
    return $ret
}

# @@change by Christian Gavin 3/18/2000
# converts image names to filenames before saving
# converts font object names to font keys before saving

proc vTcl:get_opts_special {opts} {

    global vTcl
    set ret ""
    foreach i $opts {
        set o [lindex $i 0]
        set v [lindex $i 4]
        if {$o != "-class" && $v != [lindex $i 3]} {

	    if [info exists vTcl(option,translate,$o)] {

	    	set v [$vTcl(option,translate,$o) $v]
	    	vTcl:log "Translated option: $o value: $v"
	    }

            lappend ret $o $v
        }
    }
    return $ret
}

# @@end_change

proc vTcl:dump_widget_quick {target} {
    global vTcl
    vTcl:update_widget_info $target
    set result "$target conf $vTcl(w,options)\n"
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
    set opt [$target conf]

    ## Let's be safe and force wm for toplevel windows.  Just incase...
    if {$class == "Toplevel"} { set mgr wm }
    
    if {$target != "."} {
	if {$class == "Menu" && [string first .# $target] >= 0} { return }
        set result "$vTcl(tab)$classes($class,createCmd) "
	append result "$basename"

        if {$mgr == "wm" && $class != "Menu"} {
            append result " -class [winfo class $target]"
        }

        # @@change by Christian Gavin 3/18/2000
        # use special proc to convert image names to filenames before
        # saving to disk

        set p [vTcl:get_opts_special $opt]

        # @@end_change

        if {$p != ""} {
            append result " \\\n[vTcl:clean_pairs $p]\n"
        } else {
            append result "\n"
        }

	if {$class == "Toplevel" && [wm state $target] == "withdrawn"} {
	    append result $vTcl(tab)
	    append result "wm withdraw $target\n"
	}
    }
    if {$mgr == "wm"} {
        if {$class == "Menu"} {
            append result [vTcl:dump_menu_widget $target $basename]
        } else {
            append result [vTcl:dump_top_widget $target $basename]
        }
    } elseif {$mgr == "menubar"} {
        return ""
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

proc vTcl:dump_widget_bind {target basename} {
    global vTcl
    set result ""
    if {[catch {bindtags $target \{$vTcl(bindtags,$target)\}}]} {
        return ""
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
		set pairs [vTcl:get_opts_special $conf]

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
                    append result "$vTcl(tab)wm $i $basename [wm $i $target]\n"
		    append result "$vTcl(tab)update\n"
		}
                default {
		    ## Let's get the current values of the target.
                    # append result "$vTcl(tab)wm $i $basename $vTcl(w,wm,$i)\n"

                    append result "$vTcl(tab)wm $i $basename "
		    append result [wm $i $target]\n
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

	append output $vTcl(tab)
	append output "set widget(rev,[vTcl:base_name $name]) \{$value\}\n"

	set alias $value
	set value $widget($alias)

	append output $vTcl(tab)
	append output "set \{widget($alias)\} \"[vTcl:base_name $value]\"\n"

	# .top38.cpd28 => {} top38 cpd28
	set components [split $value .]

	# {} top38 cpd28 fra21 => cpd28 fra21
	set components [lrange $components 2 end]

	append output $vTcl(tab)
	append output "set \{widget(child,$alias)\} \"[join $components .]\"\n"

	if {$vTcl(pr,cmdalias)} {
	    append output $vTcl(tab)
	    set cmd [lindex [interp alias {} $alias] 0]
	    set widg [vTcl:base_name $value]
	    append output "interp alias {} $alias {} $cmd $widg\n"
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
	append string "if {\[info exists vTcl(sourcing)\]} \{"
	append string "Window show $top; update; Window hide $top"
	append string "\}\n"
    }

    return $string
}
