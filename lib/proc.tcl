##############################################################################
#
# proc.tcl - procedures for manipulating proctions and the proction browser
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

proc vTcl:delete_proc {name} {
    global vTcl
    set result [tk_messageBox -type yesno \
        -title "Visual Tcl" \
        -message "Are you sure you want to delete procedure $name ?"]

    if {$result == "no"} {
        return
    }

    if {$name != ""} {
        rename $name ""
        vTcl:list delete "{$name}" vTcl(procs)
        vTcl:update_proc_list
    }
}

proc vTcl:find_new_procs {} {
    global vTcl
    return [vTcl:diff_list $vTcl(start,procs) [info procs]]
}

proc vTcl:proc:get_args { name } {
    set args {}
    if {$name != ""} {
        foreach j [info args $name] {
            if {[info default $name $j def]} {
                lappend args [list $j $def]
            } else {
                lappend args $j
            }
        }
    }
    return $args
}

proc vTcl:show_proc {name} {
    global vTcl
    if {$name != ""} {
        set args [vTcl:proc:get_args $name]
        set body [string trim [info body $name] "\n"]
        set win .vTcl.proc_[vTcl:rename $name]
        Window show .vTcl.proc $win $name $args $body
    } else {
        Window show .vTcl.proc .vTcl.proc_new "" "" "global widget\n\n"
    }
}

proc vTcl:proclist:show {{on ""}} {
    global vTcl
    if {$on == "flip"} { set on [expr - $vTcl(pr,show_func)] }
    if {$on == ""}     { set on $vTcl(pr,show_func) }
    if {$on == 1} {
        Window show $vTcl(gui,proclist)
        vTcl:update_proc_list
    } else {
        Window hide $vTcl(gui,proclist)
    }
    set vTcl(pr,show_func) $on
}

proc vTcl:update_proc {base} {
    global vTcl
    set vTcl(pr,geom_proc) [wm geometry $base]
    set name [$base.f2.f8.procname get]
    set args [$base.f2.f9.args get]
    set body [string trim [$base.f4.text get 0.0 end] "\n"]
    if {[lempty $name]} { return }
    if {[regexp (.*):: $name matchAll context]} {

	# create new namespace if necessary
	namespace eval ${context} {}
    }

    proc $name $args $body

    vTcl:list add "{$name}" vTcl(procs)
    grab release $base
    destroy $base
    vTcl:update_proc_list $name
    ::vTcl::change
}

proc vTcl:update_proc_list {{name {}}} {
    global vTcl
    if {![winfo exists $vTcl(gui,proclist)]} { return }
    $vTcl(gui,proclist).f2.list delete 0 end
    foreach i [lsort $vTcl(procs)] {
	if {![vTcl:valid_procname $i]} { continue }
	if {[info body $i] != "" || $i == "main" || $i == "init"} {
	    $vTcl(gui,proclist).f2.list insert end $i
	}
    }
    if {$name != ""} {
        set plist [$vTcl(gui,proclist).f2.list get 0 end]
        set pindx [lsearch $plist $name]
        if {$pindx >= 0} {
            $vTcl(gui,proclist).f2.list selection set $pindx
            $vTcl(gui,proclist).f2.list see $pindx
        }
    }
}

# kc: during File->Open or File->Source, determine if we should keep
# record of proc $name.  Used to exclude tix procs that get defined as a
# byproduct of creating tix widgets.
#
# returns:
#   1 if should be ignored, 0 if should be kept
#
proc vTcl:ignore_procname_when_sourcing {name} {
    global vTcl
    if [regexp "^($vTcl(proc,ignore))" $name] {
        return 1
    } else {
        return 0
    }
}

# kc: during File->Save, determine if proc $name should be saved.  Used
# to prevent global tk and tix functions from being saved.
#
# returns:
#   1 if should be ignored, 0 if saved
#
proc vTcl:ignore_procname_when_saving {name} {
    global vTcl
    set len [expr [string length $vTcl(winname)] - 1]
    if {[regexp "^($vTcl(proc,ignore))" $name] \
            || ([string range $name 0 $len] == "$vTcl(winname)")} {
        return 1
    } else {
        return 0
    }
}

# kc: for backward compatibility
proc vTcl:valid_procname {name} {

    # include namespace procedures
    if {[string match *::* $name]} {
	return 1
    }

    return [expr ![vTcl:ignore_procname_when_saving $name]]
}

