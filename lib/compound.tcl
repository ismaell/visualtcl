##############################################################################
#
# compound.tcl - procedures for creating and inserting compound-widgets
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

##########################################################################
# Compound Widgets
#
# compound   = type options mgr-info bind-info children
# mgr-info   = geom-manager-name geom-info
# bind-info  = list of: {event} {command}
# menu-info  = list of: {type} {options}
# children   = list-of-compound-widgets (recursive)
#

proc vTcl:save_compounds {} {
    global vTcl
    set file [vTcl:get_file save "Save Compound Library"]
    if {$file == ""} {return}
    set f [open $file w]
    puts $f "set vTcl(cmpd,list) \"$vTcl(cmpd,list)\"\n"
    set index 0
    set num [llength $vTcl(cmpd,list)]
    foreach i $vTcl(cmpd,list) {
        puts $f "set \{vTcl(cmpd:$i)\} \{$vTcl(cmpd:$i)\}\n"
        incr index
        vTcl:statbar [expr {($index * 100) / $num}]
    }
    close $f
    vTcl:statbar 0
}

proc vTcl:load_compounds {{file ""}} {
    global vTcl

    # @@change by Christian Gavin 3/5/2000
    # if a file is given in file parameter, use it,
    # otherwise prompts for a file

    if {$file == ""} {
	    set file [vTcl:get_file open "Load Compound Library"]
    }

    # @@end_change

    if {$file == ""} {return}
    vTcl:statbar 10
    source $file
    vTcl:statbar 80
    vTcl:cmp_user_menu
    vTcl:statbar 0
}

proc vTcl:name_replace {name s} {
    global vTcl
    foreach i $vTcl(cmp,alias) {
        set s [vTcl:replace [lindex $i 0] $name[lindex $i 1] $s]
    }
    return $s
}

proc vTcl:put_compound {text compound} {
    global vTcl

    if {$vTcl(pr,autoplace)} {
	vTcl:auto_place_compound $compound $vTcl(w,def_mgr) {}
	return
    }

    vTcl:status "Insert $text"

    # because the bind commands does % substitution
    regsub -all % $compound %% compound

    bind vTcl(b) <Button-1> \
    	"vTcl:place_compound [list $compound] $vTcl(w,def_mgr) %X %Y %x %y
         set vTcl(cursor,last) \[%W cget -cursor\]
         set vTcl(cursor,w) %W"
}

proc vTcl:auto_place_compound {compound gmgr gopt} {
    global vTcl

    set name [vTcl:new_widget_name cpd $vTcl(w,insert)]

    vTcl:insert_compound $name $compound $gmgr $gopt
    vTcl:setup_bind_tree $name
    vTcl:active_widget $name
    vTcl:update_proc_list

    # @@change by Christian Gavin 3/5/2000
    #
    # when new compound inserted into window, automatically
    # refresh widget tree

    # after idle {vTcl:init_wtree}

    vTcl:init_wtree

    # @@end_change
}

proc vTcl:place_compound {compound gmgr rx ry x y} {
    global vTcl

    vTcl:status Status

    vTcl:rebind_button_1

    set vTcl(w,insert) [winfo containing $rx $ry]

    set gopt {}
    if {$gmgr == "place"} { append gopt "-x $x -y $y" }

    vTcl:auto_place_compound $compound $gmgr $gopt
}

proc vTcl:insert_compound {name compound {gmgr pack} {gopt ""}} {
    global vTcl

    set cpd \{[lindex $compound 0]\}
    set alias [lindex $compound 1]
    set vTcl(cmp,alias) [lsort -decreasing -command vTcl:sort_cmd $alias]
    set cmd [vTcl:extract_compound $name $name $cpd 0 $gmgr $gopt]
    set do "$cmd"
    set undo "destroy $name"
    vTcl:push_action $do $undo
    lappend vTcl(widgets,[winfo toplevel $name]) $name

    # moved to widget creation inside compound
    # vTcl:widget:register_all_widgets $name
}

## -background #dcdcdc -text {foobar} ...
## =>
## -background -text ...

proc vTcl:options_only {opts} {

    set result ""

    set l [llength $opts]
    set i 0
    while {$i < $l} {
        lappend result [lindex $opts $i]
        incr i 2
    }

    return $result
}

