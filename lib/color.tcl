##############################################################################
#
# color.tcl - color browser
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

proc vTcl:get_color {color} {
    global vTcl tk_version
    set oldcolor $color

    set newcolor [tk_chooseColor -initialcolor $color]
    if {$newcolor != ""} {
        return $newcolor
    } else {
        return $oldcolor
    }
}

proc vTcl:show_color {widget option variable} {
global vTcl
    set vTcl(color,widget)   $widget
    set vTcl(color,option)   $option
    set vTcl(color,variable) $variable
    set color [subst $$variable]
    if {$color == ""} {
        set color "#000000" 
    } elseif {[string range $color 0 0] != "#" } {
        set clist [winfo rgb . $color]
        set r [lindex $clist 0]
        set g [lindex $clist 1]
        set b [lindex $clist 2]
        set color "#[vTcl:hex $r][vTcl:hex $g][vTcl:hex $b]"
    }
    set vTcl(color) [vTcl:get_color $color]
    set $vTcl(color,variable) $vTcl(color)
    $vTcl(color,widget) configure -bg $vTcl(color)
    $vTcl(w,widget) configure $vTcl(color,option) $vTcl(color)
}


