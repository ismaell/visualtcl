##############################################################################
#
# lib_blt.tcl - blt widget support library
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
# Architecture by Stewart Allen
# Implementation by James Kramer usinge ideas from
# Kenneth H. Cox <kcox@senteinc.com>

proc vTcl:lib_blt:init {} {
    global vTcl

    if {[catch {package require BLT} error]} {
        lappend vTcl(libNames) {(not detected) BLT Widgets Support Library}
	return 0
    }
    lappend vTcl(libNames) {BLT Widgets Support Library}
    return 1
}

proc vTcl:widget:lib:lib_blt {args} {
    global vTcl

    set order {
	Graph
	Hierbox
	Stripchart
    }

    vTcl:lib:add_widgets_to_toolbar $order

    append vTcl(head,blt,importheader) {
    # BLT is needed
    package require BLT
    }
}
