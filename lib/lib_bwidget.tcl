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

proc vTcl:lib_bwidget:init {} {
    global vTcl

    if {[catch {package require BWidget}]} {
	lappend vTcl(libNames) "(not detected) BWidget Widget Support Library"
	return 0
    }
    lappend vTcl(libNames) "BWidget Widget Library"
    return 1
}

proc vTcl:widget:lib:lib_bwidget {args} {
    global vTcl

    set order {
	ArrowButton
	NoteBook
	ProgressBar
	ScrollView
	Separator
	Tree
    }

    vTcl:lib:add_widgets_to_toolbar $order

    append vTcl(head,bwidget,importheader) {
    if {[lsearch -exact $packageNames Bwidget] > -1} {
	package require Bwidget
    }
    }
}