proc vTclWindow.vTcl.proclist {args} {
    global vTcl
    set base .vTcl.proclist
    if { [winfo exists $base] } { wm deiconify $base; return }
    toplevel $base -class vTcl
    wm transient $base .vTcl
    wm focusmodel $base passive
    wm geometry $base 200x200+48+237
    wm maxsize $base 1137 870
    wm minsize $base 200 100
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Function List"
    wm protocol $base WM_DELETE_WINDOW {vTcl:proclist:show 0}
    frame $base.frame7 \
        -borderwidth 1 -height 30 -relief sunken -width 30
    pack $base.frame7 \
        -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side top
    vTcl:toolbar_button $base.frame7.button8 \
        -command {vTcl:show_proc ""} \
        -image [vTcl:image:get_image add.gif]
    pack $base.frame7.button8 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    vTcl:set_balloon $base.frame7.button8 "Add a new procedure"
    vTcl:toolbar_button $base.frame7.button9 \
        -command {
            set vTcl(x) [.vTcl.proclist.f2.list curselection]
            if {$vTcl(x) != ""} {
                vTcl:show_proc [.vTcl.proclist.f2.list get $vTcl(x)]
            }
        } \
        -image [vTcl:image:get_image open.gif]
    pack $base.frame7.button9 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    vTcl:set_balloon $base.frame7.button9 "Edit selected procedure"
    vTcl:toolbar_button $base.frame7.button10 \
        -command {
            set vTcl(x) [.vTcl.proclist.f2.list curselection]
            if {$vTcl(x) != ""} {
                vTcl:delete_proc [.vTcl.proclist.f2.list get $vTcl(x)]
            }
        } \
        -image [vTcl:image:get_image remove.gif]
    pack $base.frame7.button10 \
        -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    vTcl:set_balloon $base.frame7.button10 "Remove selected procedure"
    vTcl:toolbar_button $base.frame7.button11 \
        -command "wm withdraw $base" \
        -image [vTcl:image:get_image ok.gif]
    pack $base.frame7.button11 \
        -expand 0 -side right
    vTcl:set_balloon $base.frame7.button11 "Close"
    frame $base.f2 \
        -borderwidth 1 -height 30 -relief sunken -width 30
    pack $base.f2 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side top
    listbox $base.f2.list \
        -yscrollcommand {.vTcl.proclist.f2.sb4  set} \
        -background white
    bind $base.f2.list <Double-Button-1> {
        set vTcl(x) [.vTcl.proclist.f2.list curselection]
        if {$vTcl(x) != ""} {
            vTcl:show_proc [.vTcl.proclist.f2.list get $vTcl(x)]
        }
    }
    pack $base.f2.list \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    scrollbar $base.f2.sb4 \
        -command "$base.f2.list yview"
    pack $base.f2.sb4 \
        -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side right

    wm withdraw $vTcl(gui,proclist)
    vTcl:setup_vTcl:bind $vTcl(gui,proclist)
    catch {wm geometry $vTcl(gui,proclist) $vTcl(geometry,$vTcl(gui,proclist))}
    update idletasks
    wm deiconify $vTcl(gui,proclist)

    vTcl:BindHelp $vTcl(gui,proclist) FunctionList
}

