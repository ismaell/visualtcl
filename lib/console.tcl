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

proc vTcl:show_console {{show show}} {
    global vTcl tcl_platform
    if {$vTcl(console) == 1} {
        console $show
    } else {
        Window $show .vTcl.con
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
    frame .vTcl.con.fra6 \
        -height 30 -width 30
    pack .vTcl.con.fra6 \
        -anchor center -expand 0 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side top
    # @@change by Christian Gavin 3/13/2000
    # button to insert the complete name of the currently selected
    # widget
    button .vTcl.con.fra6.but1 \
        -text "Insert selected widget name" \
        -command "vTcl:insert_widget_in_text .vTcl.con.fra6.ent10"
    pack .vTcl.con.fra6.but1 -fill x -side top
    # @@end_change
    entry .vTcl.con.fra6.ent10 \
        -highlightthickness 0
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

        set caught [expr [catch [.vTcl.con.fra6.ent10 get] vTcl(err)] == 1]

	# not needed, since the redefined "puts" command calls this function
        # vTcl:console:get_output

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
    catch {wm geometry .vTcl.con $vTcl(geometry,.vTcl.con)}

    .vTcl.con.fra5.tex7 tag configure vTcl:bold \
        -font -*-helvetica-bold-r-normal--*-120-*

    .vTcl.con.fra5.tex7 tag configure vTcl:error -foreground #B00000
    .vTcl.con.fra5.tex7 tag configure vTcl:return_value -foreground #0000B0
    # @@end_change
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

