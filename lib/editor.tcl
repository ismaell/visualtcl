##############################################################################
#
# editor.tcl - a simple text editor
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

proc vTcl:editor:load_images {} {
	global vTcl
	foreach i {new open save cut copy paste search srchfwd srchbak} {
		image create photo "editor_$i" \
			-file [file join $vTcl(VTCL_HOME) images edit $i.gif]
	}
}

proc vTclWindow.editor {base} {
    if {$base == ""} {
        set base .vTcl.editor
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm geometry $base 436x395+253+154
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Text Editor"
    frame $base.cpd18 \
        -borderwidth 1 -height 30 -relief raised -width 30 
    menubutton $base.cpd18.01 \
        -anchor w -menu $base.cpd18.01.02 -padx 4 -pady 3 -text File \
        -width 4 
    menu $base.cpd18.01.02 -tearoff 0 
    $base.cpd18.01.02 add command  -accelerator Ctrl+N -label New 
    $base.cpd18.01.02 add command  -accelerator Ctrl+O -label Open 
    $base.cpd18.01.02 add command  -accelerator Ctrl+W -label Close 
    $base.cpd18.01.02 add separator
    $base.cpd18.01.02 add command  -accelerator Ctrl+S -label Save 
    $base.cpd18.01.02 add command  -label {Save As} 
    $base.cpd18.01.02 add separator
    $base.cpd18.01.02 add command  -accelerator Ctrl+Q -label Exit 
    menubutton $base.cpd18.03 \
        -anchor w -menu $base.cpd18.03.04 -padx 4 -pady 3 -text Edit \
        -width 4 
    menu $base.cpd18.03.04 \
        -tearoff 0 
    menubutton $base.cpd18.05 \
        -anchor w -menu $base.cpd18.05.06 -padx 4 -pady 3 -text Help \
        -width 4 
    menu $base.cpd18.05.06 \
        -tearoff 0 
    menubutton $base.cpd18.men19 \
        -anchor w -menu $base.cpd18.men19.01 -padx 4 -pady 3 -text Goto \
        -width 4 
    menu $base.cpd18.men19.01 \
        -tearoff 0 
    frame $base.fra20 \
        -borderwidth 1 -height 20 -relief raised -width 125 
    frame $base.fra20.fra21 \
        -height 85 -relief groove -width 194 
    button $base.fra20.fra21.fra22 \
        -borderwidth 1 -relief raised -image editor_new
    button $base.fra20.fra21.fra23  -command "vTcl:editor:load $base.fra27.tex28" \
        -borderwidth 1 -relief raised -image editor_open
    button $base.fra20.fra21.fra24 \
        -borderwidth 1 -relief raised -image editor_save
    frame $base.fra20.fra25 \
        -height 85 -relief groove -width 194 
    button $base.fra20.fra25.01 \
        -borderwidth 1 -relief raised -image editor_cut
    button $base.fra20.fra25.02 \
        -borderwidth 1 -relief raised -image editor_copy
    button $base.fra20.fra25.03 \
        -borderwidth 1 -relief raised -image editor_paste
    frame $base.fra20.fra26 \
        -height 85 -relief groove -width 194 
    button $base.fra20.fra26.01 \
        -borderwidth 1 -relief raised -image editor_search
    button $base.fra20.fra26.02 \
        -borderwidth 1 -relief raised -image editor_srchfwd
    button $base.fra20.fra26.03 \
        -borderwidth 1 -relief raised -image editor_srchbak
    frame $base.fra27 \
        -borderwidth 1 -height 75 -relief raised -width 125 
    text $base.fra27.tex28 \
        -height 9 -highlightthickness 0 -width 33 \
        -xscrollcommand "$base.fra27.scr29 set" \
        -yscrollcommand "$base.fra27.scr30 set" \
		-wrap none
    scrollbar $base.fra27.scr29 \
        -command "$base.fra27.tex28 xview" -highlightthickness 0 \
        -orient horiz 
    scrollbar $base.fra27.scr30 \
        -command "$base.fra27.tex28 yview" -highlightthickness 0 \
        -orient vert 
    frame $base.fra31 \
        -borderwidth 1 -height 20 -relief raised -width 125 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.cpd18 \
        -in $base -anchor center -expand 0 -fill x -side top 
    pack $base.cpd18.01 \
        -in $base.cpd18 -anchor center -expand 0 -fill none -side left 
    pack $base.cpd18.03 \
        -in $base.cpd18 -anchor center -expand 0 -fill none -side left 
    pack $base.cpd18.05 \
        -in $base.cpd18 -anchor center -expand 0 -fill none -side right 
    pack $base.cpd18.men19 \
        -in $base.cpd18 -anchor center -expand 0 -fill none -side left 
    pack $base.fra20 \
        -in $base -anchor center -expand 0 -fill x -side top 
    pack $base.fra20.fra21 \
        -in $base.fra20 -anchor center -expand 0 -fill none -padx 3 -pady 2 \
        -side left 
    pack $base.fra20.fra21.fra22 \
        -in $base.fra20.fra21 -anchor center -expand 0 -fill none -side left 
    pack $base.fra20.fra21.fra23 \
        -in $base.fra20.fra21 -anchor center -expand 0 -fill none -side left 
    pack $base.fra20.fra21.fra24 \
        -in $base.fra20.fra21 -anchor center -expand 0 -fill none -side left 
    pack $base.fra20.fra25 \
        -in $base.fra20 -anchor center -expand 0 -fill none -padx 3 -pady 2 \
        -side left 
    pack $base.fra20.fra25.01 \
        -in $base.fra20.fra25 -anchor center -expand 0 -fill none -side left 
    pack $base.fra20.fra25.02 \
        -in $base.fra20.fra25 -anchor center -expand 0 -fill none -side left 
    pack $base.fra20.fra25.03 \
        -in $base.fra20.fra25 -anchor center -expand 0 -fill none -side left 
    pack $base.fra20.fra26 \
        -in $base.fra20 -anchor center -expand 0 -fill none -padx 3 -pady 2 \
        -side left 
    pack $base.fra20.fra26.01 \
        -in $base.fra20.fra26 -anchor center -expand 0 -fill none -side left 
    pack $base.fra20.fra26.02 \
        -in $base.fra20.fra26 -anchor center -expand 0 -fill none -side left 
    pack $base.fra20.fra26.03 \
        -in $base.fra20.fra26 -anchor center -expand 0 -fill none -side left 
    pack $base.fra27 \
        -in $base -anchor center -expand 1 -fill both -side top 
    grid columnconf $base.fra27 0 -weight 1
    grid rowconf $base.fra27 0 -weight 1
    grid $base.fra27.tex28 \
        -in $base.fra27 -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 1 \
        -pady 1 -sticky nesw 
    grid $base.fra27.scr29 \
        -in $base.fra27 -column 0 -row 1 -columnspan 1 -rowspan 1 -padx 1 \
        -pady 1 -sticky ew 
    grid $base.fra27.scr30 \
        -in $base.fra27 -column 1 -row 0 -columnspan 1 -rowspan 1 -padx 1 \
        -pady 1 -sticky ns 
    pack $base.fra31 \
        -in $base -anchor center -expand 0 -fill x -side top 
}

proc vTcl:editor:load {text} {
	set file [vTcl:get_file open]
	if {$file == ""} {
		return
	}
	set f [open $file]
	$text delete 0.0 end
	$text insert end [read $f]
	close $f
}

source globals.tcl
source file.tcl

toplevel .vTcl
wm withdraw .
wm withdraw .vTcl
global vTcl; set vTcl(VTCL_HOME) /home/stewart/vtcl/vtcl

vTcl:editor:load_images
vTclWindow.editor ""


