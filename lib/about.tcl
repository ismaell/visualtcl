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
    bind $base <Key-Escape> "%W.fra30.but31 invoke"
    bind $base <Key-Return> "%W.fra30.but31 invoke"

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
        -command "Window hide $base; Window show .vTcl.credits" \
        -text Credits... -width 8 \
        -borderwidth 1 -font [vTcl:font:get_font "vTcl:font5"]
    label $base.lab21 \
        -borderwidth 1 -font [vTcl:font:get_font "vTcl:font5"] \
        -text {Version 1.5.2} -foreground white -background black
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

    vTcl:center $base
    wm deiconify $base
}

proc vTcl:fill_credits {} {

    global vTcl tcl_version tk_version

    set inID [open [file join $vTcl(VTCL_HOME) lib Help About.txt]]
    CreditsText delete 0.0 end
    CreditsText insert 0.0 [read $inID]
    CreditsText insert end \
        "\nTcl version $tcl_version\nTk version $tk_version"
    CreditsText configure -state disabled
    close $inID
}

proc vTclWindow.vTcl.credits {base {container 0}} {

    if {$base == ""} {
        set base .vTcl.credits
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }

    global widget tcl_version tk_version
    vTcl:DefineAlias $base CreditsWindow vTcl:Toplevel:WidgetProc "" 1
    vTcl:DefineAlias $base.cpd24.03 CreditsText vTcl:WidgetProc CreditsWindow 1

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
    bind $base <Key-Escape> "$base.but23 invoke"
    bind $base <<Ready>> {
        vTcl:fill_credits
        wm geometry %W 500x420
        vTcl:center %W 500 420
        wm deiconify %W
    }
    }
    ::vTcl::OkButton $base.but23 -command "Window hide $base"
    frame $base.cpd24 \
        -borderwidth 1 -height 30 -relief raised -width 30
    scrollbar $base.cpd24.01 \
        -command "$base.cpd24.03 xview" -orient horizontal
    scrollbar $base.cpd24.02 \
        -command "$base.cpd24.03 yview"
    text $base.cpd24.03 -height 1 -background white \
        -font {-family helvetica -size 12} \
        -width 8 -wrap none -xscrollcommand "$base.cpd24.01 set" \
        -yscrollcommand "$base.cpd24.02 set"
    bind $base.cpd24.03 <KeyRelease> "break"
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.but23 \
        -in $base -anchor e -expand 0 -fill none -pady 5 -side top
    pack $base.cpd24 \
        -in $base -anchor center -expand 1 -fill both -side top
    grid columnconf $base.cpd24 0 -weight 1
    grid rowconf $base.cpd24 0 -weight 1
    grid $base.cpd24.01 \
        -in $base.cpd24 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew
    grid $base.cpd24.02 \
        -in $base.cpd24 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns
    grid $base.cpd24.03 \
        -in $base.cpd24 -column 0 -row 0 -columnspan 1 -rowspan 1 -sticky nesw

    vTcl:FireEvent $base <<Ready>>
}
