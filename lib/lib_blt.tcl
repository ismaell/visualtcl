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

proc vTcl:widget:lib:lib_blt {args} {
    global vTcl

    catch {package require foobar}
    set names [string tolower [package names]]

    if {[lsearch -exact $names blt] == -1} {

        lappend vTcl(libNames) {(not detected) BLT Widgets Support Library}
        return

    } else {

        package require BLT
        namespace import blt::vector
        namespace import blt::graph
        namespace import blt::hierbox
        namespace import blt::stripchart
    }

    # announce ourselves!
    lappend vTcl(libNames) {BLT Widgets Support Library}

    set order { Graph Hierbox Stripchart }

    vTcl:lib:add_widgets_to_toolbar $order

    append vTcl(head,importheader) {

        # provoke name search
        catch {package require foobar}
        set names [package names]

        # check if BLT is available
        if { [lsearch -exact $names BLT] != -1} {

            package require BLT
            namespace import blt::vector
            namespace import blt::graph
            namespace import blt::hierbox
            namespace import blt::stripchart
        }
    }
}