proc vTcl:extract_compound {base name compound {level 0} {gmgr ""} {gopt ""}} {
    global vTcl widget classes

    set todo ""
    foreach i $compound {
        set class [string trim [lindex $i 0]]
        set opts [string trim [lindex $i 1]]
        set mgr  [string trim [lindex $i 2]]
        set mgrt [string trim [lindex $mgr 0]]
        set mgri [string trim [lindex $mgr 1]]
        set bind [string trim [lindex $i 3]]
        set menu [string trim [lindex $i 4]]
        set chld [string trim [lindex $i 5]]
        set wdgt [string trim [lindex $i 6]]
        set alis [string trim [lindex $i 7]]
        set grid [string trim [lindex $i 8]]
        set proc [string trim [lindex $i 9]]
        set cmpdname [string trim [lindex $i 10]]
        set topopt [string trim [lindex $i 11]]

        ## process procs first in case there are dependencies (init)
        foreach j $proc {
            set nme [lindex $j 0]
            set arg [lindex $j 1]
            set bdy [lindex $j 2]

            ## if the proc name is in a namespace, make sure namespace exists
	    if {[string match ::${cmpdname}::* $nme]} {
                namespace eval ::${cmpdname} [list proc $nme $arg $bdy]
            } else {
                proc $nme $arg $bdy
            }

            vTcl:list add "{$nme}" vTcl(procs)
        }
        if {[lsearch -exact $vTcl(procs) "::${cmpdname}::init"] >= 0 } {
            eval [list ::${cmpdname}::init] $name
        }
        if {$mgrt == "wm" || $base == "."} {
            set base $name
        } elseif {$level == 0 && $gmgr != ""} {
            if {$gmgr != $mgrt || $gopt != ""}  {
                set mgrt $gmgr
                set mgri $gopt
            }
            if {$mgrt != "place"} {
                set mgri [lrange $mgri 2 end]
            }
        }
        if {$level > 0} {
            set name "$base$wdgt"
        } elseif {$class == "Toplevel"} {
            set vTcl(w,insert) $name
            lappend vTcl(tops) $name
            vTcl:update_top_list
        }

        set replaced_opts [vTcl:name_replace $base $opts]
        append todo "$classes($class,createCmd) $name "
	append todo "$replaced_opts; "
        if {$mgrt != "" && $mgrt != "wm"} {
            if {$mgrt == "place" && $mgri == ""} {
                set mgri "-x 5 -y 5"
            }
            append todo "$mgrt $name [vTcl:name_replace $base $mgri]; "
        } elseif {$mgrt == "wm"} {
        } else {
            set ret $name
        }
        foreach j $topopt {
            set opt [lindex $j 0]
            set val [lindex $j 1]
            switch $opt {
                {} {}
                state {
                }
                title {
                    append todo "wm $opt $name \"$val\"; "
                }
                default {
                    append todo "wm $opt $name $val; "
                }
            }
        }

        ## widget registration
        append todo "vTcl:widget:register_widget $name; "

        ## restore default values
        set opts_only [vTcl:options_only $replaced_opts]
        foreach def $classes($class,defaultValues) {
            ## only replace the options not specified in the compound
            if {[lsearch -exact $opts_only $def] == -1} {
                append todo "vTcl:prop:default_opt $name $def vTcl(w,opt,$def); "
            }
        }

        ## options not to save
        foreach def $classes($class,dontSaveOptions) {
            append todo "vTcl:prop:save_or_unsave_opt $name $def vTcl(w,opt,$def) 0; "
        }

        set index 0
        incr level
        foreach j $bind {
            # see if it is a list of bindtags, a binding for
            # the target, or a binding for a bindtag (ya follow me?)
            switch -exact -- [llength $j] {
                1 {
                    append todo "bindtags $name [list [vTcl:name_replace $base [lindex $j 0]]]; "
                }

                2 {
                    set e [lindex $j 0]
                    set c [vTcl:name_replace $base [lindex $j 1]]
                    append todo "bind $name $e \{$c\}; "
                }

                3 {
                    set bindtag [lindex $j 0]
                    set event   [lindex $j 1]

                    if {[lsearch -exact $::widgets_bindings::tagslist $bindtag] == -1} {
                       lappend ::widgets_bindings::tagslist $bindtag
                    }

                    append todo "if \{\[bind $bindtag $event] == \"\"\} \{bind $bindtag $event \{[lindex $j 2]\}\}; "
                }

                default {
                    oops "Internal error"
                }
            }
        }
        foreach j $menu {
            set t [lindex $j 0]
            set o [lindex $j 1]
            if {$t != "tearoff"} {
                append todo "$name add $t [vTcl:name_replace $base $o]; "
            }
        }
	if {$classes($class,dumpChildren)} {
	    foreach j $chld {
	       append todo "[vTcl:extract_compound $base $name \{$j\} $level]; "
		incr index
	    }
	}
        if {$alis != ""} {
            append todo "vTcl:set_alias $name $alis -noupdate; "
        } elseif {$alis == "" && $vTcl(pr,autoalias)} {
            set next [vTcl:next_widget_name $class]
            append todo "vTcl:set_alias $name $next -noupdate; "
        }

        foreach j $grid {
            set cmd [lindex $j 0]
            set num [lindex $j 1]
            set prop [lindex $j 2]
            set val [lindex $j 3]
            append todo "grid $cmd $name $num $prop $val; "
        }

        if {[lsearch -exact $vTcl(procs) "::${cmpdname}::main"] >= 0 } {
	    append todo "[list ::${cmpdname}::main] $name"
        }
    }

    return $todo
}

