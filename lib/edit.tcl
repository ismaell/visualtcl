##############################################################################
#
# edit.tcl - procedures used in cut, copy, and paste
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

proc vTcl:copy {} {
    global vTcl
    set vTcl(buffer) [vTcl:create_compound $vTcl(w,widget)]
    set vTcl(buffer,type) [vTcl:lower_first $vTcl(w,class)]
}

proc vTcl:cut {} {
    global vTcl
    if { $vTcl(w,widget) == "." } { return }

    vTcl:copy
    vTcl:delete
}

proc vTcl:delete {} {
    global vTcl
    if { $vTcl(w,widget) == "." } { return }

    set w $vTcl(w,widget)
    if {[lempty $w]} { return }

    vTcl:destroy_handles

    set top [winfo toplevel $w]
    # list widget tree without including $w (it's why the "0" parameter)
    set children [vTcl:widget_tree $w 0]
    set parent [winfo parent $vTcl(w,widget)]
    set class [winfo class $w]

    set buffer [vTcl:create_compound $vTcl(w,widget)]
    set do ""
    foreach child $children {
    	append do "vTcl:unset_alias $child; "
    }
    append do "vTcl:unset_alias $vTcl(w,widget); "
    append do "vTcl:setup_unbind $vTcl(w,widget); "
    append do "destroy $vTcl(w,widget)"
    set undo "vTcl:insert_compound $vTcl(w,widget) \{$buffer\} $vTcl(w,def_mgr)"
    vTcl:push_action $do $undo

    catch {namespace delete ::widgets::$vTcl(w,widget)} error

    ## If it's a toplevel window, remove it from the tops list.
    if {$class == "Toplevel"} { lremove vTcl(tops) $w }

    if {![info exists vTcl(widgets,$top)]} { set vTcl(widgets,$top) {} }
    ## Activate the widget created before this one in the widget order.
    set s [lsearch $vTcl(widgets,$top) $w]

    ## Remove the window and all its children from the widget order.
    eval lremove vTcl(widgets,$top) $w $children

    if {$s > 0} {
	set n [lindex $vTcl(widgets,$top) [expr $s - 1]]
    } else {
    	set n [lindex $vTcl(widgets,$top) end]
    }

    if {[lempty $vTcl(widgets,$top)] || ![winfo exists $n]} { set n $parent }

    # @@change by Christian Gavin 3/5/2000
    # automatically refresh widget tree after delete operation

    after idle {vTcl:init_wtree}

    # @@end_change

    if {[vTcl:streq $n "."]} {
    	vTcl:prop:clear
	return
    }

    if {[winfo exists $n]} { vTcl:active_widget $n }
}

proc vTcl:paste {{fromMouse ""}} {
    global vTcl

    if {![info exists vTcl(buffer)] || [lempty $vTcl(buffer)]} { return }

    set opts {}
    if {$fromMouse == "-mouse" && $vTcl(w,def_mgr) == "place"} {
    	set opts "-x $vTcl(mouse,x) -y $vTcl(mouse,y)"	
    }

    set name [vTcl:new_widget_name $vTcl(buffer,type) $vTcl(w,insert)]
    set do "
	vTcl:insert_compound $name [list $vTcl(buffer)] $vTcl(w,def_mgr) \
	    [list $opts]
	vTcl:setup_bind_tree $name
    "
    set undo "destroy $name"
    vTcl:push_action $do $undo

    # @@change by Christian Gavin 3/5/2000
    # automatically refresh widget tree after paste operation

    after idle {vTcl:init_wtree}

    # @@end_change

    vTcl:active_widget $name
}

namespace eval ::vTcl::findReplace {
    variable base	.find
    variable txtbox	""
    variable count	0

    variable case	1
    variable wild	0
    variable regexp	0
    variable dir	down

    variable index	0.0
    variable selFirst	0.0
    variable selLast	0.0
    variable origInd	0.0
}

