##############################################################################
#
# lib_core.tcl - core tcl/tk widget support library
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

#
# initializes this library
#
proc vTcl:lib_core:init {} {
    global vTcl

    lappend vTcl(libNames) "Tcl/Tk Core Widget Library"
    return 1
}

proc vTcl:widget:lib:lib_core {args} {
    global vTcl

    set order {
    	Toplevel
	Message
	Frame
	Canvas
	Button
	Entry
	Label
	Listbox
	Text
	Checkbutton
	Radiobutton
	Scrollbar
	Scale
	Menubutton
    } 

    if {[info tclversion] >= 8.4} {
	lappend order Spinbox
    }

    vTcl:lib:add_widgets_to_toolbar $order

    append vTcl(head,core,importheader) {
    switch $tcl_platform(platform) {
	windows {
	}
	default {
	    option add *Scrollbar.width 10
	}
    }
    }
}

####################################################################
# Tooltip support
#

proc vTcl:get_balloon {target} {
    set events [bind $target]
    if {[lsearch -exact $events <<SetBalloon>>] == -1} {
        return ""
    }
    set event [string trim [bind $target <<SetBalloon>>]]
    if {[string match {set ::vTcl::balloon::%W*} $event]} {
        return [lindex $event 2]
    }
    return ""
}

proc vTcl:update_balloon {target var} {
    set ::$var [vTcl:get_balloon $target]
}

proc vTcl:config_balloon {target var} {
    set old [vTcl:get_balloon $target]
    set new [vTcl:at ::$var]
    if {$old == "" && $new == ""} {
        return
    }
    if {$old != "" && $new == ""} {
        bind $target <<SetBalloon>> {}
        ::widgets_bindings::remove_tag_from_widget $target _vTclBalloon
    } else {
        bind $target <<SetBalloon>> "set ::vTcl::balloon::%W \{$new\}"
        ::widgets_bindings::add_tag_to_widget $target _vTclBalloon
        ::widgets_bindings::add_tag_to_tagslist _vTclBalloon
    }

    ## if the bindings editor is there, refresh it
    if {[winfo exists .vTcl.bind]} {
        ::widgets_bindings::save_current_binding
        vTcl:get_bind $target
    }
}

####################################################################
# Procedures to support extra geometry mgr configuration
#

proc vTcl:grid:conf_ext {target var value} {
    global vTcl
    set parent [winfo parent $target]
    grid columnconf $parent $vTcl(w,grid,-column) -weight  $vTcl(w,grid,column,weight)
    grid columnconf $parent $vTcl(w,grid,-column) -minsize $vTcl(w,grid,column,minsize)
    grid rowconf    $parent $vTcl(w,grid,-row)    -weight  $vTcl(w,grid,row,weight)
    grid rowconf    $parent $vTcl(w,grid,-row)    -minsize $vTcl(w,grid,row,minsize)
    # Both required for better compatibilty!
    grid propagate  $target $vTcl(w,grid,propagate)
    pack propagate  $target $vTcl(w,grid,propagate)
}

proc vTcl:pack:conf_ext {target var value} {
    global vTcl
    # Both required for better compatibilty!
    pack propagate  $target $vTcl(w,pack,propagate)
    grid propagate  $target $vTcl(w,pack,propagate)
}

proc vTcl:wm:enable_geom {} {
    global vTcl
    # Enable/disable UI elements
    array set state {0 disabled 1 normal}
    set origin_state $state($vTcl(w,wm,set,origin))
    set size_state   $state($vTcl(w,wm,set,size))

    vTcl:prop:enable_manager_entry geometry,x $origin_state
    vTcl:prop:enable_manager_entry geometry,y $origin_state
    vTcl:prop:enable_manager_entry geometry,w $size_state
    vTcl:prop:enable_manager_entry geometry,h $size_state
}

proc vTcl:wm:conf_geom {target var value} {
    global vTcl
    set ::widgets::${target}::set,origin $vTcl(w,wm,set,origin)
    set ::widgets::${target}::set,size   $vTcl(w,wm,set,size)
    set x $vTcl(w,wm,geometry,x)
    set y $vTcl(w,wm,geometry,y)
    set w $vTcl(w,wm,geometry,w)
    set h $vTcl(w,wm,geometry,h)
    wm geometry $target ${w}x${h}+${x}+${y}
    vTcl:wm:enable_geom
}

