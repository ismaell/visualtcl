##############################################################################
#
# tops.tcl - procedures for managing toplevel windows
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

proc vTcl:wm_take_focus {target} {
    global vTcl
    if {$vTcl(w,class) == "Toplevel"} {
        set vTcl(w,insert) $target
    }

    after idle "vTcl:place_handles \"$vTcl(w,widget)\""
}

proc vTcl:destroy_top {target} {
    global vTcl

    vTcl:active_widget $target
    vTcl:delete

    return [expr ![winfo exists $target]]
}

proc vTcl:show_top {target} {
    global vTcl
    if {[vTcl:streq $target "."]} { return }
    if [winfo exists $target] {
        if {[vTcl:get_class $target] == "Toplevel"} {
            wm deiconify $target
            raise $target
        }
    } else {
        Window show $target
        wm deiconify $target
        raise $target
        vTcl:widget:register_all_widgets $target
        vTcl:setup_bind_tree $target
        vTcl:update_top_list
        vTcl:init_wtree
    }
    vTcl:select_widget $target
    vTcl:destroy_handles
}

proc vTcl:hide_top {target} {
    global vTcl
    if [winfo exists $target] {
        if {[vTcl:get_class $target] == "Toplevel"} {
            wm withdraw $target
            vTcl:select_widget .
        }
    }
}

proc vTcl:update_top_list {} {
    global vTcl
    if [winfo exists .vTcl.toplist] {
        .vTcl.toplist.f2.list delete 0 end
        set index 0
        foreach i $vTcl(tops) {
            if [catch {set n [wm title $i]}] {
                set n $i
            }
            .vTcl.toplist.f2.list insert end $n
            set vTcl(tops,$index) $i
            incr index
        }
    }
}

# convert hidden toplevels from a 1.22 project to a 1.51 project
proc vTcl:convert_tops {} {

    global vTcl

    foreach i $vTcl(tops) {
        if {![winfo exists $i]} {
            # this is to convert 1.22 projects to 1.51
            # 1.51 hidden toplevels exist but are hidden
            # 1.2x hidden toplevels don't exist at all except
            # their proc
            vTcl:show_top $i
            vTcl:hide_top $i
        }
    }
}

proc vTcl:toplist:show {{on ""}} {
    global vTcl
    if {$on == "flip"} { set on [expr - $vTcl(pr,show_top)] }
    if {$on == ""}     { set on $vTcl(pr,show_top) }
    if {$on == 1} {
        Window show $vTcl(gui,toplist)
        vTcl:update_top_list
    } else {
        Window hide $vTcl(gui,toplist)
    }
    set vTcl(pr,show_top) $on
}

proc vTclWindow.vTcl.toplist {args} {
    global vTcl
    set base .vTcl.toplist
    if {[winfo exists .vTcl.toplist]} {
        wm deiconify .vTcl.toplist; return
    }
    toplevel .vTcl.toplist -class vTcl
    wm withdraw .vTcl.toplist
    wm transient .vTcl.toplist .vTcl
    wm focusmodel .vTcl.toplist passive
    wm geometry .vTcl.toplist 200x200+714+382
    wm maxsize .vTcl.toplist 1137 870
    wm minsize .vTcl.toplist 200 100
    wm overrideredirect .vTcl.toplist 0
    wm resizable .vTcl.toplist 1 1
    wm title .vTcl.toplist "Window List"
    wm protocol $base WM_DELETE_WINDOW {vTcl:toplist:show 0}
    bind .vTcl.toplist <Double-Button-1> {
        set vTcl(x) [.vTcl.toplist.f2.list curselection]
        if {$vTcl(x) != ""} {
            vTcl:show_top $vTcl(tops,$vTcl(x))
        }
    }

    frame .vTcl.toplist.frame7 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    pack .vTcl.toplist.frame7 \
        -in .vTcl.toplist -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side top 
    button .vTcl.toplist.frame7.button8 \
        -command {
            set vTcl(x) [.vTcl.toplist.f2.list curselection]
            if {$vTcl(x) != ""} {
                vTcl:show_top $vTcl(tops,$vTcl(x))
            }
        } \
         -padx 9 \
        -pady 3 -image [vTcl:image:get_image show.gif]
    pack .vTcl.toplist.frame7.button8 \
        -in .vTcl.toplist.frame7 -anchor center -expand 0 -fill none -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left 
    vTcl:set_balloon .vTcl.toplist.frame7.button8 "Show toplevel window"
    button .vTcl.toplist.frame7.button9 \
        -command {
            set vTcl(x) [.vTcl.toplist.f2.list curselection]
            if {$vTcl(x) != ""} {
                vTcl:hide_top $vTcl(tops,$vTcl(x))
            }
        } \
         -padx 9 \
        -pady 3 -image [vTcl:image:get_image hide.gif]
    pack .vTcl.toplist.frame7.button9 \
        -in .vTcl.toplist.frame7 -anchor center -expand 0 -fill none -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left
    vTcl:set_balloon .vTcl.toplist.frame7.button9 "Hide toplevel window"
    button .vTcl.toplist.frame7.button10 \
        -command {
            set vTcl(x) [.vTcl.toplist.f2.list curselection]
            if {$vTcl(x) != ""} {
                if {[vTcl:destroy_top $vTcl(tops,$vTcl(x))]} {
		    .vTcl.toplist.f2.list delete $vTcl(x)
		}
            }
        } \
         -padx 9 \
        -pady 3 -image [vTcl:image:get_image remove.gif]
    pack .vTcl.toplist.frame7.button10 \
        -in .vTcl.toplist.frame7 -anchor center -expand 0 -fill none -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left
    vTcl:set_balloon .vTcl.toplist.frame7.button10 "Delete toplevel window"
    button $base.frame7.button11 \
    	-command "vTcl:toplist:show 0" \
	-image [vTcl:image:get_image ok.gif]
    pack $base.frame7.button11 \
    	-expand 0 -side right
    vTcl:set_balloon $base.frame7.button11 "Close"

    frame .vTcl.toplist.f2 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    pack .vTcl.toplist.f2 \
        -in .vTcl.toplist -anchor center -expand 1 -fill both -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side top
    listbox .vTcl.toplist.f2.list \
        -yscrollcommand {.vTcl.toplist.f2.sb4 set} -exportselection 0 \
        -background white
    pack .vTcl.toplist.f2.list \
        -in .vTcl.toplist.f2 -anchor center -expand 1 -fill both -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left
    scrollbar .vTcl.toplist.f2.sb4 \
        -command {.vTcl.toplist.f2.list yview}
    pack .vTcl.toplist.f2.sb4 \
        -in .vTcl.toplist.f2 -anchor center -expand 0 -fill y -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side right

    vTcl:setup_vTcl:bind .vTcl.toplist
    catch {wm geometry .vTcl.toplist $vTcl(geometry,.vTcl.toplist)}
    update idletasks
    wm deiconify .vTcl.toplist

    # ok, let's add a special tag to override the <KeyPress-Delete> mechanism

    # first, make sure the list gets the focus when it's clicked on
    bind .vTcl.toplist.f2.list <ButtonPress-1> {
        focus .vTcl.toplist.f2.list
    }

    # bind all controls in the window
    foreach child [vTcl:list_widget_tree .vTcl.toplist] {
        bindtags $child "_vTclTopDelete [bindtags $child]"
    }

    bind _vTclTopDelete <KeyPress-Delete> {
        .vTcl.toplist.frame7.button10 invoke

        # stop event processing here
        break
    }
}
