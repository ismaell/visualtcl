#!/usr/bin/wish -f
##############################################################################
#
# Visual TCL - A cross-platform application development environment
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

set vTcl(sourcing) 0

rename proc vTcl:proc

vTcl:proc proc {name args body} {
    global vTcl
    if {$name == "Window" && $vTcl(sourcing) == "1"} {return}
    vTcl:proc $name $args $body
}

# replace 'winfo' command to fix place bug with toplevel windows
rename winfo vTcl:winfo

proc winfo {options args} {
	if {$options == "manager"} {
		set w [lindex $args 0]
		if {$w == "." || [vTcl:winfo class $w] == "Toplevel"} {
			return "wm"
		}
	}
	return [uplevel vTcl:winfo $options $args]
}

proc vTcl:splash {} {
    global vTcl
    toplevel .x -bd 3 -relief raised
    wm withdraw .x
    set sw [winfo screenwidth .]
    set sh [winfo screenheight .]
    image create photo "title" \
        -file [file join $vTcl(VTCL_HOME) images title.gif]
    wm overrideredirect .x 1
    label .x.l -image title -bd 1 -relief sunken
    pack .x.l -side top -expand 1 -fill both
    set x [expr {($sw - 200)/2}]
    set y [expr {($sh - 250)/2}]
    wm geometry .x +$x+$y
    wm deiconify .x
    update idletasks
    after 2500 {catch {destroy .x}}
}

proc vTcl:load_lib {lib} {
    global vTcl
    set file [file join $vTcl(LIB_DIR) $lib]
    if {[file exists $file] == 0} {
        puts "Missing Libary: $lib"
    } else {
        uplevel #0 [list source $file]
    }
}

proc vTcl:load_widgets {} {
    global vTcl
}

proc vTcl:load_libs {} {
    global vTcl
}