proc ::vTcl::findReplace::window {{newBase ""} {container 0}} {
    variable base

    if {[llength $newBase] > 0} { set base $newBase }
    if {[winfo exists $base] && (!$container)} { wm deiconify $base; return }

    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
	toplevel $base -class Toplevel -cursor {} 
	wm focusmodel $base passive
	wm geometry $base 450x163+215+102; update
	wm maxsize $base 1028 753
	wm minsize $base 104 1
	wm overrideredirect $base 0
	wm resizable $base 0 0
	wm deiconify $base
	wm title $base "Find and Replace"
    }
    label $base.lab23 \
        -anchor w -borderwidth 1 -height 0 -text {Find what:} -underline 2 \
        -width 61 
    label $base.lab24 \
        -borderwidth 1 -text {Replace with:} -underline 1
    entry $base.findEnt \
        -width 256 
    entry $base.replaceEnt \
        -width 256 
    button $base.findBut \
        -height 23 -text {Find Next} -width 90 -command ::vTcl::findReplace::find -underline 0
    button $base.cancelBut \
        -height 23 -text Cancel -width 90 -command ::vTcl::findReplace::cancel -underline 0
    button $base.replaceBut \
        -height 23 -text Replace -width 90 -command ::vTcl::findReplace::replace -underline 0
    button $base.replaceAllBut \
        -height 23 -text {Replace All} -width 90 -command ::vTcl::findReplace::replaceAll \
	-underline 8
    checkbutton $base.caseCheck \
        -anchor w -height 17 -text {Match case} -variable che32 -width 88 \
	-variable ::vTcl::findReplace::case -underline 0
    checkbutton $base.wildCheck \
        -anchor w -height 17 -text {Use wildcards} -variable che33 -width 98 \
	-variable ::vTcl::findReplace::wild -underline 4
    checkbutton $base.regexpCheck \
        -anchor w -height 17 -text {Regular expression} -variable che34 -width 123 \
	-variable ::vTcl::findReplace::regexp -underline 2
    frame $base.fra22 \
        -borderwidth 2 -height 35 -relief groove -width 110 
    radiobutton $base.fra22.upRadio \
        -height 17 -text Up -underline 0 -value up \
        -variable ::vTcl::findReplace::dir -width 41 
    radiobutton $base.fra22.downRadio \
        -height 17 -text Down -underline 0 -value down \
        -variable ::vTcl::findReplace::dir -width 51 
    label $base.lab25 \
        -borderwidth 1 -height 0 -padx 1 -text Direction -width 46 

    focus $base.findEnt

    bind $base <Key-Escape> "::vTcl::findReplace::cancel"

    bind $base.findEnt <Key-Return> "::vTcl::findReplace::find"
    bind $base.replaceEnt <Key-Return> "::vTcl::findReplace::replace"

    bind $base <Alt-f> "focus $base.findEnt"
    bind $base <Alt-e> "focus $base.replaceEnt"
    bind $base <Alt-n> "$base.findBut invoke"
    bind $base <Alt-c> "$base.cancelBut invoke"
    bind $base <Alt-r> "$base.replaceBut invoke"
    bind $base <Alt-a> "$base.replaceAllBut invoke"
    bind $base <Alt-m> "$base.caseCheck invoke"
    bind $base <Alt-w> "$base.wildCheck invoke"
    bind $base <Alt-g> "$base.regexpCheck invoke"
    bind $base <Alt-u> "$base.fra22.upRadio invoke"
    bind $base <Alt-d> "$base.fra22.downRadio invoke"

    ###################
    # SETTING GEOMETRY
    ###################
    place $base.lab23 \
        -x 5 -y 10 -width 70 -height 17 -anchor nw -bordermode ignore 
    place $base.lab24 \
        -x 5 -y 60 -width 70 -anchor nw -bordermode ignore 
    place $base.findEnt \
        -x 85 -y 6 -width 256 -height 19 -anchor nw -bordermode ignore 
    place $base.replaceEnt \
        -x 85 -y 58 -width 256 -height 19 -anchor nw -bordermode ignore 
    place $base.findBut \
        -x 355 -y 5 -width 90 -height 23 -anchor nw -bordermode ignore 
    place $base.cancelBut \
        -x 355 -y 30 -width 90 -height 23 -anchor nw -bordermode ignore 
    place $base.replaceBut \
        -x 355 -y 55 -width 90 -height 23 -anchor nw -bordermode ignore 
    place $base.replaceAllBut \
        -x 355 -y 80 -width 90 -height 23 -anchor nw -bordermode ignore 
    place $base.caseCheck \
        -x 0 -y 100 -width 125 -height 17 -anchor nw -bordermode ignore 
    place $base.wildCheck \
        -x 0 -y 120 -width 125 -height 17 -anchor nw -bordermode ignore 
    place $base.regexpCheck \
        -x 0 -y 140 -width 125 -height 17 -anchor nw -bordermode ignore 
    place $base.fra22 \
        -x 230 -y 85 -width 112 -height 35 -anchor nw -bordermode ignore 
    place $base.fra22.upRadio \
        -x 5 -y 10 -width 41 -height 17 -anchor nw -bordermode ignore 
    place $base.fra22.downRadio \
        -x 50 -y 10 -width 51 -height 17 -anchor nw -bordermode ignore 
    place $base.lab25 \
        -x 235 -y 79 -width 46 -height 12 -anchor nw -bordermode ignore 
}

