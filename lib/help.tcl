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
        -height 15 -width 80 -background white \
        -xscrollcommand {.vTcl.help.fra18.scr23 set} \
        -yscrollcommand {.vTcl.help.fra18.scr24 set} -wrap none
    scrollbar .vTcl.help.fra18.scr23 \
        -command {.vTcl.help.fra18.tex22 xview} -orient horiz
    scrollbar .vTcl.help.fra18.scr24 \
        -command {.vTcl.help.fra18.tex22 yview} -orient vert
    ::vTcl::OkButton $base.but21 -command "Window hide $base"
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

proc vTclWindow.vTcl.tip {base {container 0}} {

    global vTcl

    if {$base == ""} {
        set base .vTcl.tip
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }

    image create photo light_bulb -data {
        R0lGODdhNAA0APcAAAAAAIAAAACAAICAAAAAgIAAgACAgMDAwMDcwKbK8AAA
        AAAAKgAAVQAAfwAAqgAA1AAqAAAqKgAqVQAqfwAqqgAq1ABVAABVKgBVVQBV
        fwBVqgBV1AB/AAB/KgB/VQB/fwB/qgB/1ACqAACqKgCqVQCqfwCqqgCq1ADU
        AADUKgDUVQDUfwDUqgDU1CoAACoAKioAVSoAfyoAqioA1CoqACoqKioqVSoq
        fyoqqioq1CpVACpVKipVVSpVfypVqipV1Cp/ACp/Kip/VSp/fyp/qip/1Cqq
        ACqqKiqqVSqqfyqqqiqq1CrUACrUKirUVSrUfyrUqirU1FUAAFUAKlUAVVUA
        f1UAqlUA1FUqAFUqKlUqVVUqf1UqqlUq1FVVAFVVKlVVVVVVf1VVqlVV1FV/
        AFV/KlV/VVV/f1V/qlV/1FWqAFWqKlWqVVWqf1WqqlWq1FXUAFXUKlXUVVXU
        f1XUqlXU1H8AAH8AKn8AVX8Af38Aqn8A1H8qAH8qKn8qVX8qf38qqn8q1H9V
        AH9VKn9VVX9Vf39Vqn9V1H9/AH9/Kn9/VX9/f39/qn9/1H+qAH+qKn+qVX+q
        f3+qqn+q1H/UAH/UKn/UVX/Uf3/Uqn/U1KoAAKoAKqoAVaoAf6oAqqoA1Koq
        AKoqKqoqVaoqf6oqqqoq1KpVAKpVKqpVVapVf6pVqqpV1Kp/AKp/Kqp/Vap/
        f6p/qqp/1KqqAKqqKqqqVaqqf6qqqqqq1KrUAKrUKqrUVarUf6rUqqrU1NQA
        ANQAKtQAVdQAf9QAqtQA1NQqANQqKtQqVdQqf9QqqtQq1NRVANRVKtRVVdRV
        f9RVqtRV1NR/ANR/KtR/VdR/f9R/qtR/1NSqANSqKtSqVdSqf9SqqtSq1NTU
        ANTUKtTUVdTUf9TUqtTU1AAAAAwMDBkZGSYmJjMzMz8/P0xMTFlZWWZmZnJy
        cn9/f4yMjJmZmaWlpbKysr+/v8zMzNjY2OXl5fLy8v/78KCgpICAgP8AAAD/
        AP//AAAA//8A/wD//////ywAAAAANAA0AAAI/gD/CRxIsKDBgwgTKlzIsKHD
        hxD/AYhIsaJFihMRZrxYcGNCjx05HgRpEABJiSdFojRoz57JljBbmlSpkWBM
        lzddArBHc2TGnDtvvuTZs2NQoUd1Ji0qUKbJpDlx5kSZ0mHMp1GzXp3JUahW
        rU+rWv1K1unLrmXTDiUaMezXsG7JVoQL9Om+u/viaqVoFikAvHe93dX5lS9M
        qCYFe1vMeDDUmxHf7pNHGZxly43z7qXKFSFYAJXBtbwMrvFas3AZfg59E7M3
        eZq3ij0IdrJonjEvU877mG3D2vJEs7RnmTLs3r5LwtXr8vVtg6R3I2+4POnf
        4C0Lji4tPWpkpYdttwsfuL34ce8QsyYOfjs39+PWwz4Ejt29N3DyBCNePrZu
        aNKXMXZaTIZFBcBr+QGYGXLJ/bZafowthldhFX0GGoQS3jUgTBf1JRtsgO0j
        1VYNPsTcYReKeJiBT2FE3lvyoLiZQLMpBKNS0xUFVozMncXUPyseFiN4Zv1I
        0GlB6SWfkVwFidNOR3bWk5Q0crhSlD+elNGSIRWV0kZPyWOkQ5SFJeaY1F1I
        GZomtshmmzW+KeecdPYUEAA7}

    global widget
    vTcl:DefineAlias $base TipWindow vTcl:TopLevel:WidgetProc "" 1
    vTcl:DefineAlias $base.cpd25.03 TipText vTcl:WidgetProc TipWindow 1
    vTcl:DefineAlias $base.fra20.che26 DontShowTips vTcl:WidgetProc TipWindow 1

    if {[info exists vTcl(pr,dontshowtips)]} {
        set ::tip::dontshow $vTcl(pr,dontshowtips)
    }
    if {[info exists vTcl(pr,tipindex)]} {
        set ::tip::Index $vTcl(pr,tipindex)
    }

    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm withdraw $base
    wm maxsize $base 1284 1010
    wm minsize $base 100 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "Tip of the day"
    wm protocol $base WM_DELETE_WINDOW {
         Window hide .vTcl.tip
         set vTcl(pr,dontshowtips) $::tip::dontshow
         set vTcl(pr,tipindex)     $::tip::Index}
    }
    frame $base.fra20 \
        -borderwidth 2 -height 75 -width 125 
    button $base.fra20.but22 \
        -text Close -width 8 \
        -command {
             Window hide .vTcl.tip
             set vTcl(pr,dontshowtips) $::tip::dontshow
             set vTcl(pr,tipindex)     $::tip::Index
         }
    checkbutton $base.fra20.che26 \
        -text {Don't show tips on startup} -variable ::tip::dontshow 
    button $base.fra20.but19 \
        \
        -command {
             TipWindow.TipText configure -state normal
             TipWindow.TipText delete 0.0 end
             TipWindow.TipText insert end [::tip::get_next_tip]
             TipWindow.TipText configure -state disabled
        } \
        -text {Next >} -width 8 
    frame $base.fra23 \
        -borderwidth 2 
    label $base.fra23.lab24 \
        -borderwidth 1 \
        -image light_bulb \
        -relief raised -text label 
    frame $base.cpd25 \
        -borderwidth 1 -relief raised 
    scrollbar $base.cpd25.01 \
        -command "$base.cpd25.03 xview" -orient horizontal
    scrollbar $base.cpd25.02 \
        -command "$base.cpd25.03 yview"
    text $base.cpd25.03 -background white \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* -height 1 \
        -xscrollcommand "$base.cpd25.01 set" \
        -yscrollcommand "$base.cpd25.02 set" 
    label $base.lab19 \
        -borderwidth 1 -font [vTcl:font:get_font "vTcl:font8"] \
        -text {Did you know ...?} 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra20 \
        -in $base -anchor e -expand 0 -fill x -side bottom 
    pack $base.fra20.but22 \
        -in $base.fra20 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side right 
    pack $base.fra20.che26 \
        -in $base.fra20 -anchor center -expand 0 -fill none -side left 
    pack $base.fra20.but19 \
        -in $base.fra20 -anchor center -expand 0 -fill none -padx 5 -pady 5 \
        -side right 
    pack $base.fra23 \
        -in $base -anchor center -expand 0 -fill y -side left 
    pack $base.fra23.lab24 \
        -in $base.fra23 -anchor center -expand 0 -fill none -padx 5 \
        -side left 
    pack $base.cpd25 \
        -in $base -anchor center -expand 1 -fill both -padx 5 -pady 5 \
        -side bottom 
    grid columnconf $base.cpd25 0 -weight 1
    grid rowconf $base.cpd25 0 -weight 1
    grid $base.cpd25.01 \
        -in $base.cpd25 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew 
    grid $base.cpd25.02 \
        -in $base.cpd25 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns 
    grid $base.cpd25.03 \
        -in $base.cpd25 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    pack $base.lab19 \
        -in $base -anchor center -expand 0 -fill none -side top 

    wm geometry $base 506x292
    update
    vTcl:center $base 506 292
    wm deiconify $base

    $base.fra20.but19 invoke
}

