##############################################################################
#
# toolbar.tcl - widget toolbar
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

proc vTcl:toolbar_create {args} {
    global vTcl
    set base .vTcl.toolbar
    if {[winfo exists $base]} {return}
    vTcl:toplevel $base -width 0 -height 0 -class vTcl
    wm transient $base .vTcl
    wm withdraw $base
    wm title $base "Widget Toolbar"
    wm geometry $base +0+110
    wm overrideredirect $base 0
    catch {wm geometry .vTcl.toolbar $vTcl(geometry,.vTcl.toolbar)}
    wm deiconify $base
    update
    wm protocol .vTcl.toolbar WM_DELETE_WINDOW {
        vTcl:error "You cannot remove the toolbar"
    }

    set base .vTcl.toolbar
    set f [vTcl:new_widget_name tb $base]
    image create photo pointer \
        -file [file join $vTcl(VTCL_HOME) images icon_pointer.gif]
    button $f -bd 1 -image pointer -relief sunken -command "
	$f configure -relief sunken
	vTcl:raise_last_button $f
	vTcl:rebind_button_1
	vTcl:status Status
    	set vTcl(x,lastButton) $f
    " -padx 0 -pady 0 -highlightthickness 0
    lappend vTcl(tool,list) $f
    set vTcl(x,lastButton) $f
    set ${base}::resizing 0
    set ${base}::event 0
    bind $base <Configure> "vTcl:toolbar_configure $base"
}

proc vTcl:toolbar_configure {base} {
    set ${base}::resizing 1
    if {![vTcl:at ${base}::event]} {
        set ${base}::event 1
        after 1000 vTcl:toolbar_event $base
    }
}

proc vTcl:toolbar_event {base} {
    # no move for 1 second ?
    if {[vTcl:at ${base}::resizing] == 0} {
        vTcl:toolbar_reflow $base
        after 1000 "set ${base}::event 0"
    } else {
        after 1000 vTcl:toolbar_event $base
    }
    set ${base}::resizing 0
}

proc vTcl:toolbar_add {class name image cmd_add} {
    global vTcl
    set base .vTcl.toolbar
    if {![winfo exists $base]} { vTcl:toolbar_create }
    set f [vTcl:new_widget_name tb $base]
    ensureImage $image
    button $f -bd 1 -image $image -padx 0 -pady 0 -highlightthickness 0

    bind $f <ButtonRelease-1> \
        "vTcl:new_widget \$vTcl(pr,autoplace) $class $f \"$cmd_add\""

    bind $f <Shift-ButtonRelease-1> \
        "vTcl:new_widget 1 $class $f \"$cmd_add\""

    vTcl:set_balloon $f $name
    lappend vTcl(tool,list) $f
}

proc vTclWindow.vTcl.toolbar {args} {
    vTcl:toolbar_reflow
}

proc vTcl:toolbar_reflow {{base .vTcl.toolbar}} {
    global vTcl
    set existed [winfo exists $base]
    if {!$existed} { vTcl:toolbar_create }
    wm resizable $base 1 1
    set num [llength [winfo children $base]]
    switch $::tcl_platform(platform) {
    windows {
        set itemWidth  23
        set itemHeight 23
    }
    default {
        set itemWidth  22
        set itemHeight 22
    }
    }
    set w [expr [winfo width $base] / $itemWidth]
    if {$w == 0} {
        set w $vTcl(toolbar,width)
    }
    set h 0
    set x 0
    set gr ""
    foreach i $vTcl(tool,list) {
        append gr "$i "
        incr x
        if {$x >= $w} {
            if {$existed} {
                eval grid forget $gr
            }
            eval "grid $gr"
            set x 0
            incr h
            set gr ""
        }
    }
    if {$gr != ""} {
        if {$existed} {
            eval grid forget $gr
        }
        eval "grid $gr"
        incr h
    }
    update
    vTcl:setup_vTcl:bind $base
    wm geometry $base [expr $w * $itemWidth]x[expr $h * $itemHeight]
}
