##############################################################################
#
# edit.tcl - procedures used in cut, copy, and paste
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

proc vTcl:copy {} {
    global vTcl
    set vTcl(buffer) [vTcl:create_compound $vTcl(w,widget)]
    set vTcl(buffer,type) [vTcl:lower_first $vTcl(w,class)]
}

proc vTcl:cut {} {
    global vTcl
    if { $vTcl(w,widget) == "." } { return }

    vTcl:copy
    vTcl:delete
}

proc vTcl:delete {} {
    global vTcl
    if { $vTcl(w,widget) == "." } { return }

    set w $vTcl(w,widget)
    if {[lempty $w]} { return }

    vTcl:destroy_handles

    set top [winfo toplevel $w]
    set children [winfo children $w]
    set parent [winfo parent $vTcl(w,widget)]
    set class [winfo class $w]

    set buffer [vTcl:create_compound $vTcl(w,widget)]
    set do "vTcl:unset_alias $vTcl(w,widget); "
    foreach child $children {
    	append do "vTcl:unset_alias $child; "
    }
    append do "destroy $vTcl(w,widget)"
    set undo "vTcl:insert_compound $vTcl(w,widget) \{$buffer\} $vTcl(w,def_mgr)"
    vTcl:push_action $do $undo

    ## If it's a toplevel window, remove it from the tops list.
    if {$class == "Toplevel"} { lremove vTcl(tops) $w }

    if {![info exists vTcl(widgets,$top)]} { set vTcl(widgets,$top) {} }
    ## Activate the widget created before this one in the widget order.
    set s [lsearch $vTcl(widgets,$top) $w]

    ## Remove the window and all its children from the widget order.
    eval lremove vTcl(widgets,$top) $w $children

    if {$s > 0} {
	set n [lindex $vTcl(widgets,$top) [expr $s - 1]]
    } else {
    	set n [lindex $vTcl(widgets,$top) end]
    }

    if {[lempty $vTcl(widgets,$top)] || ![winfo exists $n]} { set n $parent }

    # @@change by Christian Gavin 3/5/2000
    # automatically refresh widget tree after delete operation
    
    after idle {vTcl:init_wtree}

    # @@end_change

    if {[vTcl:streq $n "."]} {
    	vTcl:prop:clear
	return
    }

    if {[winfo exists $n]} { vTcl:active_widget $n }
}

proc vTcl:paste {{fromMouse ""}} {
    global vTcl

    if {![info exists vTcl(buffer)] || [lempty $vTcl(buffer)]} { return }

    set opts {}
    if {$fromMouse == "-mouse" && $vTcl(w,def_mgr) == "place"} {
    	set opts "-x $vTcl(mouse,x) -y $vTcl(mouse,y)"	
    }

    set name [vTcl:new_widget_name $vTcl(buffer,type) $vTcl(w,insert)]
    set do "
	vTcl:insert_compound $name [list $vTcl(buffer)] $vTcl(w,def_mgr) \
	    [list $opts]
	vTcl:setup_bind_tree $name
    "
    set undo "destroy $name"
    vTcl:push_action $do $undo

    # @@change by Christian Gavin 3/5/2000
    # automatically refresh widget tree after paste operation

    after idle {vTcl:init_wtree}

    # @@end_change

    vTcl:active_widget $name
}