proc vTcl:create_compound {target {cmpdname ""}} {
    global vTcl
    set vTcl(cmp,alias) ""
    set ret [vTcl:gen_compound $target "" $cmpdname]
    lappend ret $vTcl(cmp,alias)
    return $ret
}

proc vTcl:gen_compound {target {name ""} {cmpdname ""}} {
    global vTcl widget
    set ret ""
    set mgr ""
    set bind ""
    set menu ""
    set chld ""
    set alias ""
    set grid ""
    set proc ""
    if {![winfo exists $target]} {
        return ""
    }
    set class [vTcl:get_class $target]

    # @@change by Christian Gavin 3/6/2000
    # rename conf to configure because Iwidgets don't like
    # conf only

    set opts [vTcl:get_opts [$target configure]]

    # @@end_change

    if {$class == "Menu"} {
        set mnum [$target index end]
        if {$mnum != "none"} {
            for {set i 0} {$i <= $mnum} {incr i} {
                set t [$target type $i]
                set c [vTcl:get_opts [$target entryconf $i]]
                lappend menu "$t \{$c\}"
            }
        }
        set mgrt {}
        set mgri {}
    } elseif {$class == "Toplevel"} {
        set mgrt "wm"
        set mgri ""
    } else {
        set mgrt [winfo manager $target]

        # @@debug
        vTcl:log "gen_compound: mgrt=\"$mgrt\""
        # @@end_debug

 	# @@change by Christian Gavin 3/6/2000
 	# in Iwidgets, some controls are not yet packed/gridded/placed
 	# when they are in edit mode, therefore there is no manager at
 	# this time

	if {[lempty $mgrt] || [lempty [info commands $mgrt]]} {
	    set mgri {}
        } else {
	    set mgri [vTcl:get_mgropts [$mgrt info $target]]
	}

 	# @@end_change
    }
    lappend mgr $mgrt $mgri
    set blst [bind $target]
    foreach i $blst {
        lappend bind "$i \{[bind $target $i]\}"
    }

    # now, are bindtags non-standard ?
    set bindtags $vTcl(bindtags,$target)
    if {$bindtags != [::widgets_bindings::get_standard_bindtags $target] } {
        # append the list of binding tags
        lappend bind [list $bindtags]

        # keep all bindings definitions with the compound
        # (even if children define them too)
        foreach bindtag $bindtags {
            if {[lsearch -exact $::widgets_bindings::tagslist $bindtag] >= 0} {
                foreach event [bind $bindtag] {
                    lappend bind "$bindtag $event \{[bind $bindtag $event]\}"
                }
            }
        }
    }

    foreach i [vTcl:get_children $target] {

      # change cy CGavin to retain children names
      # while creating a compound
      set windowpath [split $i .]
      set lastpath [lindex $windowpath end]

	append chld "[vTcl:gen_compound $i $name.$lastpath] "
    }

    catch {set alias $widget(rev,$target)}
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
                if {$x > 0} {
                    lappend grid "${a}conf $i -$b $x"
                }
            }
        }
    }
    if {$cmpdname != ""} {
        foreach i $vTcl(procs) {
            if {[string match ::${cmpdname}::* $i]} {
                lappend proc [list $i [vTcl:proc:get_args $i] [info body $i]]
            }
        }
    }
    set topopt ""
    if {$class == "Toplevel"} {
        foreach i $vTcl(attr,tops) {
            set v [wm $i $target]
            if {$v != ""} {
                lappend topopt [list $i $v]
            }
        }
    }
    lappend ret $class $opts $mgr $bind $menu $chld $name $alias $grid $proc $cmpdname $topopt
    vTcl:append_alias $target $name
    return \{$ret\}
}

proc vTcl:append_alias {name alias} {
    global vTcl
    lappend vTcl(cmp,alias) "$name $alias"
}

proc vTcl:sort_cmd {el1 el2} {
    set l1 [string length [lindex $el1 0]]
    set l2 [string length [lindex $el2 0]]
    return [expr {$l1 - $l2}]
}

proc vTcl:replace {target replace source} {
    set ret ""
    set where [string first $target $source]
    if {$where < 0} {return $source}
    set len [string length $target]
    set before [string range $source 0 [expr {$where - 1}]]
    set after [string range $source [expr {$where + $len}] end]
    return "$before$replace$after"
}

proc vTcl:name_compound {t} {
    global vTcl
    if {$t == "" || ![winfo exists $t]} {return}
    set name [vTcl:get_string "Name Compound" $t]
    if {$name == ""} {return}
    if {[lsearch $vTcl(cmpd,list) $name] < 0} {lappend vTcl(cmpd,list) $name}
    set vTcl(cmpd:$name) [vTcl:create_compound $t $name]
    vTcl:cmp_user_menu
}