namespace eval ::tip {
    variable Tips ""
    variable Index 0

    proc {::tip::get_next_tip} {} {
	variable Tips
        variable Index

	if {[lempty $Tips]} {
	    global vTcl
	    set tipFile [file join $vTcl(VTCL_HOME) lib Help Tips]
	    foreach tip [vTcl:read_file $tipFile] {
		lappend Tips [string trim $tip]
	    }
	}

        set length [llength $Tips]
        set Index  [expr ($Index + 1) % $length]

        return [lindex $Tips $Index]
    }
}

namespace eval ::vTcl::news {
    variable http	""
    variable URL	"http://www.unreality.com/vtcl/news.txt"

    proc ::vTcl::news::Init {} {
	variable http
        if {[catch {package require http} error]} { return 0 }

	set http ::http::geturl
	if {$error < 2.3} { set http http_get }
	return 1
    }

    proc ::vTcl::news::get_news {} {
	global vTcl
	variable http
	variable URL

	after cancel $vTcl(tmp,newsAfter)

	vTcl:status "Getting news..."

    	if {![::vTcl::news::Init]} { return }

	if {[catch {$http $URL -timeout 30000} token]} { return }
	upvar #0 $token state

	## If we didn't get the file successfully, bail out.
	if {[lindex $state(http) 1] != 200} { return }

	::vTcl::news::display_news $state(body)

	vTcl:status
    }

