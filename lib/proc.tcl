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
    set body [string trim [$base.f3.text get 0.0 end] "\n"]
    if {$name != ""} {

        if {[regexp (.*):: $name matchAll context]} {

            # create new namespace if necessary
	    namespace eval ${context} {}
	}

        proc $name $args $body
    } else {
    	# user hasn't entered a proc name yet
    	return
    }
    vTcl:list add "{$name}" vTcl(procs)
    grab release $base
    destroy $base
    vTcl:update_proc_list $name
}

proc vTcl:update_proc_list {{name {}}} {
    global vTcl
    if { [winfo exists $vTcl(gui,proclist)] == 0 } { return }
    $vTcl(gui,proclist).f2.list delete 0 end
    foreach i [lsort $vTcl(procs)] {
        if {[vTcl:valid_procname $i] == 1} {
            if {[info body $i] != "" || $i == "main" || $i == "init"} {
                $vTcl(gui,proclist).f2.list insert end $i
            }
        }
    }
    if {$name != ""} {
        set plist [$vTcl(gui,proclist).f2.list get 0 end]
        set pindx [lsearch $plist $name]
        if {$pindx >= 0} {
        $vTcl(gui,proclist).f2.list selection set $pindx
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
        -side bottom
    button $base.frame7.button8 \
        -command {vTcl:show_proc ""} \
         -padx 9 \
        -pady 3 -text Add -width 4
    pack $base.frame7.button8 \
        -anchor center -expand 1 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    button $base.frame7.button9 \
        -command {
            set vTcl(x) [.vTcl.proclist.f2.list curselection]
            if {$vTcl(x) != ""} {
                vTcl:show_proc [.vTcl.proclist.f2.list get $vTcl(x)]
            }
        } \
        -padx 9 \
        -pady 3 -text Edit -width 4
    pack $base.frame7.button9 \
        -anchor center -expand 1 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    button $base.frame7.button10 \
        -command {
            set vTcl(x) [.vTcl.proclist.f2.list curselection]
            if {$vTcl(x) != ""} {
                vTcl:delete_proc [.vTcl.proclist.f2.list get $vTcl(x)]
            }
        } \
        -padx 9 \
        -pady 3 -text Delete -width 4
    pack $base.frame7.button10 \
        -anchor center -expand 1 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    button $base.frame7.button11 \
        -command { vTcl:proclist:show 0 }\
         -padx 9 -pady 3 -text Done -width 4
    pack $base.frame7.button11 \
        -anchor center -expand 1 -fill x -side left
    frame $base.f2 \
        -borderwidth 1 -height 30 -relief sunken -width 30
    pack $base.f2 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side top
    listbox $base.f2.list \
        -yscrollcommand {.vTcl.proclist.f2.sb4  set}
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
}

proc vTclWindow.vTcl.proc {args} {
    global vTcl
    set base "[lindex $args 0]"
    set title "[lindex $args 1]"
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
    frame $base.f2.f8 -height 30 -width 30
    pack $base.f2.f8 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side top
    label $base.f2.f8.label10 -anchor w  \
        -relief groove -text Function -width 9
    pack $base.f2.f8.label10 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 0 \
        -side left
    entry $base.f2.f8.procname \
        -cursor {}  \
        -highlightthickness 0
    pack $base.f2.f8.procname \
        -anchor center -expand 1 -fill x -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left
    frame $base.f2.f9 \
        -height 30 -width 30
    pack $base.f2.f9 \
        -anchor center -expand 0 -fill both -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side top
    label $base.f2.f9.label12 \
        -anchor w  \
        -relief groove -text Arguments -width 9
    pack $base.f2.f9.label12 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 0 \
        -side left
    entry $base.f2.f9.args \
        -cursor {}  \
        -highlightthickness 0
    pack $base.f2.f9.args \
        -anchor center -expand 1 -fill x -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left
    frame $base.f3 \
        -borderwidth 2 -height 30 -relief groove -width 30
    pack $base.f3 \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 3 -pady 3 \
        -side top

    # @@change by Christian Gavin 3/13/2000
    # button to insert the complete name of the currently selected
    # widget
    button $base.f3.butInsert \
        -text "Insert selected widget name" \
        -command "vTcl:insert_widget_in_text $base.f3.text"
    pack $base.f3.butInsert -fill x -side top
    # @@end_change

    text $base.f3.text \
        -height 7 -highlightthickness 0 -width 16 \
        -wrap none -yscrollcommand "$base.f3.scrollbar4 set" \
        -background white
    pack $base.f3.text \
        -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left
    bind $base.f3.text <KeyPress> "+set vTcl(proc,[lindex $args 0],chg) 1"
    scrollbar $base.f3.scrollbar4 \
        -command "$base.f3.text yview"
    pack $base.f3.scrollbar4 \
        -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    frame $base.frame14 \
        -borderwidth 1 -height 30 -relief sunken -width 30
    pack $base.frame14 \
        -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 -padx 3 -pady 3 \
        -side top
    button $base.frame14.button15 \
        -command "vTcl:update_proc $base" \
        -padx 9 -pady 3 -text OK -width 5
    pack $base.frame14.button15 \
        -anchor center -expand 1 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left
    button $base.frame14.button16 \
        -command "vTcl:proc:edit_cancel $base" \
         -padx 9 \
        -pady 3 -text Cancel -width 5
    pack $base.frame14.button16 \
        -anchor center -expand 1 -fill x -ipadx 0 -ipady 0 -padx 0 -pady 0 \
        -side left

    set pname $base.f2.f8.procname
    set pargs $base.f2.f9.args
    set pbody $base.f3.text
    $pname delete 0 end
    $pargs delete 0 end
    $pbody delete 0.0 end
    $pname insert end $iproc
    $pargs insert end $iargs
    $pbody insert end $ibody
    $pbody mark set insert 0.0
    if {$iproc == ""} {
        focus $pname
        $base.frame14.button15 configure -state disabled
    } else {
        focus $pbody
    }

    # don't allow empty procedure name
    bind $pname <KeyRelease> "\
    	if \{\[$pname get\] == \"\"\} \{ \
    	      $base.frame14.button15 configure -state disabled \
    	\} else \{ \
    	      $base.frame14.button15 configure -state normal \
    	\}"

    # @@change by Christian Gavin 3/19/2000
    # syntax colouring

    vTcl:syntax_color $base.f3.text

    # @@end_change
}

proc vTcl:proc:edit_cancel {base} {
    global vTcl
    if {$vTcl(proc,$base,chg) == 0} {
        grab release $base
    	set vTcl(pr,geom_proc) [wm geometry $base]
        destroy $base
    } else {
        vTcl:dialog "Buffer has changed. Do you\nwish to save the changes?" {Yes No Cancel}
        switch $vTcl(x_mesg) {
            No {
                grab release $base
                destroy $base
            }
            Yes {
                vTcl:update_proc $base
            }
            Cancel {}
        }
    }
}


