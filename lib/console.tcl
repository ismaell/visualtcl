##############################################################################
#
# console.tcl - console procedures
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

namespace eval ::console {
    variable MRU         ""
    variable current_MRU 0

    proc add_MRU cmd {

        variable MRU
        variable current_MRU 0

        set MRU [linsert $MRU 0 $cmd]

        if {[llength $MRU] > 20} {
            set MRU [lreplace $MRU end end]
        }

        set current_MRU -1
    }

    proc get_MRU direction {

        variable MRU
        variable current_MRU

        switch $direction {
            backward {
                if {$current_MRU < [expr [llength $MRU] - 1]} {
                    incr current_MRU
                }
            }
            forward {
                if {$current_MRU > 0} {
                    incr current_MRU -1
                }
            }
        }

        set result [lindex $MRU $current_MRU]
        return $result
    }
}

proc vTclWindow.vTcl.con {args} {
    #@@change by Christian Gavin 3/18/2000
    # restore console position/size
    global vTcl env
    #@@end_change

    set base .vTcl.con
    if {[winfo exists .vTcl.con]} {
        wm deiconify .vTcl.con; return
    }

    toplevel .vTcl.con -class vTcl
    wm transient .vTcl.con .vTcl
    wm minsize .vTcl.con 375 80
    wm title .vTcl.con "Command Console"
    wm protocol .vTcl.con WM_DELETE_WINDOW { vTcl:attrbar:toggle_console }
    frame .vTcl.con.fra5 \
        -height 30 -width 30
    pack .vTcl.con.fra5 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side top
    text .vTcl.con.fra5.tex7 \
        -highlightthickness 0 -state disabled -width 50 -height 6 \
        -yscrollcommand {.vTcl.con.fra5.scr8 set}
    pack .vTcl.con.fra5.tex7 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    scrollbar .vTcl.con.fra5.scr8 \
        -command {.vTcl.con.fra5.tex7 yview} -highlightthickness 0
    pack .vTcl.con.fra5.scr8 \
        -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side right
    frame .vTcl.con.fra6
    pack .vTcl.con.fra6 \
        -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side top
    # @@change by Christian Gavin 3/13/2000
    # button to insert the complete name of the currently selected
    # widget
    button .vTcl.con.fra6.but1 \
        -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) images edit inswidg.gif] ] \
        -command "vTcl:insert_widget_in_text .vTcl.con.fra6.ent10"
    vTcl:set_balloon .vTcl.con.fra6.but1 "Insert selected widget command"
    pack .vTcl.con.fra6.but1 -fill x -side left
    # @@end_change
    vTcl:entry .vTcl.con.fra6.ent10 \
        -highlightthickness 0 -bg white
    pack .vTcl.con.fra6.ent10 \
        -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side top
    menu .vTcl.con.fra5.tex7.menu -tearoff 0
    .vTcl.con.fra5.tex7.menu add command -label "Clear" \
         -command {.vTcl.con.fra5.tex7 conf -state normal
                   .vTcl.con.fra5.tex7 delete 0.0 end
                   .vTcl.con.fra5.tex7 conf -state disabled}
    bind .vTcl.con.fra5.tex7 <ButtonPress-3> {
        tk_popup .vTcl.con.fra5.tex7.menu %X %Y
    }
    bind .vTcl.con.fra6.ent10 <Key-Return> {
        .vTcl.con.fra5.tex7 conf -state normal
        .vTcl.con.fra5.tex7 insert end "\n[.vTcl.con.fra6.ent10 get]" vTcl:bold
        .vTcl.con.fra5.tex7 conf -state disabled

        set cmd [.vTcl.con.fra6.ent10 get]
        if {$cmd == "exit" || $cmd == "quit"} {
            vTcl:attrbar:toggle_console
            set caught 0
            set vTcl(err) $cmd
        } else {
            ::console::add_MRU $cmd
            set caught [expr [catch $cmd vTcl(err)] == 1]
        }

        .vTcl.con.fra5.tex7 conf -state normal

        if {$caught} {
            .vTcl.con.fra5.tex7 insert end "\n$vTcl(err)\n" vTcl:error
        } else {
            .vTcl.con.fra5.tex7 insert end "\n$vTcl(err)\n" vTcl:return_value
        }

        .vTcl.con.fra5.tex7 conf -state disabled
        .vTcl.con.fra5.tex7 yview end
        .vTcl.con.fra6.ent10 delete 0 end
    }
    bind .vTcl.con.fra6.ent10 <KeyRelease-Up> {
        set cmd [::console::get_MRU backward]
        .vTcl.con.fra6.ent10 delete 0 end
        .vTcl.con.fra6.ent10 insert 0 $cmd
    }
    bind .vTcl.con.fra6.ent10 <KeyRelease-Down> {
        set cmd [::console::get_MRU forward]
        .vTcl.con.fra6.ent10 delete 0 end
        .vTcl.con.fra6.ent10 insert 0 $cmd
    }

    catch {wm geometry .vTcl.con $vTcl(geometry,.vTcl.con)}

    .vTcl.con.fra5.tex7 tag configure vTcl:bold \
        -font -*-helvetica-bold-r-normal--*-120-*

    .vTcl.con.fra5.tex7 tag configure vTcl:error -foreground #B00000
    .vTcl.con.fra5.tex7 tag configure vTcl:return_value -foreground #0000B0
    # @@end_change

    vTcl:setup_vTcl:bind $base
}

proc vTcl:console:get_output {{display 1}} {
    global vTcl

    # is the console actually visible ? if not, we'll show output later
    if {! [winfo exists .vTcl.con]} {
    	return
    }

    set contents [read $vTcl(LOG_FD_R)]
    if {$contents != "" && $display} {

	.vTcl.con.fra5.tex7 conf -state normal
        .vTcl.con.fra5.tex7 insert end "\n$contents" vTcl:return_value
	.vTcl.con.fra5.tex7 yview end
	.vTcl.con.fra5.tex7 conf -state disabled
    }
}

