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
        -borderwidth 1 -height 53 -relief sunken -width 125 
    label $base.fra18.lab32 \
        -relief raised -text {The Basics} 
    checkbutton $base.fra18.che33 \
        -anchor w -highlightthickness 0 -text {Use Balloon Help} \
        -variable vTcl(pr,balloon) 
    checkbutton $base.fra18.che34 \
        -anchor w -highlightthickness 0 -text {Ask for Widget name on insert} \
        -variable vTcl(pr,getname) 
    checkbutton $base.fra18.che35 \
        -anchor w -highlightthickness 0 \
        -text {Save verbose widget configuration} -variable vTcl(pr,fullcfg) 
    checkbutton $base.fra18.che36 \
        -anchor w -highlightthickness 0 -text {Short automatic widget names} \
        -variable vTcl(pr,shortname) 
    checkbutton $base.fra18.che37 \
        -anchor w -highlightthickness 0 -text {Save global variable values} \
        -variable vTcl(pr,saveglob) 
    checkbutton $base.fra18.che39 \
        -anchor w -highlightthickness 0 -text {Window focus selects window} \
        -variable vTcl(pr,winfocus) 
    checkbutton $base.fra18.che40 \
        -anchor w -highlightthickness 0 -text {Window focus selects window} \
        -variable vTcl(pr,winfocus) 
    frame $base.fra18.fra17 \
        -height 5 -relief groove -width 5 
    frame $base.fra20 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    label $base.fra20.lab22 \
        -relief raised -text {Font Settings} 
    label $base.fra20.lab23 \
        -relief raised -text Dialog -width 7 
    label $base.fra20.lab24 \
        -relief raised -text Fixed -width 7 
    entry $base.fra20.ent25 \
        -textvariable vTcl(pr,font_dlg) -width 8 
    entry $base.fra20.ent26 \
        -textvariable vTcl(pr,font_fixed) -width 8 
    bind $base.fra20.ent26 <Return> {
        option add *vTcl*Text*font $vTcl(pr,font_fixed)
    }
    frame $base.fra21 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    label $base.fra21.lab41 \
        -relief raised -text {Default Manager}
    radiobutton $base.fra21.rad42 \
        -anchor w -highlightthickness 0 -text Grid -value grid \
        -variable vTcl(pr,manager) -width 5 
    radiobutton $base.fra21.rad43 \
        -anchor w -highlightthickness 0 -text Pack -value pack \
        -variable vTcl(pr,manager) -width 5 
    radiobutton $base.fra21.rad44 \
        -anchor w -highlightthickness 0 -text Place -value place \
        -variable vTcl(pr,manager) -width 5 
    label $base.fra21.lab18 \
        -relief raised -text {Option Encaps} 
    radiobutton $base.fra21.rad19 \
        -anchor w -highlightthickness 0 -text List -value list \
        -variable vTcl(pr,encase) -width 5 
    radiobutton $base.fra21.rad20 \
        -anchor w -highlightthickness 0 -text Braces -value brace \
        -variable vTcl(pr,encase) -width 5 
    radiobutton $base.fra21.rad21 \
        -anchor w -highlightthickness 0 -text Quotes -value quote \
        -variable vTcl(pr,encase) -width 5 
    frame $base.fra21.fra20 \
        -height 5 -width 5 
    frame $base.fra23 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    button $base.fra23.but18 \
        -command "wm withdraw $base" -highlightthickness 0 -padx 9 \
        -pady 3 -text OK 
    ###################
    # SETTING GEOMETRY
    ###################
    grid columnconf $base 0 -weight 1
    grid $base.fra18 \
        -column 0 -row 0 -columnspan 1 -rowspan 1 -ipadx 5 -padx 5 \
        -pady 5 -sticky nesw 
    grid columnconf $base.fra18 0 -weight 1
    grid rowconf $base.fra18 7 -weight 1
    grid $base.fra18.lab32 \
        -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5 -sticky nesw 
    grid $base.fra18.che33 \
        -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra18.che34 \
        -column 0 -row 2 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra18.che35 \
        -column 0 -row 4 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra18.che36 \
        -column 0 -row 3 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra18.che37 \
        -column 0 -row 5 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra18.che40 \
        -column 0 -row 6 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra18.fra17 \
        -column 0 -row 7 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra20 \
        -column 0 -row 1 -columnspan 1 -rowspan 1 -ipadx 5 -padx 5 \
        -pady 5 -sticky nesw 
    grid columnconf $base.fra20 1 -weight 1
    grid $base.fra20.lab22 \
        -column 0 -row 0 -columnspan 2 -rowspan 1 -padx 5 \
        -pady 5 -sticky nesw 
    grid $base.fra20.lab23 \
        -column 0 -row 1 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5 -sticky nesw 
    grid $base.fra20.lab24 \
        -column 0 -row 2 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5 -sticky nesw 
    grid $base.fra20.ent25 \
        -column 1 -row 1 -columnspan 1 -rowspan 1 -padx 5 \
        -sticky ew 
    grid $base.fra20.ent26 \
        -column 1 -row 2 -columnspan 1 -rowspan 1 -padx 5 \
        -sticky ew 
    grid $base.fra21 \
        -column 1 -row 0 -columnspan 1 -rowspan 2 -ipadx 5 -padx 5 \
        -pady 5 -sticky nesw 
    grid columnconf $base.fra21 0 -weight 1
    grid rowconf $base.fra21 8 -weight 1
    grid $base.fra21.lab41 \
        -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5 -sticky nesw 
    grid $base.fra21.rad42 \
        -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra21.rad43 \
        -column 0 -row 2 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra21.rad44 \
        -column 0 -row 3 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra21.lab18 \
        -column 0 -row 4 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5 -sticky nesw 
    grid $base.fra21.rad19 \
        -column 0 -row 5 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra21.rad20 \
        -column 0 -row 6 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra21.rad21 \
        -column 0 -row 7 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra21.fra20 \
        -column 0 -row 8 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra23 \
        -column 0 -row 2 -columnspan 2 -rowspan 1 -padx 5 -pady 5 \
        -sticky nesw 
    grid columnconf $base.fra23 0 -weight 1
    grid $base.fra23.but18 \
        -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 3 \
        -pady 3 -sticky nesw 
}


