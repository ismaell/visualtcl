##############################################################################
#
# about.tcl - dialog "about Visual Tcl"
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

proc vTclWindow.vTcl.about {args} {

    set base .vTcl.about

    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    global widget
    set widget(rev,$base.lab21) {AboutVersion}
    set {widget(AboutVersion)} "$base.lab21"
    set {widget(child,AboutVersion)} "lab21"
    set {widget(CreditsWindow)} ".vTcl.credits"

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel -background black
    wm focusmodel $base passive
    wm withdraw $base
    wm minsize $base 100 1
    wm overrideredirect $base 0
    wm resizable $base 0 0
    wm transient $base .vTcl
    wm title $base "About Visual Tcl"

    label $base.lab28 \
        -background #000000 -borderwidth 1 -image title -relief groove \
        -text label
    frame $base.fra30 \
        -borderwidth 2 -height 75 -width 125 -background black
    button $base.fra30.but31 \
        -text Close -width 8 \
        -command "Window hide $base" \
        -borderwidth 1 -font [vTcl:font:get_font "vTcl:font5"]
    button $base.fra30.but32 \
        -command Window\ hide\ $base\;Window\ show\ \$widget(CreditsWindow) \
        -text Credits... -width 8 \
        -borderwidth 1 -font [vTcl:font:get_font "vTcl:font5"]
    label $base.lab21 \
        -borderwidth 1 -font [vTcl:font:get_font "vTcl:font5"] \
        -text {Version 1.5.1b4} -foreground white -background black
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.lab28 \
        -in $base -anchor center -expand 1 -fill both -side top 
    pack $base.fra30 \
        -in $base -anchor center -expand 0 -fill none -side bottom 
    pack $base.fra30.but31 \
        -in $base.fra30 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side right 
    pack $base.fra30.but32 \
        -in $base.fra30 -anchor center -expand 0 -fill none -padx 5 \
        -side left
    pack $base.lab21 \
        -in $base -anchor center -expand 0 -fill none -pady 2 -side top 

    update idletasks

    bind $base <Key-Escape> "$base.fra30.but31 invoke"

    vTcl:center $base
    wm deiconify $base
}

proc vTclWindow.vTcl.credits {base {container 0}} {

    if {$base == ""} {
        set base .vTcl.credits
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }

    global widget tcl_version tk_version
    set widget(rev,$base) {CreditsWindow}
    set {widget(CreditsWindow)} "$base"
    set {widget(child,CreditsWindow)} ""
    interp alias {} CreditsWindow {} vTcl:Toplevel:WidgetProc $base
    set widget(rev,$base.cpd24) {Frame1}
    set {widget(Frame1)} "$base.cpd24"
    set {widget(child,Frame1)} "cpd24"
    interp alias {} Frame1 {} vTcl:Toplevel:WidgetProc $base.cpd24
    set widget(rev,$base.cpd24.01) {Scrollbar1}
    set {widget(Scrollbar1)} "$base.cpd24.01"
    set {widget(child,Scrollbar1)} "cpd24.01"
    interp alias {} Scrollbar1 {} vTcl:Toplevel:WidgetProc $base.cpd24.01
    set widget(rev,$base.cpd24.02) {Scrollbar2}
    set {widget(Scrollbar2)} "$base.cpd24.02"
    set {widget(child,Scrollbar2)} "cpd24.02"
    interp alias {} Scrollbar2 {} vTcl:Toplevel:WidgetProc $base.cpd24.02
    set widget(rev,$base.cpd24.03) {CreditsText}
    set {widget(CreditsText)} "$base.cpd24.03"
    set {widget(child,CreditsText)} "cpd24.03"
    interp alias {} CreditsText {} vTcl:WidgetProc $base.cpd24.03

    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    toplevel $base -class Toplevel
    wm transient $base .vTcl
    wm overrideredirect $base 0
    wm focusmodel $base passive
    wm withdraw $base
    wm maxsize $base 1284 1010
    wm minsize $base 100 1
    wm resizable $base 1 1
    wm title $base "Visual Tcl Credits"
    }
    button $base.but23 \
        -command {Window hide $widget(CreditsWindow)} -text Close -width 8
    frame $base.cpd24 \
        -borderwidth 1 -height 30 -relief raised -width 30
    scrollbar $base.cpd24.01 \
        -command "$base.cpd24.03 xview" -orient horizontal
    scrollbar $base.cpd24.02 \
        -command "$base.cpd24.03 yview"
    text $base.cpd24.03 \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* -height 1 \
        -width 8 -wrap none -xscrollcommand "$base.cpd24.01 set" \
        -yscrollcommand "$base.cpd24.02 set"
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.but23 \
        -in $base -anchor center -expand 0 -fill none -pady 5 -side bottom
    pack $base.cpd24 \
        -in $base -anchor center -expand 1 -fill both -side top
    grid columnconf $base.cpd24 0 -weight 1
    grid rowconf $base.cpd24 0 -weight 1
    grid $base.cpd24.01 \
        -in $base.cpd24 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew
    grid $base.cpd24.02 \
        -in $base.cpd24 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns
    grid $base.cpd24.03 \
        -in $base.cpd24 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw

    CreditsText delete 0.0 end
    CreditsText insert 0.0 \
         "Copyright\ (C)\ 1996-2000\ Stewart\ Allen\ (stewart@neuron.com)\n\n======================================================================\nMaintained\ by:\n\nChristian\ Gavin\ (cgavin@dnai.com)\nDamon\ Courtney\ (damon@unreality.com)\n\n======================================================================\nFreewrap\ is\ Copyright\ (C)\ 1998\ by\ Dennis\ LaBelle\n(dlabelle@albany.net)\ All\ Rights\ Reserved.\n\n======================================================================\nPortions\ of\ this\ software\ from\n\n\ \ Effective\ Tcl/Tk\ Programming\n\ \ Mark\ Harrison,\ DSC\ Communications\ Corp.\n\ \ Michael\ McLennan,\ Bell\ Labs\ Innovations\ for\ Lucent\ Technologies\n\ \ Addison-Wesley\ Professional\ Computing\ Series\n\n\ \ Copyright\ (c)\ 1996-1997\ \ Lucent\ Technologies\ Inc.\ and\ Mark\ Harrison\n======================================================================\n
Routines for encoding and decoding base64
   encoding from Time Janes,
   decoding from Pascual Alonso,
   namespace'ing and bugs from Parand Tony Darugar (tdarugar@binevolve.com)\n
Combobox and Multicolumn listbox Copyright (c) 1999, Bryan Oakley
Progressbar Copyright (c) 2000 Alexander Schoepe\n
======================================================================
Enhanced Tk Console, part of the VerTcl system

Originally based off Brent Welch's Tcl Shell Widget
(from \"Practical Programming in Tcl and Tk\")

Thanks to the following (among many) for early bug reports & code ideas:
Steven Wahl <steven@indra.com>, Jan Nijtmans <nijtmans@nici.kun.nl>
Crimmins <markcrim@umich.edu>, Wart <wart@ugcs.caltech.edu>

Copyright 1995-2000 Jeffrey Hobbs
Initiated: Thu Aug 17 15:36:47 PDT 1995

jeff.hobbs@acm.org

source standard_disclaimer.tcl
source bourbon_ware.tcl
======================================================================
"
    CreditsText insert end \
         "\nTcl version $tcl_version\nTk version $tk_version"
    bind $base <Key-Escape> "$base.but23 invoke"

    # avoid syntax coloring in credits text...
    bind $widget(CreditsText) <KeyRelease> "break"

    wm geometry $base 500x420
    vTcl:center $base 500 420
    wm deiconify $base
}