proc vTclWindow.vTcl.proc {args} {
    global vTcl
    set base  [lindex $args 0]
    set title [lindex $args 1]
    set iproc [lindex $args 1]
    set iargs [lindex $args 2]
    set ibody [lindex $args 3]
    if { [winfo exists $base] } { wm deiconify $base; return }
    set vTcl(proc,[lindex $args 0],chg) 0
    toplevel $base -class vTcl
    wm transient $base .vTcl
    wm focusmodel $base passive
    wm geometry $base $vTcl(pr,geom_proc)
    wm maxsize $base 1137 870
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "$title"
    bind $base <Key-Escape> "vTcl:update_proc $base"
    frame $base.f2 -height 30 -width 30
    pack $base.f2 \
        -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 3 -pady 3 \
        -side top
    frame $base.f2.f8 -height 30 -width 30 -relief flat
    pack $base.f2.f8 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side top
    label $base.f2.f8.label10 -anchor w  \
        -relief flat -text Function -width 9
    pack $base.f2.f8.label10 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 0 \
        -side left
    vTcl:entry $base.f2.f8.procname \
        -cursor {}  \
        -highlightthickness 0 -bg white
    pack $base.f2.f8.procname \
        -anchor center -expand 1 -fill x -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left
    frame $base.f2.f9 \
        -height 30 -width 30 -relief flat
    pack $base.f2.f9 \
        -anchor center -expand 0 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side top
    label $base.f2.f9.label12 \
        -anchor w  \
        -relief flat -text Arguments -width 9
    pack $base.f2.f9.label12 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 0 \
        -side left
    vTcl:entry $base.f2.f9.args \
        -cursor {}  \
        -highlightthickness 0 -bg white
    pack $base.f2.f9.args \
        -anchor center -expand 1 -fill x -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left
    frame $base.f3 \
        -borderwidth 2 -relief flat
    pack $base.f3 \
        -anchor center -expand 0 -fill x -side top

    # toolbar
    frame $base.f3.toolbar
    pack $base.f3.toolbar -side top -anchor nw -fill x

    set butInsert [vTcl:formCompound:add $base.f3.toolbar vTcl:toolbar_button \
        -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) images edit inswidg.gif] ] \
        -command "vTcl:insert_widget_in_text $base.f4.text" ]
    pack configure $butInsert -side left
    vTcl:set_balloon $butInsert "Insert selected widget command"

    set last [vTcl:formCompound:add $base.f3.toolbar frame -width 5]
    pack configure $last -side left

    set last [vTcl:formCompound:add $base.f3.toolbar vTcl:toolbar_button \
        -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) images edit copy.gif] ] \
        -command "tk_textCopy $base.f4.text"]
    pack configure $last -side left
    vTcl:set_balloon $last "Copy selected text to clipboard"

    set last [vTcl:formCompound:add $base.f3.toolbar vTcl:toolbar_button \
        -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) images edit cut.gif] ]  \
        -command "tk_textCut $base.f4.text"]
    pack configure $last -side left
    vTcl:set_balloon $last "Cut selected text"

    set last [vTcl:formCompound:add $base.f3.toolbar vTcl:toolbar_button \
        -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) images edit paste.gif] ]  \
        -command "tk_textPaste $base.f4.text"]
    pack configure $last -side left
    vTcl:set_balloon $last "Paste text from clipboard"

    set last [vTcl:formCompound:add $base.f3.toolbar frame -width 5]
    pack configure $last -side left

    set butFind [vTcl:formCompound:add $base.f3.toolbar vTcl:toolbar_button \
        -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) images edit search.gif] ] \
	-command "::vTcl::findReplace::show $base.f4.text"]
    pack configure $butFind -side left
    vTcl:set_balloon $butFind "Find/Replace"

    set butCancel [vTcl:formCompound:add $base.f3.toolbar vTcl:toolbar_button \
        -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) images edit remove.gif] ]  \
        -command "vTcl:proc:edit_cancel $base"]
    pack configure $butCancel -side right
    vTcl:set_balloon $butCancel "Discard changes"

    set butOK [vTcl:formCompound:add $base.f3.toolbar vTcl:toolbar_button \
        -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) images edit ok.gif] ]  \
        -command "vTcl:update_proc $base"]
    pack configure $butOK -side right
    vTcl:set_balloon $butOK "Save changes"

    frame $base.f4 \
        -borderwidth 1 -height 30 -relief sunken -width 30
    scrollbar $base.f4.01 \
        -command "$base.f4.text xview" -highlightthickness 0 \
        -orient horizontal
    scrollbar $base.f4.02 \
        -command "$base.f4.text yview" -highlightthickness 0
    text $base.f4.text \
        -background white -borderwidth 0 -height 3 -wrap none \
        -relief flat -xscrollcommand "$base.f4.01 set" \
        -yscrollcommand "$base.f4.02 set"
    pack $base.f4 \
        -in "$base" -anchor center -expand 1 -fill both -side top
    grid columnconf $base.f4 0 -weight 1
    grid rowconf $base.f4 0 -weight 1
    grid $base.f4.01 \
        -in "$base.f4" -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew
    grid $base.f4.02 \
        -in "$base.f4" -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns
    grid $base.f4.text \
        -in "$base.f4" -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw

    bind $base.f4.text <KeyPress> "+::vTcl::proc_edit_change $base %K"
    bind $base.f4.text <Control-Key-i> "$butInsert invoke"
    bind $base.f4.text <Control-Key-f> "$butFind invoke"
    bind $base <Destroy> {
	if {[winfo exists .vTcl.find]} { destroy .vTcl.find }
    }

    set pname $base.f2.f8.procname
    set pargs $base.f2.f9.args
    set pbody $base.f4.text
    $pname delete 0 end
    $pargs delete 0 end
    $pbody delete 0.0 end
    $pname insert end $iproc
    $pargs insert end $iargs
    $pbody insert end $ibody
    $pbody mark set insert 0.0
    if {$iproc == ""} {
        focus $pname
        $butOK configure -state disabled
    } else {
        focus $pbody
    }

    # don't allow empty procedure name
    bind $pname <KeyRelease> "\
    	if \{\[$pname get\] == \"\"\} \{ \
    	      $butOK configure -state disabled \
    	\} else \{ \
    	      $butOK configure -state normal \
    	\}"

    # @@change by Christian Gavin 3/19/2000
    # syntax colouring

    vTcl:syntax_color $base.f4.text

    # @@end_change
}

proc vTcl:proc:edit_cancel {base} {
    global vTcl
    if {$vTcl(proc,$base,chg) == 0} {
        grab release $base
    	set vTcl(pr,geom_proc) [wm geometry $base]
        destroy $base
    } else {
        set result [tk_messageBox -default yes -icon question -message \
            "Buffer has changed. Do you wish to save the changes?" \
            -parent $base -title "Save Changes?" -type yesnocancel]
        switch $result {
            no {
                grab release $base
                destroy $base
            }
            yes {
                vTcl:update_proc $base
            }
            cancel {}
        }
    }
}

proc ::vTcl::proc_edit_change {w k} {
    ## We don't want to mark the text as changed when we're just moving around.
    switch -- $k {
	"Up"	-
	"Down"	-
	"Right"	-
	"Left"	-
	"Prior"	-
	"Next"	-
	"Home"	-
	"End"	-
	"Insert" -
	"Delete" { return }
    }
    global vTcl
    set vTcl(proc,$w,chg) 1
}
