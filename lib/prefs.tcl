##############################################################################
#
# prefs.tcl - procedures for editing application preferences
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

# @@change by Christian Gavin 3/28/00
# added preference option for image editor
# @@end_change

proc vTclWindow.vTcl.prefs {{base ""}} {
    if {$base == ""} {
        set base .vTcl.prefs
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class vTcl
    wm transient $base .vTcl
    wm focusmodel $base passive
    wm overrideredirect $base 0
    wm resizable $base 0 0
    wm deiconify $base
    wm title $base "Preferences"
    frame $base.fra18 \
        -borderwidth 1 -height 53 \
        -highlightbackground #bcbcbc -highlightcolor #000000 -relief sunken \
        -width 125 
    label $base.fra18.lab32 \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -relief raised -text {The Basics} 
    checkbutton $base.fra18.che33 \
        -activebackground #bcbcbc -activeforeground #000000 -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 \
        -text {Use Balloon Help} -variable vTcl(pr,balloon) 
    checkbutton $base.fra18.che34 \
        -activebackground #bcbcbc -activeforeground #000000 -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 \
        -text {Ask for Widget name on insert} -variable vTcl(pr,getname) 
    checkbutton $base.fra18.che35 \
        -activebackground #bcbcbc -activeforeground #000000 -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 \
        -text {Save verbose widget configuration} -variable vTcl(pr,fullcfg) 
    checkbutton $base.fra18.che36 \
        -activebackground #bcbcbc -activeforeground #000000 -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 \
        -text {Short automatic widget names} -variable vTcl(pr,shortname) 
    checkbutton $base.fra18.che37 \
        -activebackground #bcbcbc -activeforeground #000000 -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 \
        -text {Save global variable values} -variable vTcl(pr,saveglob) 
    checkbutton $base.fra18.che39 \
        -activebackground #bcbcbc -activeforeground #000000 -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 \
        -text {Window focus selects window} -variable vTcl(pr,winfocus) 
    checkbutton $base.fra18.che40 \
        -activebackground #bcbcbc -activeforeground #000000 -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 \
        -text {Window focus selects window} -variable vTcl(pr,winfocus) 
    checkbutton $base.fra18.che41 \
        -activebackground #bcbcbc -activeforeground #000000 -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 \
        -text {Auto load/save compounds} -variable vTcl(pr,autoloadcomp) 
    frame $base.fra18.fra17 \
        -height 5 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -relief groove -width 5 
    frame $base.fra18.cpd17 \
        -borderwidth 1 -height 30 \
        -highlightbackground #bcbcbc -highlightcolor #000000 -width 30 
    label $base.fra18.cpd17.01 \
        -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -text File: 
    entry $base.fra18.cpd17.02 \
        -cursor {} \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #f3f3f3 \
        -highlightcolor #000000 -highlightthickness 0 \
        -selectbackground #000080 -selectforeground #ffffff \
        -textvariable vTcl(pr,autoloadcompfile) -width 25 
    frame $base.fra20 \
        -borderwidth 1 -height 30 \
        -highlightbackground #bcbcbc -highlightcolor #000000 -relief sunken \
        -width 30 
    label $base.fra20.lab22 \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -relief raised -text {Font Settings} 
    label $base.fra20.lab23 \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -relief raised -text Dialog -width 7 
    label $base.fra20.lab24 \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -relief raised -text Fixed -width 7 
    entry $base.fra20.ent25 \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #f3f3f3 \
        -highlightcolor #000000 -selectbackground #000080 \
        -selectforeground #ffffff -textvariable vTcl(pr,font_dlg) -width 8 
    entry $base.fra20.ent26 \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #f3f3f3 \
        -highlightcolor #000000 -selectbackground #000080 \
        -selectforeground #ffffff -textvariable vTcl(pr,font_fixed) -width 8 
    bind $base.fra20.ent26 <Key-Return> {
        option add *vTcl*Text*font $vTcl(pr,font_fixed)
    }
    frame $base.fra21 \
        -borderwidth 1 -height 30 \
        -highlightbackground #bcbcbc -highlightcolor #000000 -relief sunken \
        -width 30 
    label $base.fra21.lab41 \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -relief raised -text {Default Manager} 
    radiobutton $base.fra21.rad42 \
        -activebackground #bcbcbc -activeforeground #000000 -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 -text Grid -value grid \
        -variable vTcl(pr,manager) -width 5 
    radiobutton $base.fra21.rad43 \
        -activebackground #bcbcbc -activeforeground #000000 -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 -text Pack -value pack \
        -variable vTcl(pr,manager) -width 5 
    radiobutton $base.fra21.rad44 \
        -activebackground #bcbcbc -activeforeground #000000 -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 -text Place \
        -value place -variable vTcl(pr,manager) -width 5 
    label $base.fra21.lab18 \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -relief raised -text {Option Encaps} 
    radiobutton $base.fra21.rad19 \
        -activebackground #bcbcbc -activeforeground #000000 -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 -text List -value list \
        -variable vTcl(pr,encase) -width 5 
    radiobutton $base.fra21.rad20 \
        -activebackground #bcbcbc -activeforeground #000000 -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 -text Braces \
        -value brace -variable vTcl(pr,encase) -width 5 
    radiobutton $base.fra21.rad21 \
        -activebackground #bcbcbc -activeforeground #000000 -anchor w \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 -text Quotes \
        -value quote -variable vTcl(pr,encase) -width 5 
    frame $base.fra21.fra20 \
        -height 5 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -width 5 
    frame $base.fra23 \
        -borderwidth 1 -height 30 \
        -highlightbackground #bcbcbc -highlightcolor #000000 -relief sunken \
        -width 30 
    button $base.fra23.but18 \
        -activebackground #bcbcbc -activeforeground #000000 \
        -command {wm withdraw .vTcl.prefs} \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -highlightthickness 0 -padx 9 -pady 3 \
        -text OK 
    frame $base.fra22 \
        -borderwidth 1 \
        -highlightbackground #bcbcbc -highlightcolor #000000 -relief sunken
    label $base.fra22.lab0 \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -relief raised -text {Helper applications} 
    label $base.fra22.lab1 \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -text "Editor for images:"
    entry $base.fra22.ent1 \
        -cursor {} \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #f3f3f3 \
        -selectbackground #000080 -selectforeground #ffffff \
        -textvariable vTcl(pr,imageeditor)
        
    ###################
    # SETTING GEOMETRY
    ###################
    grid columnconf $base 0 -weight 1
    grid $base.fra18 \
        -in $base -column 0 -row 0 -columnspan 1 -rowspan 1 -ipadx 5 -padx 5 \
        -pady 5 -sticky nesw 
    grid columnconf $base.fra18 0 -weight 1
    grid rowconf $base.fra18 8 -weight 1
    grid $base.fra18.lab32 \
        -in $base.fra18 -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5 -sticky nesw 
    grid $base.fra18.che33 \
        -in $base.fra18 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra18.che34 \
        -in $base.fra18 -column 0 -row 2 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra18.che35 \
        -in $base.fra18 -column 0 -row 4 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra18.che36 \
        -in $base.fra18 -column 0 -row 3 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra18.che37 \
        -in $base.fra18 -column 0 -row 5 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra18.che40 \
        -in $base.fra18 -column 0 -row 6 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra18.che41 \
        -in $base.fra18 -column 0 -row 7 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra18.fra17 \
        -in $base.fra18 -column 0 -row 9 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra18.cpd17 \
        -in $base.fra18 -column 0 -row 8 -columnspan 1 -rowspan 1 
    pack $base.fra18.cpd17.01 \
        -in $base.fra18.cpd17 -anchor center -expand 0 -fill none -padx 2 \
        -pady 2 -side left 
    pack $base.fra18.cpd17.02 \
        -in $base.fra18.cpd17 -anchor center -expand 1 -fill x -padx 2 \
        -pady 2 -side right 
    grid $base.fra20 \
        -in $base -column 0 -row 1 -columnspan 1 -rowspan 1 -ipadx 5 -padx 5 \
        -pady 5 -sticky nesw 
    grid columnconf $base.fra20 1 -weight 1
    grid $base.fra20.lab22 \
        -in $base.fra20 -column 0 -row 0 -columnspan 2 -rowspan 1 -padx 5 \
        -pady 5 -sticky nesw 
    grid $base.fra20.lab23 \
        -in $base.fra20 -column 0 -row 1 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5 -sticky nesw 
    grid $base.fra20.lab24 \
        -in $base.fra20 -column 0 -row 2 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5 -sticky nesw 
    grid $base.fra20.ent25 \
        -in $base.fra20 -column 1 -row 1 -columnspan 1 -rowspan 1 -padx 5 \
        -sticky ew 
    grid $base.fra20.ent26 \
        -in $base.fra20 -column 1 -row 2 -columnspan 1 -rowspan 1 -padx 5 \
        -sticky ew 
    grid $base.fra21 \
        -in $base -column 1 -row 0 -columnspan 1 -rowspan 2 -ipadx 5 -padx 5 \
        -pady 5 -sticky nesw 
    grid columnconf $base.fra21 0 -weight 1
    grid rowconf $base.fra21 8 -weight 1
    grid $base.fra21.lab41 \
        -in $base.fra21 -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5 -sticky nesw 
    grid $base.fra21.rad42 \
        -in $base.fra21 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra21.rad43 \
        -in $base.fra21 -column 0 -row 2 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra21.rad44 \
        -in $base.fra21 -column 0 -row 3 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra21.lab18 \
        -in $base.fra21 -column 0 -row 4 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5 -sticky nesw 
    grid $base.fra21.rad19 \
        -in $base.fra21 -column 0 -row 5 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra21.rad20 \
        -in $base.fra21 -column 0 -row 6 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra21.rad21 \
        -in $base.fra21 -column 0 -row 7 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra21.fra20 \
        -in $base.fra21 -column 0 -row 8 -columnspan 1 -rowspan 1 \
        -sticky nesw
    grid $base.fra22 \
        -in $base -column 0 -row 2 -columnspan 2 -rowspan 1 -padx 5 -pady 5 \
        -sticky nesw 
    grid columnconf $base.fra22 1 -weight 1
    grid $base.fra22.lab0 \
        -in $base.fra22 -column 0 -row 0 -columnspan 2 -rowspan 1 -padx 5 \
        -pady 5 -sticky nesw 
    grid $base.fra22.lab1 \
        -in $base.fra22 -column 0 -row 1 -columnspan 1 -rowspan 1 -padx 3 \
        -pady 3 -sticky w
    grid $base.fra22.ent1 \
    	-in $base.fra22 -column 1 -row 1 -columnspan 1 -rowspan 1 -padx 3 \
    	-pady 3 -sticky news
    grid $base.fra23 \
        -in $base -column 0 -row 3 -columnspan 2 -rowspan 1 -padx 5 -pady 5 \
        -sticky nesw 
    grid columnconf $base.fra23 0 -weight 1
    grid $base.fra23.but18 \
        -in $base.fra23 -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 3 \
        -pady 3 -sticky nesw 
}
