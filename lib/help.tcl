##############################################################################
#
# help.tcl - help dialog
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

proc vTclWindow.vTcl.help {args} {
    global vTcl
    set base .vTcl.help
    if {[winfo exists .vTcl.help]} {
        wm deiconify .vTcl.help; return
    }
    toplevel .vTcl.help -class Toplevel
    wm withdraw .vTcl.help
    wm transient .vTcl.help .vTcl
    wm focusmodel .vTcl.help passive
    wm title .vTcl.help "Help for Visual Tcl"
    wm maxsize .vTcl.help 1137 870
    wm minsize .vTcl.help 1 1
    wm overrideredirect .vTcl.help 0
    wm resizable .vTcl.help 1 1
    frame .vTcl.help.fra18 \
        -borderwidth 1 -height 30 -relief raised -width 30 
    text .vTcl.help.fra18.tex22 \
        -height 15 -width 80 \
        -xscrollcommand {.vTcl.help.fra18.scr23 set} \
        -yscrollcommand {.vTcl.help.fra18.scr24 set} -wrap none
    scrollbar .vTcl.help.fra18.scr23 \
        -command {.vTcl.help.fra18.tex22 xview} -orient horiz -width 10 
    scrollbar .vTcl.help.fra18.scr24 \
        -command {.vTcl.help.fra18.tex22 yview} -orient vert -width 10 
    button .vTcl.help.but21 \
        -command {
            wm withdraw .vTcl.help
        } -highlightthickness 0 -padx 9 -pady 3 \
        -image [vTcl:image:get_image ok.gif]
    pack .vTcl.help.but21 \
        -anchor e -expand 0 -fill none -padx 2 -pady 2 -side top 
    pack .vTcl.help.fra18 \
        -anchor center -expand 1 -fill both -padx 5 -pady 5 -side top 
    grid columnconf .vTcl.help.fra18 0 -weight 1
    grid rowconf .vTcl.help.fra18 0 -weight 1
    grid .vTcl.help.fra18.tex22 \
        -column 0 -row 0 -columnspan 1 -rowspan 1 -sticky nesw 
    grid .vTcl.help.fra18.scr23 \
        -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew 
    grid .vTcl.help.fra18.scr24 \
        -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns 

    set file [file join $vTcl(VTCL_HOME) lib Help Main]
    if {[file exists $file]} {
	set fp [open $file]
	.vTcl.help.fra18.tex22 delete 0.0 end
	.vTcl.help.fra18.tex22 insert end [read $fp]
	close $fp
    }

    .vTcl.help.fra18.tex22 configure -state disabled

    wm geometry .vTcl.help 600x425
    vTcl:center .vTcl.help 600 425
    wm deiconify .vTcl.help
}

###
## Open the help window and set the text to the text of the file referenced
## by helpName.
###
proc vTcl:Help {helpName} {
    global vTcl

    set file [file join $vTcl(VTCL_HOME) lib Help $helpName]
    if {![file exist $file]} {
	set helpName Main
	set file [file join $vTcl(VTCL_HOME) lib Help Main]
    }

    if {[vTcl:streq $helpName "Main"]} { set helpName "Visual Tcl" }

    Window show .vTcl.help

    wm title .vTcl.help $helpName

    .vTcl.help.fra18.tex22 configure -state normal

    set fp [open $file]
    .vTcl.help.fra18.tex22 delete 0.0 end
    .vTcl.help.fra18.tex22 insert end [read $fp]
    close $fp

    .vTcl.help.fra18.tex22 configure -state disabled

    update
}

###
## Bind a particular help file to a window or widget.
###
proc vTcl:BindHelp {w help} {
    bind $w <Key-F1> "vTcl:Help $help"
}