    proc ::vTcl::news::display_news {string} {
	set base .vTcl.news

	if {[winfo exists $base]} {
	    ::vTcl::news::parse_news $base $string
	    wm deiconify $base
	    return
	}

	###################
	# CREATING WIDGETS
	###################
	toplevel $base -class Toplevel
	wm transient $base .vTcl
	wm withdraw $base
	wm focusmodel $base passive
	wm geometry $base 494x257+214+102; update
	wm maxsize $base 1028 753
	wm minsize $base 104 1
	wm overrideredirect $base 0
	wm resizable $base 0 0
	vTcl:center $base 494 257
	wm deiconify $base
	wm title $base "Visual Tcl News"

	frame $base.f \
	    -borderwidth 1 -height 78 -relief raised -width 75 
	scrollbar $base.f.hs \
	    -command "$base.f.t xview" -orient horizontal
	scrollbar $base.f.vs \
	    -command "$base.f.t yview" -orient vertical
	text $base.f.t -background white -wrap none \
	    -xscrollcommand "$base.f.hs set" \
	    -yscrollcommand "$base.f.vs set" \
	    -cursor arrow
	::vTcl::OkButton $base.b -anchor center -command "Window hide $base"

	label $base.l -anchor w

	###################
	# SETTING GEOMETRY
	###################
	pack $base.b \
	    -in $base -anchor e -expand 0 -fill none -side top 
	pack $base.l -side bottom -fill x
	pack $base.f \
	    -in $base -anchor center -expand 1 -fill both -side top
	grid columnconf $base.f 0 -weight 1
	grid rowconf $base.f 0 -weight 1
	grid $base.f.hs \
	    -in $base.f -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew
	grid $base.f.vs \
	    -in $base.f -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns
	grid $base.f.t \
	    -in $base.f -column 0 -row 0 -columnspan 1 -rowspan 1 -sticky nesw 

	wm protocol $base WM_DELETE_WINDOW "$base.b invoke"

	font create link -family Arial -size 10 -underline 1

	::vTcl::news::parse_news $base $string
    }

    proc ::vTcl::news::parse_news {base string} {
	global env

	foreach child \[$base.f.t window names] { destroy \$child }

	$base.f.t configure -state normal
	$base.f.t delete 0.0 end

	set lines [split [string trim $string] \n]
	set  i 0
	foreach line $lines {
	    if {[lempty $line]} { continue }
	    if {[string index $line 0] == "#"} { continue }
	    lassign $line command date text link
	    set text "$date - $text"
	    
	    incr i
	    switch -- $command {
	    	"News"	{
		    set l [label $base.f.t.link$i -text $text \
		    	-background white -foreground blue -font link \
			-cursor hand1]
		    bind $l <Button-1> "exec [::vTcl::web_browser] $link &"
		    bind $l <Enter> "$base.l configure -text $link"
		    bind $l <Leave> "$base.l configure -text {}"
		    $base.f.t window create end -window $l
		    $base.f.t insert end \n
		}
	    }
	}
	$base.f.t configure -state disabled
    }
}