proc vTcl:wm:conf_resize {target var value} {
    global vTcl
    set w $vTcl(w,wm,resizable,w)
    set h $vTcl(w,wm,resizable,h)
    wm resizable $target $w $h
}

proc vTcl:wm:conf_minmax {target var value} {
    global vTcl
    set min_x $vTcl(w,wm,minsize,x)
    set min_y $vTcl(w,wm,minsize,y)
    set max_x $vTcl(w,wm,maxsize,x)
    set max_y $vTcl(w,wm,maxsize,y)
    wm minsize $target $min_x $min_y
    wm maxsize $target $max_x $max_y
}

proc vTcl:wm:conf_state {target var value} {
    global vTcl
    catch {wm $vTcl(w,wm,state) $target}
}

proc vTcl:wm:conf_title {target var value} {
    global vTcl
    wm title $target "$vTcl(w,wm,title)"
}

proc vTcl:wm:dump_info {target} {
    global vTcl
    set out ""
    foreach wm_option $vTcl(m,wm,savelist) {
        if {[info exists ::widgets::${target}::${wm_option}]} {
            append out $vTcl(tab2)
            append out "set $wm_option [vTcl:at ::widgets::${target}::${wm_option}]\n"
        }
    }
    return $out
}

####################################################################
# Procedures to support "double-click" action on widets
# There are mostly procedures to support the special case of menus
#

proc vTcl:edit_target_menu {target} {
    global vTcl
    if [catch {set menu [$target cget -menu]}] {
        return
    }
    if {$menu == ""} {
        set menu [vTcl:new_widget_name m $target]
        menu $menu
        vTcl:widget:register_widget $menu -tearoff
        vTcl:setup_vTcl:bind $menu
        $target conf -menu $menu
        foreach def {-activebackground -activeforeground
                     -background -foreground} {
            vTcl:prop:default_opt $menu $def vTcl(w,opt,$def)
        }
    }

    set name [vTcl:rename $menu]
    set base ".vTcl.menu_$name"

    vTclWindow.vTclMenuEdit $base $menu
}

proc vTcl:edit_menu {menu} {
    set name [vTcl:rename $menu]
    set base ".vTcl.menu_$name"

    vTclWindow.vTclMenuEdit $base $menu
}

proc vTcl:core:get_menu_label {target} {

    set components [split $target .]

    # let's see if the parent is a menu
    set size [llength $components]

    # parent is at least a toplevel
    if {$size <= 3} {
        return "Menu"
    }

    set parent [lrange $components 0 [expr $size - 2] ]
    set parent [join $parent .]

    # puts "parent is $parent"
    if { [vTcl:get_class $parent 1] != "menu" } {
        return "Menu"
    }

    for {set i 0} {$i <= [$parent index end]} {incr i} {

        if { [$parent type $i] != "cascade" } {
            continue
        }

        set menuwindow [$parent entrycget $i -menu]

        if {$menuwindow == $target} {

            return [$parent entrycget $i -label]
        }
    }

    return "Menu"
}

proc vTcl:core:get_widget_tree_label {target} {
    set t ""

    set class [vTcl:get_class $target]

    switch [string tolower $class] {
	toplevel { set t [wm title $target] }
	label {
	    set ttt1 [$target cget -text]
	    set ttt2 [$target cget -textvariable]

	    if {$ttt2 == ""} {
		set t "LAB: $ttt1"
	    } else {
		set t "LAB: $ttt1 var=$ttt2"
	    }
	}

	radiobutton {
	    set ttt1 [$target cget -text]
	    set ttt2 [$target cget -variable]
	    set ttt3 [$target cget -value]

	    if {$ttt2 == ""} {
		set t "RB: $ttt1"
	    } else {
		set t "RB: $ttt1 var=$ttt2\(val=$ttt3\)"
	    }
	}

	checkbutton {
	    set ttt1 [$target cget -text]
	    set ttt2 [$target cget -variable]
	    set ttt3 [$target cget -onvalue]
	    set ttt4 [$target cget -offvalue]

	    if {$ttt2 == ""} {
		set t "CB: $ttt1"
	    } else {
		set t "CB: $ttt1 var=$ttt2\(on=$ttt3,off=$ttt4\)"
	    }
	}

	button {
	    set ttt1 [$target cget -text]
	    set ttt2 [$target cget -textvariable]

	    if {$ttt2 == ""} {
		set t "BUT: $ttt1"
	    } else {
		set t "BUT: $ttt1 var=$ttt2"
	    }
	}

	entry {
	    set val [$target cget -textvariable]
	    if {[lempty $val]} { set val NONE }
	    set t "VAR: $val"
	}

	message    -
	menubutton { set t [$target cget -text] }
    }

    return $t
}

