#############################################################################
#
# widget.tcl - procedures for manipulating widget information
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

#
# Given a full widget path, returns a name with "$base" replacing
# the first widget element.
#
proc vTcl:base_name {target} {
    set l [split $target .]
    set name "\$base"
    foreach i [lrange $l 2 end] {
        append name ".$i"
    }
    return $name
}

proc vTcl:properties {target} {
    vTcl:status "Properties not implemented"
}

#
# Given two compatible widgets, sets up a scrollbar
# link (i.e. textfield and scrollbar)
#
proc vTcl:bind_scrollbar {t1 t2} {
    global vTcl
    set c1 [winfo class $t1]
    set c2 [winfo class $t2]
    if { $c1 == "Scrollbar" } {
        set t3 $t1; set t1 $t2; set t2 $t3
        set c3 $c1; set c1 $c2; set c2 $c3
    } elseif { $c2 == "Scrollbar" } {
    } else {
        return
    }
    switch [lindex [$t2 conf -orient] 4] {
        vert -
        vertical { set scr_cmd -yscrollcommand; set v_cmd yview }
        default  { set scr_cmd -xscrollcommand; set v_cmd xview }
    }
    switch $c1 {
        Listbox -
        Canvas -
        Text {
            $t1 conf $scr_cmd "$t2 set"
            $t2 conf -command "$t1 $v_cmd"
        }
        Entry {
            if {$v_cmd == "xview"} {
                $t1 conf $scr_cmd "$t2 set"
                $t2 conf -command "$t1 $v_cmd"
            }
        }
    }
}

#
# Shows a "hidden" object from information stored
# during the hide. Hidden object attributes are
# not currently saved in the project. FIX.
#
proc vTcl:show {target} {
    global vTcl
    if {[vTcl:streq $target "."]} { return }
    if {![winfo viewable $target]} {
        if {[catch {eval $vTcl(hide,$target,m) $target $vTcl(hide,$target,i)}] == 1} {
            catch {$vTcl(w,def_mgr) $target $vTcl($vTcl(w,def_mgr),insert)}
        }
    }
}

#
# Withdraws a widget from display.
#
proc vTcl:hide {} {
    global vTcl
    if {$vTcl(w,manager) != "wm" && $vTcl(w,widget) != ""} {
        lappend vTcl(hide) $vTcl(w,widget)
        set vTcl(hide,$vTcl(w,widget),m) $vTcl(w,manager)
        set vTcl(hide,$vTcl(w,widget),i) [$vTcl(w,manager) info $vTcl(w,widget)]
        $vTcl(w,manager) forget $vTcl(w,widget)
        vTcl:destroy_handles
    }
}

#
# Sets the current widget as the insertion point
# for new widgets.
#
proc vTcl:set_insert {} {
    global vTcl
    set vTcl(w,insert) $vTcl(w,widget)
}

proc vTcl:select_parent {} {
    global vTcl
    vTcl:active_widget [winfo parent $vTcl(w,widget)]
    vTcl:set_insert
}

proc vTcl:select_toplevel {} {
    global vTcl
    vTcl:active_widget [winfo toplevel $vTcl(w,widget)]
    vTcl:set_insert
}

proc vTcl:active_widget {target} {
    global vTcl widgetSelected
    if {$target == ""} {return}
    if {[vTcl:streq $target "."]} { return }
    if {$vTcl(w,widget) != "$target"} {
        vTcl:select_widget $target
        vTcl:attrbar_color $target
        set vTcl(redo) [vTcl:dump_widget_quick $target]
        if {$vTcl(w,class) == "Toplevel"} {
            vTcl:destroy_handles
            set vTcl(w,insert) $target
	    wm deiconify $target
	    raise $target
        } else {
            vTcl:create_handles $target
            vTcl:place_handles $target
            if {$vTcl(w,class) == "Frame" || $vTcl(w,class) == "Canvas"} {
                set vTcl(w,insert) $target
            } else {
                set vTcl(w,insert) [winfo parent $target]
            }
        }
    } elseif {$vTcl(w,class) == "Toplevel"} {
        set vTcl(w,insert) $target
	wm deiconify $target
	raise $target
    }
    set widgetSelected 1
}

