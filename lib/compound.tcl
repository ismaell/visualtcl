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
    set index 0
    set all [vTcl::compounds::enumerateCompounds user]
    set num [llength $all]
    foreach i $all {
        puts $f [vTcl:dump_namespace vTcl::compounds::user::$i]
        incr index
        vTcl:statbar [expr {($index * 100) / $num}]
    }
    close $f
    vTcl:statbar 0
}

proc vTcl:load_compounds {{file ""}} {
    global vTcl

    ## if a file is given in file parameter, use it,
    ## otherwise prompts for a file
    if {$file == ""} {
	    set file [vTcl:get_file open "Load Compound Library"]
    }

    if {$file == ""} {return ""}
    if {![file exists $file]} {return ""}
    vTcl:statbar 10
    source $file
    vTcl:statbar 80
    vTcl:cmp_user_menu
    vTcl:statbar 0

    return $file
}

proc vTcl:name_replace {name s} {
    global vTcl
    foreach i $vTcl(cmp,alias) {
        set s [vTcl:replace [lindex $i 0] $name[lindex $i 1] $s]
    }
    return $s
}

proc vTcl:name_replace_list {name list} {
    global vTcl
    set result ""
    foreach s $list {
        foreach i $vTcl(cmp,alias) {
            set s [vTcl:replace [lindex $i 0] $name[lindex $i 1] $s]
        }
        lappend result $s
    }
    return $result
}

proc vTcl:put_compound {text compound} {
    global vTcl

    set rootclass [lindex [lindex $compound 0] 0]

    if {$vTcl(pr,autoplace) || $rootclass == "Toplevel"} {
	vTcl:auto_place_compound $compound $vTcl(w,def_mgr) {}
	return
    }

    vTcl:status "Insert $text"

    # because the bind commands does % substitution
    regsub -all % $compound %% compound

    bind vTcl(b) <Button-1> \
    	"vTcl:store_cursor %W
         vTcl:place_compound [list $compound] $vTcl(w,def_mgr) %X %Y %x %y"
}

