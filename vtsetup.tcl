#!/usr/bin/wish

##############################################################################
#
# vtsetup.tcl
#     a utility to select libraries to load on Visual Tcl startup
#
# Copyright (C) 2000 Christian Gavin
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

set vTcl(LIB_FILE) [file join $env(HOME) .vtcllibs]

############################
# code to load stock fonts


if {![info exist vTcl(sourcing)]} {
set vTcl(fonts,counter) 0
proc vTcl:font:add_font {font_descr font_type newkey} {

     global vTcl

     incr vTcl(fonts,counter)
     set newfont [eval font create $font_descr]

     lappend vTcl(fonts,objects) $newfont

     # each font has its unique key so that when a project is
     # reloaded, the key is used to find the font description

     if {$newkey == ""} {
          set newkey vTcl:font$vTcl(fonts,counter)
     }

     set vTcl(fonts,$newfont,type)                      $font_type
     set vTcl(fonts,$newfont,key)                       $newkey
     set vTcl(fonts,$vTcl(fonts,$newfont,key),object)   $newfont

     # in case caller needs it
     return $newfont
}

proc vTcl:font:get_font {key} {

	global vTcl

	return $vTcl(fonts,$key,object)
}

vTcl:font:add_font "-family helvetica -size 12 -weight normal -slant roman -underline 0 -overstrike 0" stock vTcl:font1
vTcl:font:add_font "-family helvetica -size 12 -weight normal -slant roman -underline 1 -overstrike 0" stock underline
vTcl:font:add_font "-family courier -size 12 -weight normal -slant roman -underline 0 -overstrike 0" stock vTcl:font3
vTcl:font:add_font "-family times -size 12 -weight normal -slant roman -underline 0 -overstrike 0" stock vTcl:font4
vTcl:font:add_font "-family helvetica -size 12 -weight bold -slant roman -underline 0 -overstrike 0" stock vTcl:font5
vTcl:font:add_font "-family courier -size 12 -weight bold -slant roman -underline 0 -overstrike 0" stock vTcl:font6
vTcl:font:add_font "-family times -size 12 -weight bold -slant roman -underline 0 -overstrike 0" stock vTcl:font7
vTcl:font:add_font "-family lucida -size 18 -weight normal -slant roman -underline 0 -overstrike 0" stock vTcl:font8
vTcl:font:add_font "-family lucida -size 18 -weight normal -slant italic -underline 0 -overstrike 0" stock vTcl:font9
}
############################
# code to load user fonts

vTcl:font:add_font "-family helvetica -size 12 -weight normal -slant italic -underline 0 -overstrike 0" user vTcl:font10

#################################
# GLOBAL VARIABLES
#
global widget;
    set widget(.vTcl.fontmgr.listbox) {.vTcl.fontmgr.fra28.cpd29.01}
    set widget(.vTcl.fontmgr.text) {.vTcl.fontmgr.cpd43.03}
    set widget(listbox) {.top38.lis41}
    set widget(rev,.top38.lis41) {listbox}
    set widget(rev,.vTcl.fontmgr.cpd43.03) {.vTcl.fontmgr.text}
    set widget(rev,.vTcl.fontmgr.fra28.cpd29.01) {.vTcl.fontmgr.listbox}

#################################
# USER DEFINED PROCEDURES
#

proc {setup_exit} {} {
global widget
global vTcl

set indices [$widget(listbox) curselection]

set outID [open $vTcl(LIB_FILE) w]

foreach index $indices {

    puts $outID [$widget(listbox) get $index]
}

close $outID
exit
}

proc {setup_init} {} {
global widget
global vTcl

####################################
#
# fill in the listbox

$widget(listbox) delete 0 end

set dirname [file dirname [info script]]
# puts $dirname
set libs [glob -nocomplain [file join $dirname lib lib*.tcl]]

foreach lib $libs {
    $widget(listbox) insert end [file tail $lib]
}

####################################
#
# try to open the configuration file
# if no configuration file selects everything

if {! [file exists $vTcl(LIB_FILE)] } {

    $widget(listbox) selection set 0 end
    return
}

set inID [open $vTcl(LIB_FILE) r]
set items [split [read $inID] \n]

foreach item $items {
    setup_select $item
}

close $inID
}

proc {setup_select} {item} {
global widget

set items [$widget(listbox) get 0 end]

for {set index 0}  {$index < [llength $items]}  {incr index} {

    if { [$widget(listbox) get $index] == $item} {

        $widget(listbox) selection set $index
        return
    }
}
}

proc {main} {argc argv} {
global widget
wm protocol .top38 WM_DELETE_WINDOW {setup_exit}

setup_init
}

proc {Window} {args} {
global vTcl
    set cmd [lindex $args 0]
    set name [lindex $args 1]
    set newname [lindex $args 2]
    set rest [lrange $args 3 end]
    if {$name == "" || $cmd == ""} {return}
    if {$newname == ""} {
        set newname $name
    }
    set exists [winfo exists $newname]
    switch $cmd {
        show {
            if {$exists == "1" && $name != "."} {wm deiconify $name; return}
            if {[info procs vTclWindow(pre)$name] != ""} {
                eval "vTclWindow(pre)$name $newname $rest"
            }
            if {[info procs vTclWindow$name] != ""} {
                eval "vTclWindow$name $newname $rest"
            }
            if {[info procs vTclWindow(post)$name] != ""} {
                eval "vTclWindow(post)$name $newname $rest"
            }
        }
        hide    { if $exists {wm withdraw $newname; return} }
        iconify { if $exists {wm iconify $newname; return} }
        destroy { if $exists {destroy $newname; return} }
    }
}

proc init {argc argv} {

}

init $argc $argv

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base {container 0}} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    wm focusmodel $base passive
    wm geometry $base 1x1+0+0
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm withdraw $base
    wm title $base "vt.tcl"
    }
    ###################
    # SETTING GEOMETRY
    ###################
}

proc vTclWindow.top38 {base {container 0}} {
    if {$base == ""} {
        set base .top38
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm geometry $base 364x260+179+199
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Visual Tcl Libraries Setup"
    }
    message $base.mes40 \
        -aspect 600 -justify center -padx 5 -pady 2 \
        -text {The following libraires are available to Visual Tcl. Please select the libraries you want to be loaded on Visual Tcl startup.}
    message $base.mes45 \
        -aspect 600 -font [vTcl:font:get_font "vTcl:font10"] -padx 5 -pady 2 \
        -text {Note: this will take effect the next time you start Visual Tcl.}
    listbox $base.lis41 \
        -foreground #808080 -height 0 -selectmode multiple -width 0
    button $base.but42 \
        -command setup_exit -padx 9 -pady 3 -text Close
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.mes40 \
        -in $base -anchor center -expand 0 -fill x -side top
    pack $base.mes45 \
        -in $base -anchor center -expand 0 -fill none -side top
    pack $base.lis41 \
        -in $base -anchor center -expand 1 -fill both -side top
    pack $base.but42 \
        -in $base -anchor center -expand 0 -fill x -side bottom
}

Window show .
Window show .top38

main $argc $argv
