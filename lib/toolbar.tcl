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

    ScrolledWindow .vTcl.toolbar.sw
    ScrollableFrame .vTcl.toolbar.sw.sf
    .vTcl.toolbar.sw setwidget .vTcl.toolbar.sw.sf
    pack .vTcl.toolbar.sw -side top -fill both -expand 1
    pack .vTcl.toolbar.sw.sf -side top -fill both -expand 1
    set base [.vTcl.toolbar.sw.sf getframe]
    set f [vTcl:new_widget_name tb $base]
    frame $f
    pack $f -side top -fill x
    image create photo pointer \
        -file [file join $vTcl(VTCL_HOME) images icon_pointer.gif]
    button $f.b -bd 1 -image pointer -relief sunken -command "
	$f.b configure -relief sunken
	vTcl:raise_last_button $f.b
	vTcl:rebind_button_1
	vTcl:status Status
    	set vTcl(x,lastButton) $f.b
    " -padx 0 -pady 0 -highlightthickness 0
    lappend vTcl(tool,list) $f.b
    set vTcl(x,lastButton) $f.b
    pack $f.b -side left
    label $f.l -text "Pointer" 
    pack $f.l -side left
}

proc vTcl:toolbar_add {class name image cmd_add} {
    global vTcl
    if {![winfo exists $.vTcl.toolbar]} { vTcl:toolbar_create }
    set base [.vTcl.toolbar.sw.sf getframe]
    set f [vTcl:new_widget_name tb $base]
    ensureImage $image
    frame $f
    pack $f -side top -fill x
    button $f.b -bd 1 -image $image -padx 0 -pady 0 -highlightthickness 0

    bind $f.b <ButtonRelease-1> \
        "vTcl:new_widget \$vTcl(pr,autoplace) $class $f.b \"$cmd_add\""

    bind $f.b <Shift-ButtonRelease-1> \
        "vTcl:new_widget 1 $class $f.b \"$cmd_add\""

    vTcl:set_balloon $f.b $name
    lappend vTcl(tool,list) $f.b
    pack $f.b -side left
    label $f.l -text $class
    vTcl:set_balloon $f.l $name
    pack $f.l -side left
}

proc vTclWindow.vTcl.toolbar {args} {
    vTcl:toolbar_reflow
}

proc vTcl:toolbar_reflow {{base .vTcl.toolbar}} {
    global vTcl
    set existed [winfo exists $base]
    if {!$existed} { vTcl:toolbar_create }
    wm resizable $base 1 1
    update

    vTcl:setup_vTcl:bind $base
}

