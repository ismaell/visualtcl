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
proc vTcl:widget:lib:lib_core {args} {
    global vTcl widgets classes

    lappend vTcl(libNames) "Tcl/Tk Core Widget Library"

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
	Spinbox
    } 

    vTcl:lib:add_widgets_to_toolbar $order
}

####################################################################
# Procedure to support extra geometry mgr configuration
#

proc vTcl:grid:conf_ext {target var value} {
    global vTcl
    set parent [winfo parent $target]
    grid columnconf $parent $vTcl(w,grid,-column) -weight  $vTcl(w,grid,column,weight)
    grid columnconf $parent $vTcl(w,grid,-column) -minsize $vTcl(w,grid,column,minsize)
    grid rowconf    $parent $vTcl(w,grid,-row)    -weight  $vTcl(w,grid,row,weight)
    grid rowconf    $parent $vTcl(w,grid,-row)    -minsize $vTcl(w,grid,row,minsize)
}

proc vTcl:wm:conf_geom {target var value} {
    global vTcl
    set x $vTcl(w,wm,geometry,x)
    set y $vTcl(w,wm,geometry,y)
    set w $vTcl(w,wm,geometry,w)
    set h $vTcl(w,wm,geometry,h)
    wm geometry $target ${w}x${h}+${x}+${y}
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
    wm $vTcl(w,wm,state) $target
}

proc vTcl:wm:conf_title {target var value} {
    global vTcl
    wm title $target "$vTcl(w,wm,title)"
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

proc vTcl:core:get_menu_label {class {target ""}} {

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

	if [regexp {((\.[a-zA-Z0-9]+)+)} $value matchAll path] {

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

set vTcl(option,translate,-command) vTcl:core:scrollviewtranslate
set vTcl(option,noencase,-command) 1

set vTcl(option,noencasewhen,-command) vTcl:core:noencasewhenscroll

proc vTcl:core:scrolltranslate {value} {

	global vTcl

	if [regexp {((\.[a-zA-Z0-9]+)+) set} $value matchAll path] {

               	set path [vTcl:base_name $path]

		return "\"$path set\""
	}

      	return $value
}

proc vTcl:core:scrollviewtranslate {value} {

	global vTcl

	if [regexp {((\.[a-zA-Z0-9]+)+) xview} $value matchAll path] {

               	set path [vTcl:base_name $path]

		return "\"$path xview\""
	} else {

		if [regexp {((\.[a-zA-Z0-9]+)+) yview} $value matchAll path] {

        	       	set path [vTcl:base_name $path]

			return "\"$path yview\""
		}
	}

      	return $value
}

proc vTcl:core:noencasewhen {value} {

	return [string match {"$base*} $value]
}

proc vTcl:core:noencasewhenscroll {value} {

	if { [string match {"$base*xview"} $value] ||
             [string match {"$base*yview"} $value] } {
		return 1
	} else {
		return 0
	}
}