proc ::vTcl::findReplace::show {textWidget} {
    variable base
    variable txtbox  $textWidget
    variable index   0.0
    variable origInd [$txtbox index current]

    ## Bind the F3 key so the user can continue to find the next entry.
    bind $txtbox <Key-F3> "::vTcl::findReplace::find"

    window
}

proc ::vTcl::findReplace::find {{replace 0}} {
    variable base
    variable txtbox
    variable dir
    variable count
    variable index
    variable case
    variable wild
    variable regexp
    variable selFirst
    variable selLast

    if {!$case}  { lappend switches -nocase }
    if {!$wild}  { lappend switches -exact  }
    if {$regexp} { lappend switches -regexp }

    set up 0
    set stop end
    set start top
    if {[string compare $dir "up"] == 0 } {
	set up 1
	lappend switches -backward
	set stop 0.0
	set start bottom
    }

    lappend switches -count ::vTcl::findReplace::count --

    set text [$base.findEnt get]
    if {[llength $text] == 0} { return }

    set i [eval $txtbox search $switches $text $index $stop]
    if {[llength $i] == 0} {
	if {!$replace} {
	    set x [tk_messageBox -title "No match" -parent $base -type yesno \
		-message "   Cannot find \"$text\"\nSearch again from the $start?"]
	    if {[string compare $x "yes"] == 0} {
		set index 0.0
		if {$up} { set index end }
		::vTcl::findReplace::find
	    }
	}
	return -1
    }


    set selFirst $i
    set selLast [$txtbox index "$i + $count chars"]
    set index $selLast
    if {$up} { set index $selFirst }

    if {!$replace} {
	$txtbox tag remove sel 0.0 end
	$txtbox tag add sel $i "$i + $count chars"
	$txtbox see $i
	focus $txtbox
    }

    return $i
}

proc ::vTcl::findReplace::replace {} {
    variable base
    variable txtbox
    variable index
    variable dir
    variable selFirst
    variable selLast
    variable origInd

    set text [$base.replaceEnt get]

    while {[::vTcl::findReplace::find 1] > -1} {
	set ln [lindex [split $selFirst .] 0]
	$txtbox see $selFirst
	set x [tk_dialog .__replace__ "Match found" \
	    "Match found on line $ln\nReplace this instance?" {} 0 Yes No Cancel]

	switch $x {
	    "-1" -
	    "1"  { continue }
	    "2"  { break }
	}
	$txtbox delete $selFirst $selLast
	$txtbox insert $selFirst $text
    }

    set index 0.0
    set start top
    if {[string compare $dir "up"]} {
	set index end
	set start bottom
    }

    set text [$base.findEnt get]
    set x [tk_messageBox -title "No match found" -parent $base -type yesno \
	-message "   Cannot find \"$text\"\nSearch again from the $start?"]

    if {[vTcl:streq $x "yes"]} { ::vTcl::findReplace::replace }

    $txtbox tag remove sel 0.0 end
    $txtbox see $origInd
    focus $txtbox
}

proc ::vTcl::findReplace::replaceAll {} {
    variable base
    variable txtbox
    variable dir
    variable index
    variable selFirst
    variable selLast
    variable origInd

    set text [$base.replaceEnt get]

    while {[::vTcl::findReplace::find 1] > -1} {
	$txtbox delete $selFirst $selLast
	$txtbox insert $selFirst $text
    }

    set index 0.0
    if {[string compare $dir "up"] == 0 } { set index end }

    $txtbox tag remove sel 0.0 end
    $txtbox see $origInd
    focus $txtbox
}

proc ::vTcl::findReplace::cancel {} {
    variable base
    variable txtbox

    wm withdraw $base
    focus $txtbox
}