proc vTcl:auto_place_compound {compound gmgr gopt} {
    global vTcl

    set rootclass [lindex [lindex $compound 0] 0]
    if {$rootclass == "Toplevel"} {
        set class $rootclass
    } else {
        set class cpd
    }

    set name [vTcl:new_widget_name $class $vTcl(w,insert)]

    vTcl:insert_compound $name $compound $gmgr $gopt
    vTcl:setup_bind_tree $name
    vTcl:active_widget $name
    vTcl:update_proc_list

    # when new compound inserted into window, automatically
    # refresh widget tree

    vTcl:init_wtree
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
    set childsiteproc ""
    foreach i $compound {
        set class [string trim [lindex $i 0]]
        set opts  [string trim [lindex $i 1]]
        set mgr   [string trim [lindex $i 2]]
        set mgrt  [string trim [lindex $mgr 0]]
        set mgri  [string trim [lindex $mgr 1]]
        set bind  [string trim [lindex $i 3]]
        set menu  [string trim [lindex $i 4]]
        set chld  [string trim [lindex $i 5]]
        set wdgt  [string trim [lindex $i 6]]
        set alis  [string trim [lindex $i 7]]
        set grid  [string trim [lindex $i 8]]
        set proc  [string trim [lindex $i 9]]
        set cmpdname [string trim [lindex $i 10]]
        set topopt   [string trim [lindex $i 11]]

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

            ## there is a special procedure to paste a megawidget
            if {[string match __insert* $nme]} {
                set childsiteproc $nme
            } else {
                vTcl:list add "{$nme}" vTcl(procs)
            }
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

        ## for megawidgets, we insert the compound into an already existing
        ## frame, so if the base already exists, we skip it and insert children

        set was_existing  [winfo exists $name]
        if {!$was_existing} {
            set replaced_opts [vTcl:name_replace $base $opts]
            append todo "$classes($class,createCmd) $name $replaced_opts; "
        }
        if {$mgrt != "" && $mgrt != "wm"} {
            if {$mgrt == "place" && $mgri == ""} {
                set mgri "-x 5 -y 5"
            }
            if {!$was_existing} {
                append todo "$mgrt $name [vTcl:name_replace $base $mgri]; "
            }
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

        ## megawidget childsites
        if {$childsiteproc != ""} {
            append todo "$childsiteproc $name; "
            append toto "rename $childsiteproc {}; "
        }

        if {!$was_existing} {

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

            ## bindings
            foreach j $bind {
                # see if it is a list of bindtags, a binding for
                # the target, or a binding for a bindtag (ya follow me?)
                switch -exact -- [llength $j] {
                1 {
                    append todo "bindtags $name \[vTcl:unnormalize_bindtags $name [vTcl:name_replace $base $j]\];"
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
        }; ## if {!$was_existing} ...
        incr level
	if {$classes($class,dumpChildren)} {
	    foreach j $chld {
	       append todo "[vTcl:extract_compound $base $name \{$j\} $level]; "
	    }
	}
        if {!$was_existing} {
            if {$alis != ""} {
                append todo "vTcl:set_alias $name \[vTcl:next_widget_name $class $name $alis\] -noupdate; "
            } elseif {$alis == "" && $vTcl(pr,autoalias)} {
                append todo "vTcl:set_alias $name \[vTcl:next_widget_name $class $name\] -noupdate; "
            }
        }; ## if {!$was_existing} ...

        foreach j $grid {
            set cmd  [lindex $j 0]
            set num  [lindex $j 1]
            set prop [lindex $j 2]
            set val  [lindex $j 3]
            append todo "grid $cmd $name $num $prop $val; "
        }

        if {[lsearch -exact $vTcl(procs) "::${cmpdname}::main"] >= 0 } {
	    append todo "[list ::${cmpdname}::main] $name"
        }
    }

    return $todo
}

# in a list of bindtags, replace a toplevel bindtag by %top
# for example:
#    target   = ".top18.cpd19"
#    bindtags = "Frame .top18.cpd19 .top18 all"
# =>
#    returns    "Frame .top18.cpd19 %top all"

proc vTcl:normalize_bindtags {target bindtags} {

    set result ""
    foreach bindtag $bindtags {
        if {[winfo exists $bindtag] &&
            $bindtag == [winfo toplevel $target]} {
            lappend result %top
        } else {
            lappend result $bindtag
        }
    }

    return $result
}

# in a list of bindtags, replace %top by the toplevel of
# the given target, for example:
#    target = .top19.cpd20
#    bindtags = "Frame .top18.cpd19 %top all"
# =>
#    returns    "Frame .top18.cpd19 .top19 all"

proc vTcl:unnormalize_bindtags {target bindtags} {

    set result ""
    foreach bindtag $bindtags {
        if {$bindtag == "%top"} {
            lappend result [winfo toplevel $target]
        } else {
            lappend result $bindtag
        }
    }

    return $result
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

    ## selection of list of procs to include
    set proposedProcs ""
    foreach item $vTcl(procs) {
        if {[vTcl:valid_procname $item]} {
            lappend proposedProcs $item
        }
    }

    set includedProcs [::vTcl::input::listboxSelect::select \
        $proposedProcs "Select Code for Compound" extended]

    eval [vTcl::compounds::createCompound $t user $name $includedProcs]
    vTcl:cmp_user_menu
}

##########################################################################
## New Compound Widgets Technology Here

namespace eval ::vTcl::compounds {

    namespace eval system    {}
    namespace eval user      {}
    namespace eval clipboard {}

    proc createCompound {target type compoundName \
                        {procs {}} {initCmd {}} {mainCmd {}}} {

        ## we don't want handles to be enumerated with the widget
        vTcl:destroy_handles

        set output ""
        append output "namespace eval \{::vTcl::compounds::${type}::[list $compoundName]\} \{\n"

        ## basic compound information
        set class [vTcl:get_class $target]
        append output "\nset class $class\n"
        append output "\nset source $target\n\n"

        ## append of version of vTcl:DefineAlias that is local to this namespace
        append output "\n"
        append output "proc vTcl:DefineAlias \{target alias args\} \{\n"
        append output "    if \{!\[info exists ::vTcl(running)\]\} \{\n"
        append output "        return \[eval ::vTcl:DefineAlias \$target \$alias \$args\]\n"
        append output "    \}\n"
        append output "    set class \[vTcl:get_class \$target\]\n"
        append output "    vTcl:set_alias \$target \[vTcl:next_widget_name \$class \$target \$alias\] -noupdate\n"
        append output "\}\n"
        append output "\n"

        set ::vTcl(num,index) 0
	  set ::vTcl(num,total) [llength [vTcl:list_widget_tree $target]]

        ## in addition, each toplevel has its own procedure
        if {$class == "Toplevel"} {
            append output [vTcl::widgets::core::toplevel::dumpTop $target]
            append output "\n"
        }

        ## code to actually create the compound
        append output "proc compoundCmd \{target\} \{\n"
        if {$initCmd != ""} {
            append output "    $initCmd \$target\n\n"
        }
        if {$class == "Toplevel"} {
            append output "    vTclWindow$target \$target\n"
        } else {
            append output "    set items \[split \$target .\]\n"
            append output "    set parent \[join \[lrange \$items 0 end-1\] .\]\n"
            append output "    set top \[winfo toplevel \$parent\]\n"
            append output "[$::classes($class,dumpCmd) $target \$target]\n"
        }
        if {$mainCmd != ""} {
            append output "    $mainCmd \$target\n"
        }
        append output "\}\n\n"

        ## remembers which options to save/not save
        append output "proc infoCmd \{target\} \{\n"
        append output "[$::classes($class,dumpInfoCmd) $target \$target]\n"
        append output "\}\n"

        ## optional list of procs to include with the compound
        if {![lempty $procs]} {
            append output "\nset procs \{\n"
            foreach procname $procs {
                append output "    $procname\n"
            }
            append output "\}\n"

            append output "\nproc procsCmd \{\} \{\n"
            foreach procname $procs {
                append output "[vTcl:dump_proc $procname]\n"
            }
            append output "\}\n"
        } else {
            append output "\nset procs \{\}\n"
            append output "\nproc procsCmd \{\} \{\}\n\n"
        }

        ## enumerate all the binding tags used
        set children [vTcl:complete_widget_tree $target 0]
        set used_tags ""
        set all_tags $::widgets_bindings::tagslist
        foreach child $children {
            # now, are bindtags non-standard ?
            set bindtags $::vTcl(bindtags,$child)
            if {$bindtags != [::widgets_bindings::get_standard_bindtags $child] } {
                foreach bindtag $bindtags {
                    if {[lsearch -exact $all_tags $bindtag] >= 0} {
                        lappend used_tags $bindtag
                    }
                }
            }
        }

        ## optional list of bindtags to include with the compound
        if {![lempty $used_tags]} {
            set used_tags [vTcl:lrmdups $used_tags]
            append output "\nset bindtags \{\n"
            foreach used_tag $used_tags {
                append output "    $used_tag\n"
            }
            append output "\}\n\n"

            append output "\nproc bindtagsCmd \{\} \{\n"
            foreach used_tag $used_tags {
                append output {#############################################################################}
                append output "\n\#\# Binding tag:  $used_tag\n\n"
                set bindlist [lsort [bind $used_tag]]
                foreach event $bindlist {
                   set command [bind $used_tag $event]
                   append output "bind \"$used_tag\" $event \{\n"
                   append output "$::vTcl(tab)[string trim $command]\n\}\n"
                }
            }
            append output "\}\n"
            append output "\n"
        } else {
            append output "\nset bindtags \{\}\n"
            append output "\nproc bindtagsCmd \{\} \{\}\n\n"
        }

        ## closing brace of namespace statement
        append output "\}\n"

        ## we can put the handles back
        vTcl:place_handles $::vTcl(w,widget)

        return $output
    }

    proc mergeCompoundCode {type compoundName {mergeCode 0}} {
        set spc ${type}::[list $compoundName]
        if {![lempty [vTcl:at ${spc}::procs]]} {
            ${spc}::procsCmd
            if {$mergeCode} {
                set ::vTcl(procs) [concat $::vTcl(procs) [vTcl:at ${spc}::procs]]
                set ::vTcl(procs) [vTcl:lrmdups $::vTcl(procs)]
                vTcl:update_proc_list
            }
        }

        if {![lempty [vTcl:at ${spc}::bindtags]]} {
            ${spc}::bindtagsCmd
            if {$mergeCode} {
                foreach tag [vTcl:at ${spc}::bindtags] {
                    ::widgets_bindings::add_tag_to_tagslist $tag
                }
            }
        }
    }

    ## type should be "system" (predefined compounds) or "user"
    proc enumerateCompounds {type} {
        if {$type != "system" && $type != "user" && $type != "clipboard"} {
            return ""
        }

        set list [namespace children ${type}]
        regsub -all :: $list : list
        set result ""
        foreach item $list {
            lappend result [lindex [split $item :] end]
        }
        return $result
    }

    ## inserts a compound
    proc putCompound {type compoundName} {
        set spc ${type}::[list $compoundName]
        set rootclass [vTcl:at ${spc}::class]

        if {$::vTcl(pr,autoplace) || $rootclass == "Toplevel"} {
            autoPlaceCompound $type $compoundName wm {}
            return
        }

        vTcl:status "Insert [join $compoundName]"

        bind vTcl(b) <Button-1> \
            "vTcl:store_cursor %W
             vTcl::compounds::placeCompound $type [list $compoundName] $::vTcl(w,def_mgr) %X %Y %x %y"
    }

    ## auto place a compound at insertion point
    proc autoPlaceCompound {type compoundName gmgr gopt} {
        set spc ${type}::[list $compoundName]
        set rootclass [vTcl:at ${spc}::class]

        if {$rootclass == "Toplevel"} {
            set namePrefix $rootclass
        } else {
            set namePrefix cpd
        }

        set target [vTcl:new_widget_name $namePrefix $::vTcl(w,insert)]

        insertCompound $target $type $compoundName $gmgr $gopt
        vTcl:init_wtree
        vTcl:active_widget $target
    }

    proc insertCompound {target type compoundName {gmgr pack} {gopt ""}} {
        set spc ${type}::[list $compoundName]
        set cmd ""
        append cmd "vTcl::compounds::mergeCompoundCode $type [list $compoundName] 1"
        append cmd "; [list vTcl::compounds::${spc}::compoundCmd] $target"
        append cmd "; [list vTcl::compounds::${spc}::infoCmd] $target"
        if {$gmgr != "wm"} {
            append cmd "; eval $gmgr $target $gopt"
        } else {
            append cmd "; lappend ::vTcl(tops) $target"
            append cmd "; vTcl:update_top_list"
        }
        append cmd "; vTcl:setup_bind_tree $target"
        append cmd "; vTcl:widget:register_all_widgets $target"
           
        set do "$cmd"
        set undo "destroy $target"
        vTcl:push_action $do $undo
        lappend ::vTcl(widgets,[winfo toplevel $target]) $target
    }

    proc insertCompoundDirect {target type compoundName {gmgr pack} {gopt ""}} {
        set spc ${type}::[list $compoundName]
        vTcl::compounds::mergeCompoundCode $type $compoundName 1
        vTcl::compounds::${spc}::compoundCmd $target
        vTcl::compounds::${spc}::infoCmd $target
        if {[vTcl:at ${spc}::class] == "Toplevel"} {
            set gmgr wm
            set gopt ""
        }
        if {$gmgr != "wm"} {
            eval $gmgr $target $gopt
        } else {
            lappend ::vTcl(tops) $target
            vTcl:update_top_list
        }
        vTcl:setup_bind_tree $target
        vTcl:widget:register_all_widgets $target        
        lappend ::vTcl(widgets,[winfo toplevel $target]) $target
    }

    proc placeCompound {type compoundName gmgr rx ry x y} {
        vTcl:status Status
        vTcl:rebind_button_1

        set ::vTcl(w,insert) [winfo containing $rx $ry]

        set gopt {}
        if {$gmgr == "place"} {
             append gopt "-x $x -y $y"
        }

        autoPlaceCompound $type $compoundName $gmgr $gopt
    }

    proc getClass {type compoundName} {
        set spc ${type}::[list $compoundName]
        return [vTcl:at ${spc}::class]
    }

    proc deleteCompound {type compoundName} {
        set spc ${type}::[list $compoundName]

        set procs [set ${spc}::procs]
        foreach procName $procs {
            if {[info procs $procName] == "$procName"} {
                rename $procName {}
            }
        }

        set tags [set ${spc}::bindtags]
        foreach tag $tags {
            foreach event [bind $tag] {
                bind $tag $event ""
            }
        }

        namespace delete $spc
    }
}