# translation for options when saving files

set vTcl(option,translate,-menu) vTcl:core:menutranslate
set vTcl(option,noencase,-menu) 1
set vTcl(option,noencasewhen,-menu) vTcl:core:noencasewhen

proc vTcl:core:menutranslate {value} {

	global vTcl

	if [regexp {((\.[a-zA-Z0-9_]+)+)} $value matchAll path] {

		if {$matchAll == $value} {

	               	set path [vTcl:base_name $path]

			return "\"$path\""
		}
	}

      	return $value
}

set vTcl(option,translate,-xscrollcommand) vTcl:core:scrolltranslate
set vTcl(option,noencase,-xscrollcommand) 1

set vTcl(option,translate,-yscrollcommand) vTcl:core:scrolltranslate
set vTcl(option,noencase,-yscrollcommand) 1

set vTcl(option,noencasewhen,-xscrollcommand) vTcl:core:noencasewhen
set vTcl(option,noencasewhen,-yscrollcommand) vTcl:core:noencasewhen

set vTcl(option,translate,-command) vTcl:core:commandtranslate
set vTcl(option,noencase,-command) 1
set vTcl(option,noencasewhen,-command) vTcl:core:noencasecommandwhen

set vTcl(option,translate,-variable) vTcl:core:variabletranslate
set vTcl(option,noencase,-variable) 1
set vTcl(option,noencasewhen,-variable) vTcl:core:noencasewhen

set vTcl(option,translate,-textvariable) vTcl:core:variabletranslate
set vTcl(option,noencase,-textvariable) 1
set vTcl(option,noencasewhen,-textvariable) vTcl:core:noencasewhen

proc vTcl:core:variabletranslate {value} {

        global vTcl

	if {[regexp {(\.[\.a-zA-Z0-9_]+)::(.*)} $value matchAll path variable]} {

            ## potential candidate, is it a window ?
            if {![winfo exists $path]} {return $value}

            set path [vTcl:base_name $path]
            return "\"${path}\\::${variable}\""
        }

        return $value
}

proc vTcl:core:scrolltranslate {value} {

	global vTcl

	if [regexp {((\.[a-zA-Z0-9_]+)+) set} $value matchAll path] {

               	set path [vTcl:base_name $path]

		return "\"$path set\""
	}

      	return $value
}

proc vTcl:core:commandtranslate {value} {

    global vTcl

    if {[regexp {(\.[\.a-zA-Z0-9_]+) (x|y)view} $value matchAll path axis]} {

       	set path [vTcl:base_name $path]

	return "\"$path ${axis}view\""

    } elseif {[regexp {vTcl:DoCmdOption (\.[\.a-zA-Z0-9_]+) (.*)} $value matchAll path cmd]} {

        set path [vTcl:base_name $path]

        return "\[list vTcl:DoCmdOption $path $cmd\]"
    }

    return $value
}

proc vTcl:core:noencasewhen {value} {

    if { [string match {"$base*} $value] ||
         [string match {"$site*} $value] } {
        return 1
    }

    return 0
}

proc vTcl:core:noencasecommandwhen {value} {

	if { [string match {"$base*?view"} $value] ||
             [string match {"$site*?view"} $value] ||
             [string match {\[list vTcl:DoCmdOption $base*} $value] } {
		return 1
	} else {
		return 0
	}
}

proc vTcl:core:set_option {target option description} {

    global vTcl

    set value [$target cget $option]
    set newvalue [vTcl:get_string $description $target $value]

    if {! [vTcl:streq $value $newvalue]} {
        $target configure $option $newvalue

        # we better save that option, too
        set vTcl(w,opt,$option) $newvalue
        vTcl:prop:save_opt $target $option vTcl(w,opt,$option)

        # keep showing the selection in the toplevel
        # (do not destroy the selection handles)
        vTcl:init_wtree 0
    }
}