proc vTcl:select_widget {target} {
    global vTcl

    if {[vTcl:streq $target "."]} {
	vTcl:prop:clear
    	return
    }

    vTcl:log "vTcl:select_widget $target"
    if {$target == $vTcl(w,widget)} {
        # @@change by Christian Gavin 3/13/2000
        # show selection in widget tree
        vTcl:show_selection_in_tree $target
        # @@end_change
    	return
    }
    set vTcl(w,last_class) $vTcl(w,class)
    set vTcl(w,last_widget) $vTcl(w,widget)
    set vTcl(w,last_manager) $vTcl(w,manager)
    vTcl:update_widget_info $target
    vTcl:prop:update_attr
    vTcl:get_bind $target
    vTcl:add_functions_to_rc_menu

    # @@change by Christian Gavin 3/13/2000
    # show selection in widget tree
    vTcl:show_selection_in_tree $target
    # @@end_change
}

#
# Recurses a widget tree ignoring toplevels
#
proc vTcl:widget_tree {target} {
    global vTcl classes
    if {$target == ".vTcl" || [string range $target 0 4] == ".__tk"} {
        return
    }
    set output "$target "
    set class [winfo class $target]
    set dumpChildren 1
    if {[info exists classes($class,dumpChildren)]} {
    	set dumpChildren $classes($class,dumpChildren)
    }
    if {!$dumpChildren} { return $output }

    set c [vTcl:get_children $target]
    foreach i $c {
        set mgr [winfo manager $i]
        set class [vTcl:get_class $i]
        if {$class != "Toplevel"} {
            append output [vTcl:widget_tree $i]
        }
    }
    return $output
}