proc vTcl:setup {} {
    global tk_strictMotif env vTcl tcl_platform

    set vTcl(version)   1.2.0
    set vTcl(VTCL_HOME) $env(VTCL_HOME)
    if {$env(HOME) == ""} {
        set vTcl(CONF_FILE) [file join $env(VTCL_HOME) .vtclrc]
    } else {
        set vTcl(CONF_FILE) [file join $env(HOME) .vtclrc]
    }
    set vTcl(LIB_DIR)   [file join $vTcl(VTCL_HOME) lib]
    set vTcl(LIB_WIDG)  [glob -nocomplain [file join $vTcl(LIB_DIR) lib_*.tcl]]
    set vTcl(LIBS)      "globals.tcl about.tcl propmgr.tcl balloon.tcl
        attrbar.tcl
        bind.tcl command.tcl color.tcl console.tcl compound.tcl compounds.tcl
        do.tcl dragsize.tcl dump.tcl edit.tcl file.tcl handle.tcl
        input.tcl menu.tcl misc.tcl name.tcl prefs.tcl proc.tcl tclet.tcl
        toolbar.tcl tops.tcl tree.tcl var.tcl vtclib.tcl widget.tcl help.tcl"

    set tk_strictMotif    1
    wm withdraw .
    vTcl:splash

	# load vtcl libraries (from 'lib' directory)
    foreach i $vTcl(LIBS) {
        vTcl:load_lib $i
    }

    # load widget libraries
    foreach i $vTcl(LIB_WIDG) {
        vTcl:load_lib $i
        lappend vTcl(w,libs) [lindex [split [lindex [file split $i] end] .] 0]
    }
    if {[file exists $vTcl(CONF_FILE)]} {
        catch {uplevel #0 [list source $vTcl(CONF_FILE)]}
        catch {set vTcl(w,def_mgr) $vTcl(pr,manager)}
    }
    vTcl:setup_gui
    update idletasks
    set vTcl(start,procs)   [lsort [info procs]]
    set vTcl(start,globals) [lsort [info globals]]

    rename exit vTcl:exit
    proc exit {args} {}
    proc init {argc argv} {}
    proc main {argc argv} {}

    vTcl:proclist:show $vTcl(pr,show_func)
    vTcl:varlist:show  $vTcl(pr,show_var)
    vTcl:toplist:show  $vTcl(pr,show_top)
}

proc vTcl:setup_gui {} {
    global vTcl tcl_platform tk_version

    if {$tcl_platform(platform) == "macintosh"} {
        set vTcl(pr,balloon) 0
        set vTcl(balloon,on) 0
    }
    if {$tk_version < 8} {
        if {$vTcl(pr,font_dlg) == ""} {
            set vTcl(pr,font_dlg) -Adobe-Helvetica-Medium-R-Normal-*-*-180-*-*-*-*-*-*
        }
        if {$vTcl(pr,font_fixed) == ""} {
            set vTcl(pr,font_fixed) fixed
        }
        option add *vTcl*font \
            -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-*
        option add *vTcl*Scrollbar.borderWidth 1
        option add *vTcl*Scrollbar.width 10
    } else {
        if {$vTcl(pr,font_dlg) == ""} {
            set vTcl(pr,font_dlg) {Helvetica 14}
        }
        if {$vTcl(pr,font_fixed) == ""} {
            set vTcl(pr,font_fixed) {Courier 10}
        }
        if {$tcl_platform(platform) == "unix"} {
            option add *vTcl*Scrollbar.width 10
            option add *vTcl*font {Helvetica 12}
        }
    }
    option add *vTcl*Text*font $vTcl(pr,font_fixed)

    vTcl:setup_bind_tree .
    vTcl:load_images
    Window show .vTcl
    foreach l $vTcl(w,libs) {
        vTcl:widget:lib:$l
    }
    vTcl:toolbar_reflow
    foreach i $vTcl(gui,showlist) {
        Window show $i
    }
    vTcl:define_bindings
    vTcl:cmp_sys_menu
}

proc vTclWindow.vTcl {args} {
    global vTcl tcl_platform tcl_version

    if {[winfo exists .vTcl]} {return}
    toplevel $vTcl(gui,main)
    wm title $vTcl(gui,main) "Visual Tcl"
    wm resizable $vTcl(gui,main) 0 0
	wm group $vTcl(gui,main) $vTcl(gui,main)
	wm command $vTcl(gui,main) "$vTcl(VTCL_HOME)/vtcl"
	wm iconname $vTcl(gui,main) "Visual Tcl"
    if {$tcl_platform(platform) == "macintosh"} {
        wm geometry $vTcl(gui,main) +0+20
    } else {
        wm geometry $vTcl(gui,main) +0+0
    }
    catch {wm geometry .vTcl $vTcl(geometry,.vTcl)}
    wm protocol .vTcl WM_DELETE_WINDOW {vTcl:quit}
    set tmp $vTcl(gui,main).menu
    frame $tmp -relief flat
    frame .vTcl.stat -relief flat
    pack $tmp -side top -expand 1 -fill x

	if {$tcl_version >= 8} {
		.vTcl conf -menu .vTcl.m
	}
    foreach menu {file edit mode compound options window} {
		if {$tcl_version >= 8} {
			vTcl:menu:insert .vTcl.m.$menu $menu .vTcl.m
		} else {
			menubutton $tmp.$menu -text [vTcl:upper_first $menu] \
				-menu $tmp.$menu.m -anchor w
			vTcl:menu:insert $tmp.$menu.m $menu
			pack $tmp.$menu -side left
		}
    }

	if {$tcl_version >= 8} {
		vTcl:menu:insert .vTcl.m.help help .vTcl.m
	} else {
		menubutton $tmp.help -text Help -menu $tmp.help.m -anchor w
		vTcl:menu:insert $tmp.help.m help
		pack $tmp.help -side right
	}

    # RIGHT CLICK MENU
    set vTcl(gui,rc_menu) .vTcl.menu_rc
    menu $vTcl(gui,rc_menu) -tearoff 0
        $vTcl(gui,rc_menu) add command -label "Set Insert" -command {
            vTcl:set_insert
        }
        $vTcl(gui,rc_menu) add separator
        $vTcl(gui,rc_menu) add command -label "Select Toplevel" -command {
            vTcl:select_toplevel
        }
        $vTcl(gui,rc_menu) add command -label "Select Parent" -command {
            vTcl:select_parent
        }
        $vTcl(gui,rc_menu) add separator
        $vTcl(gui,rc_menu) add comm -label "Hide" -comm {
            vTcl:hide
        }

    # MINI-ATTRIBUTE AREA
    vTcl:attrbar
    vTcl:set_manager $vTcl(w,def_mgr)

    # STATUS AREA
    label .vTcl.stat.sl \
        -relief groove -bd 2 -text "Status" -anchor w -width 35 \
        -textvariable vTcl(status)
    label .vTcl.stat.mo \
        -width 6 -relief groove -bd 2 -textvariable vTcl(mode)
    bind .vTcl.stat.mo <ButtonRelease> vTcl:switch_mode
    vTcl:set_balloon .vTcl.stat.mo "application mode"
    frame .vTcl.stat.f -relief sunken -bd 1 -width 150 -height 15
    frame .vTcl.stat.f.bar -relief raised -bd 1 -bg #ff4444
    pack .vTcl.stat.sl -side left -expand 1 -fill both
    pack .vTcl.stat.mo -side left -padx 2
    pack .vTcl.stat.f  -side left -padx 2 -fill y
    pack .vTcl.stat -side top -fill both

    vTcl:setup_vTcl:bind .vTcl
}

proc vTcl:vtcl:remap {} {
    global vTcl
    foreach i $vTcl(windows) {
        catch {wm deiconify $i} error
    }
    foreach i $vTcl(tops) {
        if {[winfo exists $i] == 1} {
            if {[wm state $i] != "withdrawn"} {
                catch {wm deiconify $i} error
            }
        }
    }
}

proc vTcl:vtcl:unmap {} {
    global vTcl
    foreach i $vTcl(windows) {
        if {$i != ".vTcl"} {
            catch {wm withdraw $i} error
        } else {
            catch {wm iconify $i} error
        }
    }
    foreach i $vTcl(tops) {
        if {[winfo exists $i] == 1} {
            if {[wm state $i] != "withdrawn"} {
                catch {wm iconify $i} error
            }
        }
    }
}

proc vTcl:define_bindings {} {
    global vTcl
    vTcl:status "creating bindings"

    foreach i {a b} {
        bind vTcl($i) <Control-z>  { vTcl:pop_action }
        bind vTcl($i) <Control-r>  { vTcl:redo_action }
        bind vTcl($i) <Control-x>  { vTcl:cut }
        bind vTcl($i) <Control-c>  { vTcl:copy }
        bind vTcl($i) <Control-v>  { vTcl:paste }
        bind vTcl($i) <Control-q>  { vTcl:quit }
        bind vTcl($i) <Control-n>  { vTcl:new }
        bind vTcl($i) <Control-o>  { vTcl:open }
        bind vTcl($i) <Control-s>  { vTcl:save }
        bind vTcl($i) <Control-w>  { vTcl:close }
        bind vTcl($i) <Key-Delete> { vTcl:delete }
        bind vTcl($i) <Alt-a>      { vTcl:set_alias $vTcl(w,widget) }
        bind vTcl($i) <Alt-f>      { vTcl:proclist:show flip }
        bind vTcl($i) <Alt-v>      { vTcl:varlist:show flip }
        bind vTcl($i) <Alt-o>      { vTcl:toplist:show flip }
        bind vTcl($i) <Alt-t>      { vTcl:setup_unbind_tree . }
        bind vTcl($i) <Alt-e>      { vTcl:setup_bind_tree . }
        bind vTcl($i) <Alt-b>      { vTcl:show_bindings }
        bind vTcl($i) <Alt-w>      { vTcl:show_wtree }
        bind vTcl($i) <Alt-c>      { vTcl:name_compound $vTcl(w,widget) }
    }

    bind vTcl(c) <Configure>  {
        if {$vTcl(w,widget) == "%W"} {
            vTcl:update_widget_info %W
        }
        vTcl:place_handles $vTcl(w,widget)
    }

    bind Text <Control-Key-c> {tk_textCopy %W}
    bind Text <Control-Key-x> {tk_textCut %W}
    bind Text <Control-Key-v> {tk_textPaste %W}
    bind Text <Key-Tab>       {
        tkTextInsert %W $vTcl(tab)
        focus %W
        break
    }
    #
    # handles auto-indent
    #
    bind Text <Key-Return>    {
        set pos [%W index "insert linestart"]
        set nos [%W search -regexp -nocase "\[a-z0-9\]" $pos]
        if {$nos != ""} {
            set ct [%W get $pos $nos]
            tkTextInsert %W "\n${ct}"
            focus %W
            break
        } else {
            tkTextInsert %W "\n"
            focus %W
            break
        }
    }

    bind vTcl(b) <Shift-Button-1>    {vTcl:bind_scrollbar %W $vTcl(w,widget)}
    bind vTcl(b) <Button-3>          {vTcl:right_click %W %X %Y}
    bind vTcl(b) <Double-Button-1>   {vTcl:widget_dblclick %W}
    bind vTcl(b) <Button-1>          {vTcl:bind_button_1 %W %X %Y}
    bind vTcl(b) <Button-2>          {vTcl:bind_button_2 %W %X %Y}
    bind vTcl(b) <Control-Button-1>  {vTcl:bind_button_2 %W %X %Y}
    bind vTcl(b) <B1-Motion>         {vTcl:bind_motion %X %Y}
    bind vTcl(b) <B2-Motion>         {vTcl:bind_motion %X %Y}
    bind vTcl(b) <Control-B1-Motion> {vTcl:bind_motion %X %Y}
    bind vTcl(b) <ButtonRelease-1>   {vTcl:bind_release %X %Y}
    bind vTcl(b) <ButtonRelease-2>   {vTcl:bind_release %X %Y}

    bind vTcl(b) <Up>          { vTcl:widget_delta $vTcl(w,widget) 0 -$vTcl(key,y) 0 0 }
    bind vTcl(b) <Down>        { vTcl:widget_delta $vTcl(w,widget) 0 $vTcl(key,y) 0 0 }
    bind vTcl(b) <Left>        { vTcl:widget_delta $vTcl(w,widget) -$vTcl(key,x) 0 0 0 }
    bind vTcl(b) <Right>       { vTcl:widget_delta $vTcl(w,widget) $vTcl(key,x) 0 0 0 }
    bind vTcl(b) <Shift-Up>    { vTcl:widget_delta $vTcl(w,widget) 0 0 0 -$vTcl(key,h) }
    bind vTcl(b) <Shift-Down>  { vTcl:widget_delta $vTcl(w,widget) 0 0 0 $vTcl(key,h) }
    bind vTcl(b) <Shift-Left>  { vTcl:widget_delta $vTcl(w,widget) 0 0 -$vTcl(key,w) 0 }
    bind vTcl(b) <Shift-Right> { vTcl:widget_delta $vTcl(w,widget) 0 0 $vTcl(key,w) 0 }

    bind vTcl(b) <Alt-h> {
        if { $vTcl(h,exist) == "yes" } {
            vTcl:destroy_handles
        } else {
            vTcl:create_handles $vTcl(w,widget)
        }
    }

    vTcl:status "Status"
}

proc vTcl:main {argc argv} {
    global env vTcl tcl_version tcl_platform

    catch {package require Unsafe} ; #for running in Netscape
    catch {package require dde}    ; #for windows
    catch {package require Tk}     ; #for dynamic loading tk
    if {$tcl_version < 7.6} {
        wm deiconify .
        wm title . "Time to upgrade"
        frame .f -relief groove -bd 2
        pack .f -expand 1 -fill both -padx 2 -pady 2
        label .f.l1 -text "This version of Tk is too old..."
        label .f.l2 -text "Tcl7.6 and Tk4.2 or newer required"
        button .f.b -text "Bummer!" -command {exit}
        pack .f.l1 .f.l2 -side top -padx 5
        pack .f.b -side top -pady 5
    } else {
        if {[info commands console] == "console"} {
            console title "Visual Tcl"
            console hide
        }
        if {$tcl_platform(platform) == "macintosh"} {
            set vTcl(VTCL_HOME) $env(HOME)
        }
        if {![info exists env(VTCL_HOME)]} {
            set home [file dirname [info script]]
            switch [file pathtype $home] {
                absolute {set env(VTCL_HOME) $home}
                relative {set env(VTCL_HOME) [file join [pwd] $home]}
                volumerelative {
                    set curdir [pwd]
                    cd $home
                    set env(VTCL_HOME) [file join [pwd] [file dirname \
                        [file join [lrange [file split $home] 1 end]]]]
                    cd $curdir
                }
            }
        }
        if {![file isdir $env(VTCL_HOME)]} {
            set vTcl(VTCL_HOME) [pwd]
        }
        vTcl:setup
        if {$argc == 1} {
            if {[file exists $argv]} {
                vTcl:open $argv
            } elseif {[file exists [file join [pwd] $argv]]} {
                vTcl:open [file join [pwd] $argv]
            }
        }
        if {[info commands console] == "console"} {
            set vTcl(console) 1
        }
    }
}

vTcl:main $argc $argv


