##############################################################################
#
# input.tcl - procedures for prompting windowed string input
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

proc vTcl:get_string {title target {value ""}} {
    global vTcl
    set tmpname .vTcl.[vTcl:rename $target]
    set vTcl(x,$tmpname) ""
    vTcl:string_window $title $tmpname $value
    tkwait window $tmpname
    return $vTcl(x,$tmpname)
}

proc vTcl:set_string {base str} {
    global vTcl
    set vTcl(x,$base) $str
    grab release $base
    destroy $base
}

proc vTcl:snarf_string {base} {
    global vTcl
    vTcl:set_string $base "[$base.ent18 get]"
}

proc vTcl:string_window {title base {value ""}} {
    global vTcl

    vTcl:check_mouse_coords

    toplevel $base
    wm transient $base .vTcl
    wm focusmodel $base passive
    wm geometry $base 225x49+[expr $vTcl(mouse,X)-120]+[expr $vTcl(mouse,Y)-20]
    wm maxsize $base 500 870
    wm minsize $base 225 1
    wm overrideredirect $base 0
    wm resizable $base 1 0
    wm deiconify $base
    wm title $base "$title"
    frame $base.fra19 \
        -borderwidth 1 -height 30 -relief sunken -width 30
    pack $base.fra19 \
        -in $base -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side top
    ::vTcl::CancelButton $base.fra19.but21 -command "
	$base.ent18 delete 0 end
	vTcl:set_string \{$base\} \{$value\}
    "
    pack $base.fra19.but21 \
        -in $base.fra19 -anchor center -expand 0 -fill none -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side right
    ::vTcl::OkButton $base.fra19.but20 -command "vTcl:snarf_string \{$base\}"
    pack $base.fra19.but20 \
        -in $base.fra19 -anchor center -expand 0 -fill none -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side right
    vTcl:entry $base.ent18 \
        -cursor {} -background white
    pack $base.ent18 \
        -in $base -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side top
    bind $base <Key-Return> "vTcl:snarf_string \{$base\}; break"
    bind $base <Key-Escape> "$base.fra19.but21 invoke"
    $base.ent18 insert end $value
    update idletasks
    focus $base.ent18
    grab $base
}

proc vTcl:set_text {target} {
    global vTcl
    set base .vTcl.[vTcl:rename $target]
    vTcl:text_window $base "Set Text" $target
    tkwait window $base

    ## They closed it without hitting the done button.  Just forget it.
    if {![info exists vTcl(x,$base)]} { return }

    $target configure -text $vTcl(x,$base)
    unset vTcl(x,$base)
    vTcl:create_handles $target
}

proc vTcl:get_text {base text} {
    global vTcl

    ## Remove the last character which is a \n the text widget puts in for
    ## some reason.
    set string [$text get 0.0 end]
    set end [expr [string length $string] - 1]
    set vTcl(x,$base) [string range $string 0 [expr $end - 1]]
    destroy $base
}

proc vTcl:text_window {base title target} {
    global vTcl
    toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm geometry $base 274x289+[expr $vTcl(mouse,X)-130]+[expr $vTcl(mouse,Y)-20]
    wm maxsize $base 1265 994
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base $title

    frame $base.cpd48 \
        -borderwidth 1 -height 245 -relief raised -width 262
    scrollbar $base.cpd48.01 \
        -command "$base.cpd48.03 xview" -orient horizontal
    scrollbar $base.cpd48.02 \
        -command "$base.cpd48.03 yview"
    text $base.cpd48.03 \
        -width 8 -xscrollcommand "$base.cpd48.01 set" \
        -yscrollcommand "$base.cpd48.02 set" -background white

    # avoid syntax coloring here (automatic for text widgets in vTcl)
    global $base.cpd48.03.nosyntax
    set $base.cpd48.03.nosyntax 1

    frame $base.butfr

    ::vTcl::OkButton $base.butfr.but52 \
	-command "vTcl:get_text $base $base.cpd48.03"
    vTcl:set_balloon $base.butfr.but52 "Save Changes"

    ::vTcl::CancelButton $base.butfr.but53 -command "destroy $base"
    vTcl:set_balloon $base.butfr.but53 "Discard Changes"

    bind $base <Key-Escape> "$base.butfr.but53 invoke"

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.butfr -side top -anchor e
    pack $base.butfr.but53 -side right
    pack $base.butfr.but52 -side right
    pack $base.cpd48 -fill both -expand 1

    grid columnconf $base.cpd48 0 -weight 1
    grid rowconf $base.cpd48 0 -weight 1
    grid $base.cpd48.01 \
        -in $base.cpd48 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew
    grid $base.cpd48.02 \
        -in $base.cpd48 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns
    grid $base.cpd48.03 \
        -in $base.cpd48 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw 

    $base.cpd48.03 insert end [$target cget -text]
    focus $base.cpd48.03
}