#
# Recurses a widget tree with the option of not ignoring built-ins
#
proc vTcl:list_widget_tree {target {which ""}} {
    if {$which == ""} {
        if {$target == ".vTcl" || [string range $target 0 4] == ".__tk"} {
            return
        }
    }
    set w_tree "$target "
    set children [vTcl:get_children $target]
    foreach i $children {

	# don't include temporary windows
	if {[string match {*#*} $i]} {
	    continue
	}

	# Don't include unknown widgets
	set c [vTcl:get_class $i]

	if {![vTcl:valid_class $c]} { continue }

        append w_tree "[vTcl:list_widget_tree $i $which] "
    }
    return $w_tree
}

##############################################################################
# WIDGET INFO ROUTINES
##############################################################################
proc vTcl:split_info {target} {
    global vTcl
    set index 0
    set mgr $vTcl(w,manager)
    set mgr_info [$mgr info $target]
    set vTcl(w,info) $mgr_info
    if { $vTcl(var_update) == "yes" } {
        set index a
        foreach i $mgr_info {
            if { $index == "a" } {
                set var vTcl(w,$mgr,$i)
                set last $i
                set index b
            } else {
                set $var $i
                set index a
            }
        }
    }
    if {$mgr == "grid"} {
        set p [winfo parent $target]
        set pre g
        set gcolumn $vTcl(w,grid,-column)
        set grow $vTcl(w,grid,-row)
        foreach a {column row} {
            foreach b {weight minsize} {
                set num [subst $$pre$a]
                if [catch {
                    set x [expr round([grid ${a}conf $p $num -$b])]
                }] {set x 0}
                set vTcl(w,grid,$a,$b) $x
            }
        }
    }
}

proc vTcl:split_wm_info {target} {
    global vTcl
    set vTcl(w,info) ""
    foreach i $vTcl(attr,tops) {
        if {$i == "geometry"} {
            #
            # because window managers behave unpredictably with wm and
            # winfo, one is used for editing and the other for saving
            #
	    ##
	    # This causes windows to have the wrong geometry.  At least under
	    # my window manager.  Have to look into this further. -D
	    ##
            if {$vTcl(mode) == "EDIT"} {
                # set vTcl(w,wm,$i) [winfo $i $target]
                set vTcl(w,wm,$i) [wm $i $target]
            } else {
                set vTcl(w,wm,$i) [wm $i $target]
            }
        } else {
            set vTcl(w,wm,$i) [wm $i $target]
        }
    }
    set vTcl(w,wm,class) [winfo class $target]
    if { $vTcl(var_update) == "yes" } {
	lassign [vTcl:split_geom $vTcl(w,wm,geometry)] w h x y
        set vTcl(w,wm,geometry,w)    $w
        set vTcl(w,wm,geometry,h)    $h
        set vTcl(w,wm,geometry,x)    $x
        set vTcl(w,wm,geometry,y)    $y
        set vTcl(w,wm,minsize,x)     [lindex $vTcl(w,wm,minsize) 0]
        set vTcl(w,wm,minsize,y)     [lindex $vTcl(w,wm,minsize) 1]
        set vTcl(w,wm,maxsize,x)     [lindex $vTcl(w,wm,maxsize) 0]
        set vTcl(w,wm,maxsize,y)     [lindex $vTcl(w,wm,maxsize) 1]
        set vTcl(w,wm,aspect,minnum) [lindex $vTcl(w,wm,aspect) 0]
        set vTcl(w,wm,aspect,minden) [lindex $vTcl(w,wm,aspect) 1]
        set vTcl(w,wm,aspect,maxnum) [lindex $vTcl(w,wm,aspect) 2]
        set vTcl(w,wm,aspect,maxden) [lindex $vTcl(w,wm,aspect) 3]
        set vTcl(w,wm,resizable,w)   [lindex $vTcl(w,wm,resizable) 0]
        set vTcl(w,wm,resizable,h)   [lindex $vTcl(w,wm,resizable) 1]
    }
}

proc vTcl:get_grid_stickies {sticky} {
    global vTcl
    set len [string length $sticky]
    foreach i {n s e w} {
        set vTcl(grid,sticky,$i) ""
    }
    for {set i 0} {$i < $len} {incr i} {
        set val [string index $sticky $i]
        set vTcl(grid,sticky,$val) $val
    }
}

proc vTcl:update_widget_info {target} {

    vTcl:log "update_widget_info $target"

    global vTcl widget
    update idletasks
    set vTcl(w,widget) $target
    set vTcl(w,didmove) 0
    set vTcl(w,options) ""
    set vTcl(w,optlist) ""
    if {![winfo exists $target]} {return}
    foreach i $vTcl(attr,winfo) {
	if {$i == "manager" && $target == "."} {
	    vTcl:log "target $target manager = [winfo $i $target]"

	    # root placer problem
	    set vTcl(w,$i) wm
	} else {
	    set vTcl(w,$i) [winfo $i $target]
	}
    }
    set vTcl(w,class) [vTcl:get_class $target]
    set vTcl(w,r_class) [winfo class $target]
    set vTcl(w,conf) [$target configure]

    set attrs $vTcl(attr,winfo)
    ##
    # Remove class from the attributes, 'cause we don't want [winfo class]
    # over setting the value we stored from get_class. -Damon
    ##
    lremove attrs class
    switch $vTcl(w,class) {
        Toplevel {
            set vTcl(w,opt,-text) [wm title $target]

	    ##
	    # Set the geometry based on results from [wm geometry] instead of
	    # [winfo geometry].  Remove those attributes from the list of
	    # attributes to setup in the vTcl(w,*) array.
	    ##
	    set remove {geometry height width rootx rooty x y}
	    eval lremove attrs $remove
	    set geometry [wm geometry $target]
	    lassign [vTcl:split_geom $geometry] width height x y
	    set rootx $x
	    set rooty $y
	    foreach var $remove {
	    	set vTcl(w,$var) [set $var]
	    }
        }
        default {
            set vTcl(w,opt,-text) ""
        }
    }

    foreach i $attrs {
        set vTcl(w,$i) [winfo $i $target]
    }

    switch $vTcl(w,manager) {
        {} {}
        grid -
        pack -
        place {
            vTcl:split_info $target
        }
        wm {
            if { $vTcl(w,class) != "Menu" } {
                vTcl:split_wm_info $target
            }
        }
    }
    set vTcl(w,options) [vTcl:conf_to_pairs $vTcl(w,conf) set]
    if {[catch {set vTcl(w,alias) $widget(rev,$target)}]} {
        set vTcl(w,alias) ""
    }
}

proc vTcl:conf_to_pairs {conf opt} {
    global vTcl
    set pairs ""
    foreach i $conf {
        set option [lindex $i 0]
        set def [lindex $i 3]
        set value [lindex $i 4]
        if {$value != $def && $option != "-class"} {
            lappend pairs $option $value
        }
        if {$opt == "set"} {
            lappend vTcl(w,optlist) $option
            set vTcl(w,opt,$option) $value
        }
    }
    return $pairs
}

proc vTcl:new_widget_name {class base} {
    global vTcl
    set c [vTcl:lower_first $class]
    while { 1 } {
        if $vTcl(pr,shortname) {
            set num "[string range $c 0 2]$vTcl(item_num)"
        } else {
            set num "$c$vTcl(item_num)"
        }
        incr vTcl(item_num)
        if {$base != "." && $class != "Toplevel"} {
            set new_widg $base.$num
        } else {
            set new_widg .$num
        }
	if { [lsearch $vTcl(tops) $new_widg] >= 0 } { continue }
        if { ![winfo exists $new_widg] } { break }
    }
    return $new_widg
}

proc vTcl:setup_vTcl:bind {target} {
    global vTcl
    set bindlist [vTcl:list_widget_tree $target all]
    update idletasks
    foreach i $bindlist {
        if { [lsearch [bindtags $target] vTcl(a)] < 0 } {
            set tmp [bindtags $target]
            bindtags $target "vTcl(a) $tmp"
        }
    }
}

proc vTcl:setup_bind {target} {
    global vTcl
    if {[lsearch [bindtags $target] vTcl(b)] < 0} {
        set vTcl(bindtags,$target) [bindtags $target]
        if {[vTcl:get_class $target] == "Toplevel"} {
            wm protocol $target WM_DELETE_WINDOW "vTcl:hide_top $target"
            if {$vTcl(pr,winfocus) == 1} {
                wm protocol $target WM_TAKE_FOCUS "vTcl:wm_take_focus $target"
            }
            bindtags $target "vTcl(bindtags,$target) vTcl(b) vTcl(c)"
        } else {
            bindtags $target vTcl(b)
        }
    }
}

proc vTcl:switch_mode {} {
    global vTcl
    if {$vTcl(mode) == "EDIT"} {
        vTcl:setup_unbind_tree .
    } else {
        vTcl:setup_bind_tree .
    }
}

proc vTcl:setup_bind_tree {target} {
    global vTcl
    set bindlist [vTcl:list_widget_tree $target]
    update idletasks
    foreach i $bindlist {
        vTcl:setup_bind $i
    }
    set vTcl(mode) "EDIT"
}

proc vTcl:setup_unbind {target} {
    global vTcl
    if { [lsearch [bindtags $target] vTcl(b)] >= 0 } {
        bindtags $target $vTcl(bindtags,$target)
    }
}

proc vTcl:setup_unbind_tree {target} {
    global vTcl
    vTcl:select_widget .
    vTcl:destroy_handles
    set bindlist [vTcl:list_widget_tree $target]
    update idletasks
    foreach i $bindlist {
        vTcl:setup_unbind $i
    }
    set vTcl(mode) "TEST"
}

##############################################################################
# INSERT NEW WIDGET ROUTINE
##############################################################################
proc vTcl:auto_place_widget {class {options ""}} {
    global vTcl
    if {$vTcl(mode) == "TEST"} {
        vTcl:error "Inserting widgets is not\nallowed in Test mode."
        return
    }
    if { ($vTcl(w,insert) == "." && $class != "Toplevel") ||
         ([winfo exists $vTcl(w,insert)] == 0 && $class != "Toplevel")} {
        vTcl:dialog "No insertion point set!"
        return
    }
    set vTcl(mgrs,update) no
    if $vTcl(pr,getname) {
        set new_widg [vTcl:get_name $class]
    } else {
        set new_widg [vTcl:new_widget_name $class $vTcl(w,insert)]
    }

    if {[lempty $new_widg]} { return }

    set created_widget [vTcl:create_widget $class $options $new_widg 0 0]

    # @@change by Christian Gavin 3/5/2000
    #
    # when new widget is inserted, automatically refresh
    # widget tree

    # we do not destroy the handles that were just created
    # (remember, the handles are used to grab and move a widget
    # around)

    after idle "\
	    vTcl:init_wtree 0
	    vTcl:show_selection_in_tree $created_widget"
    
    # @@end_change

    return $created_widget
}

proc vTcl:create_widget {class options new_widg x y} {
    global vTcl classes

    set do ""
    set undo ""
    if {$vTcl(pr,getname) == 1} {
        if { $vTcl(w,insert) == "." } {
            set new_widg ".$new_widg"
        } else {
            set new_widg "$vTcl(w,insert).$new_widg"
        }
    }

    set c $class
    append do "$classes($c,createCmd) $new_widg "
    append do "$classes($c,defaultOptions) $options;"

    if {![lempty $classes($c,insertCmd)]} {
	append do "[$classes($c,insertCmd) $new_widg];"
    }
    if {$class != "Toplevel"} {
        append do "$vTcl(w,def_mgr) $new_widg $vTcl($vTcl(w,def_mgr),insert)"
	if {$vTcl(w,def_mgr) == "place"} { append do " -x $x -y $y" }
	append do ";"
    }
    append do "vTcl:setup_bind_tree $new_widg; "
    append do "vTcl:widget:register_widget $new_widg; "
    append do "vTcl:active_widget $new_widg; "
    if {$undo == ""} {
        set undo "destroy $new_widg; vTcl:active_widget [list $vTcl(w,widget)];"
    }
    vTcl:push_action $do $undo
    update idletasks
    set vTcl(mgrs,update) yes

    if {$class == "Toplevel"} {
    	set vTcl(widgets,$new_widg) {}
    } else {
	lappend vTcl(widgets,[winfo toplevel $new_widg]) $new_widg
    }

    if { $vTcl(pr,autoalias) } {
	set alias [vTcl:next_widget_name $c]
	vTcl:set_alias $new_widg $alias
    }

    return $new_widg
}

proc vTcl:set_alias {target {alias ""} {noupdate ""}} {
    global vTcl widget classes

    if {[lempty $target]} { return }

    set c [vTcl:get_class $target]
    set was {}
    if {[lempty $alias]} {
	if {![info exists widget(rev,$target)]} {
	    set alias [vTcl:get_string "Widget alias for $c" $target]
	} else {
	    set was $widget(rev,$target)
	    set alias [vTcl:get_string "Widget alias for $c" $target $was]
	}
    }

    if {![lempty $was]} {
	## Unset the widget variables and delete the alias from the interpreter.
	catch {
	    unset widget($was)
	    unset widget(rev,$target)
	    unset widget(child,$was)
	    interp alias {} $was {} {}
	}
    }

    if {![lempty $alias]} {
        set widget($alias) $target
        set widget(rev,$target) $alias

	# .top38.cpd28 => {} top38 cpd28
	set components [split $target .]

        # {} top38 cpd28 fra21 => cpd28 fra21
	set components [lrange $components 2 end]

        set widget(child,$alias) [join $components .]

	## Create an alias in the interpreter.
	if { $vTcl(pr,cmdalias) } { 
	    interp alias {} $alias {} $classes($c,widgetProc) $target
	}

	# Refresh property manager after changing an alias
	if {[lempty $noupdate]} { vTcl:update_widget_info $target }

	## This is not really necesary.
	# vTcl:prop:update_attr
    }
}

proc vTcl:unset_alias {w} {
    global widget widgetNums

    if {![info exists widget(rev,$w)]} { return }
    set alias $widget(rev,$w)

    catch {
	unset widget($alias)
	unset widget(rev,$w)
	unset widget(child,$alias)
	interp alias {} $alias {} {}
    }

    set class [vTcl:get_class $w]

    ## If the alias is something like Button1, we try to remove its number
    ## from the widgetNums($class) variable.  This lets us re-use aliases
    ## when widgets are deleted.
    if {[regexp "$class\(\[0-9\]+\)" $alias trash num]} {
	lremove widgetNums($class) $num
    }
}

proc vTcl:update_label {t} {
    global vTcl
    if {$t == ""} {return}
    switch [vTcl:get_class $t] {
        Toplevel {
            wm title $t $vTcl(w,opt,-text)
            set vTcl(w,wm,title) $vTcl(w,opt,-text)
        }
        default {
            if [catch {set txt [$t cget -text]}] {
                return
            }
            $t conf -text $vTcl(w,opt,-text)
            vTcl:place_handles $t
        }
    }
}

proc vTcl:set_label {t} {
    global vTcl
    if {$t == ""} {return}
    if [catch {set txt [$t cget -text]}] {
        return
    }
    set label [vTcl:get_string "Setting label" $t $txt]
    $t conf -text $label
    vTcl:place_handles $t
    set vTcl(w,opt,-text) $label
}

proc vTcl:set_textvar {t} {
    global vTcl
    if {$t == ""} {return}
    set label [vTcl:get_string "Setting textvariable" $t [$t cget -textvar]]
    $t conf -textvar $label
    vTcl:place_handles $t
    vTcl:update_widget_info $t
}

proc vTcl:widget_dblclick {target X Y x y} {
    global vTcl classes
    vTcl:set_mouse_coords $X $Y $x $y
    set c [vTcl:get_class $target 1]
    set class [winfo class $target]

    if {![lempty $classes($class,dblClickCmd)]} {
        eval $classes($class,dblClickCmd) $target
    }
}

proc vTcl:pack_after {target} {
if {[winfo manager $target] != "pack" || $target == "."} {return}
    set l [pack slaves [winfo parent $target]]
    set i [lsearch $l $target]
    set n [lindex $l [expr $i + 1]]
    if {$n != ""} {
        pack conf $target -after $n
    }
    vTcl:place_handles $target
}

proc vTcl:pack_before {target} {
if {[winfo manager $target] != "pack" || $target == "."} {return}
    set l [pack slaves [winfo parent $target]]
    set i [lsearch $l $target]
    set n [lindex $l [expr $i - 1]]
    if {$n != ""} {
        pack conf $target -before $n
    }
    vTcl:place_handles $target
}

proc vTcl:manager_update {mgr} {
    global vTcl
    if {$mgr == ""} {return}
    set options ""
    if {$vTcl(w,manager) != "$mgr"} {return}
    update idletasks
    if {$mgr != "wm" } {
        foreach i $vTcl(m,$mgr,list) {
            set value $vTcl(w,$mgr,$i)
            if { $value == "" } { set value {{}} }
            append options "$i $value "
        }
        set vTcl(var_update) "no"
        set undo [vTcl:dump_widget_quick $vTcl(w,widget)]
        set do "$mgr configure $vTcl(w,widget) $options"
        vTcl:push_action $do $undo
        set vTcl(var_update) "yes"
    } else {
        set    vTcl(w,wm,geometry) \
            "$vTcl(w,wm,geometry,w)x$vTcl(w,wm,geometry,h)"
        append vTcl(w,wm,geometry) \
            "+$vTcl(w,wm,geometry,x)+$vTcl(w,wm,geometry,y)"
        set    vTcl(w,wm,minsize) \
            "$vTcl(w,wm,minsize,x) $vTcl(w,wm,minsize,y)"
        set    vTcl(w,wm,maxsize) \
            "$vTcl(w,wm,maxsize,x) $vTcl(w,wm,maxsize,y)"
        set    vTcl(w,wm,aspect) \
            "$vTcl(w,wm,aspect,minnum) $vTcl(w,wm,aspect,minden)"
        append vTcl(w,wm,aspect) \
            "+$vTcl(w,wm,aspect,maxnum)+$vTcl(w,wm,aspect,maxden)"
        set    vTcl(w,wm,resizable) \
            "$vTcl(w,wm,resizable,w) $vTcl(w,wm,resizable,h)"
#            set    do "$mgr geometry $vTcl(w,widget) $vTcl(w,wm,geometry); "
        append do "$mgr minsize $vTcl(w,widget) $vTcl(w,wm,minsize); "
        append do "$mgr maxsize $vTcl(w,widget) $vTcl(w,wm,maxsize); "
        append do "$mgr focusmodel $vTcl(w,widget) $vTcl(w,wm,focusmodel);"
        append do "$mgr resizable $vTcl(w,widget) $vTcl(w,wm,resizable); "
        append do "$mgr title $vTcl(w,widget) \"$vTcl(w,wm,title)\"; "
        switch $vTcl(w,wm,state) {
            withdrawn { append do "$mgr withdraw $vTcl(w,widget); " }
            iconic { append do "$mgr iconify $vTcl(w,widget); " }
            normal { append do "$mgr deiconify $vTcl(w,widget); " }
        }
        eval $do
        vTcl:wm_button_update
    }
    vTcl:place_handles $vTcl(w,widget)
    vTcl:update_top_list
}

# @@change by Christian Gavin 4/16/2000
# proc to insert widget in text editor
# @@end_change

# insert the current widget name (eg. .top30) or alias into
# given text widget

proc vTcl:insert_widget_in_text {t} {
    global vTcl

    if {$vTcl(w,alias) != ""} {
	set name \$widget\($vTcl(w,alias)\)
    } else {
	set name $vTcl(w,widget)
    }

    $t insert insert $name
}

proc vTcl:add_functions_to_rc_menu {} {
    global vTcl classes

    $vTcl(gui,rc_widget_menu) delete 0 end

    set c $vTcl(w,class)
    if {[lempty $classes($c,functionCmds)]} { return }

    foreach cmd $classes($c,functionCmds) text $classes($c,functionText) {
	$vTcl(gui,rc_widget_menu) add command -label $text -command $cmd
    }
}

proc vTcl:new_widget {class button {options ""}} {
    global vTcl classes
    if {$vTcl(mode) == "TEST"} {
        vTcl:error "Inserting widgets is not\nallowed in Test mode."
        return
    }

    vTcl:raise_last_button $button

    if {$vTcl(pr,autoplace) || $class == "Toplevel" \
    	|| $classes($class,autoPlace)} {
	vTcl:status "Status"
	vTcl:rebind_button_1
    	return [vTcl:auto_place_widget $class $options]
    }

    $button configure -relief sunken

    vTcl:status "Insert $class"

    bind vTcl(b) <Button-1> \
    	"vTcl:place_widget $class $button [list $options] %X %Y %x %y"
}

proc vTcl:place_widget {class button options rx ry x y} {
    global vTcl

    if { !$vTcl(pr,multiplace) } {
	$button configure -relief raised
	vTcl:status "Status"
	vTcl:rebind_button_1
    }

    set vTcl(w,insert) [winfo containing $rx $ry]

    set vTcl(mgrs,update) no
    if $vTcl(pr,getname) {
        set new_widg [vTcl:get_name $class]
    } else {
        set new_widg [vTcl:new_widget_name $class $vTcl(w,insert)]
    }

    if {[lempty $new_widg]} { return }

    set created_widget [vTcl:create_widget $class $options $new_widg $x $y]

    # @@change by Christian Gavin 3/5/2000
    #
    # when new widget is inserted, automatically refresh
    # widget tree

    # we do not destroy the handles that were just created
    # (remember, the handles are used to grab and move a widget
    # around)

    after idle "\
	    vTcl:init_wtree 0
	    vTcl:show_selection_in_tree $created_widget"
    
    # @@end_change

    return $created_widget
}

proc vTcl:next_widget_name {class} {
    global widgetNums classes

    set var $class
    if {[info exists classes($class,aliasPrefix)]} {
    	set var $classes($class,aliasPrefix)
    }
    ## Get the next available widget number for this class.
    ## IE: Edit1, Edit2, Edit3...
    if {![info exists widgetNums($var)] || [lempty $widgetNums($var)]} {
    	set widgetNums($var) 0
    }
    set num [lindex [lsort -decreasing -integer $widgetNums($var)] 0]
    incr num
    lappend widgetNums($var) $num
    return $var$num
}

proc vTcl:update_aliases {} {
    global widgetNums widget

    catch {unset widgetNums}

    set aliases [array names widget]
    lremove aliases rev,* child,*

    foreach alias [lsort $aliases] {
	if {![regexp {([a-zA-Z]+)([0-9]+)} $alias trash class num]} { continue }
	if {![vTcl:valid_class $class]} { continue }
	lappend widgetNums($class) $num
    }
}

proc vTcl:widget:get_image {w} {
    global vTcl classes

    set c [vTcl:get_class $w]
    set i $classes($c,icon)
    if {[vTcl:streq [string index $i 0] "@"]} {
    	set i [[string range $i 1 end] $w]
    }
    return $i
}

proc vTcl:widget:get_tree_label {w} {
    global vTcl classes

    set c [vTcl:get_class $w]
    set t $classes($c,treeLabel)
    if {[vTcl:streq [string index $t 0] "@"]} {
    	set t [[string range $t 1 end] $w]
    }
    return $t
}

###
## Register a widget and give it a containing namespace to hold data.
###
proc vTcl:widget:register_widget {w} {
    set opts [$w configure]

    if {![catch {namespace children ::widgets} namespaces]} {
	if {[lsearch $namespaces ::widgets::${w}] > -1} {return}
    }

    namespace eval ::widgets::${w} {
    	variable options
	variable save
	variable defaults
    }

    foreach list $opts {
    	lassign $list opt x x def val
	set ::widgets::${w}::options($opt) $val
	set ::widgets::${w}::defaults($opt) $def
	if {[vTcl:streq $def $val]} {
	    set ::widgets::${w}::save($opt) 0
	} else {
	    set ::widgets::${w}::save($opt) 1
	}
    }
}

###
## Register all unregistered widgets.  This is called when loading a project.
## If the project has widget registry information already stored, the namespace
## for each widget will already exist, and the widget will not be registered.
##
## If there is no registry, one will be created.  This lets us register old
## imported projects that don't contain saved registry information.
###
proc vTcl:widget:register_all_widgets {{w .}} {
    set widgets [vTcl:list_widget_tree $w]
    foreach w $widgets {
	echo $w
    	vTcl:widget:register_widget $w
    }
}
