##############################################################################
#
# tree.tcl - widget tree browser and associated procedures
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

set vTcl(tree,last_selected) ""
set vTcl(tree,last_yview) 0.0

proc vTcl:show_selection_in_tree {widget_path} {

    vTcl:show_selection .vTcl.tree.fra4.can8.[vTcl:rename $widget_path] \
    	$widget_path
}

proc vTcl:show_selection {button_path target} {
    global vTcl

    # do not refresh the widget tree if it does not exist
    if {![winfo exists .vTcl.tree]} return

    if {[vTcl:streq $target "."]} { return }

    vTcl:log "widget tree select: $button_path"
    set b .vTcl.tree.fra4.can8

    if {$vTcl(tree,last_selected)!=""} {
	    $b itemconfigure "TEXT$vTcl(tree,last_selected)" -fill #000000
    }

    $b itemconfigure "TEXT$button_path" -fill #ffffff

    set vTcl(tree,last_selected) $button_path
}

proc vTcl:show_wtree {} {
    global vTcl
    Window show .vTcl.tree
    vTcl:init_wtree
}

proc vTcl:clear_wtree {} {
    # Do not refresh the widget tree if it does not exist.
    if {![winfo exists .vTcl.tree]} { return }
    set b .vTcl.tree.fra4.can8
    foreach i [winfo children $b] {
        destroy $i
    }
    $b delete TEXT LINE
    $b configure -scrollregion "0 0 0 0"
}

proc vTcl:init_wtree {{wants_destroy_handles 1}} {
    global vTcl widgets classes

    # do not refresh the widget tree if it does not exist
    if {![winfo exists .vTcl.tree]} return
    if {![info exists vTcl(tree,width)]} { set vTcl(tree,width) 0 }

    set b .vTcl.tree.fra4.can8

    # save scrolling position first
    set vTcl(tree,last_yview) [lindex [$b yview] 0]

    vTcl:destroy_handles

    vTcl:clear_wtree
    set y 10
    set tree [vTcl:list_widget_tree .]
    foreach i $tree {
        if {$i == "."} {
            set depth 1
        } else {
            set depth [llength [split $i "."]]
        }
        set x [expr $depth * 30 - 15]
        set x2 [expr $x + 40]
        set y2 [expr $y + 15]
        set j [vTcl:rename $i]
        if {$i == "."} {
            set c vTclRoot
	    set t "Visual Tcl"
        } else {
	    set c [vTcl:get_class $i 1]
	    set t {}
        }
        if {![winfo exists $b.$j]} {
            set l($depth) [llength [vTcl:get_children $i]]
            if {$i == "."} {
                incr l($depth) -1
            }
            if {$depth > 1} {
                incr l([expr $depth - 1]) -1
            }
	    set cmd vTcl:show
	    if {$c == "Toplevel" || $c == "vTclRoot"} { set cmd vTcl:show_top }
            button $b.$j -image [vTcl:widget:get_image $i] -command "
                if \{\$vTcl(mode) == \"EDIT\"\} \{
                	$cmd $i
                	vTcl:active_widget $i
                	vTcl:show_selection $b.$j $i
                \}
            "
            bind $b.$j <ButtonRelease-3> "
                vTcl:active_widget $i
                vTcl:set_mouse_coords %X %Y %x %y
                $vTcl(gui,rc_menu) post %X %Y
                grab $vTcl(gui,rc_menu)
                bind $vTcl(gui,rc_menu) <ButtonRelease> {
                    grab release $vTcl(gui,rc_menu)
                     $vTcl(gui,rc_menu) unpost
                }"
            vTcl:set_balloon $b.$j $i
            $b create window $x $y -window $b.$j -anchor nw -tags $b.$j

	    if {[lempty $t]} { set t [vTcl:widget:get_tree_label $i] }

            set t [$b create text $x2 $y2 -text $t -anchor w \
		    -tags "TEXT TEXT$b.$j"]

	    set size [lindex [$b bbox $t] 2]
	    if {$size > $vTcl(tree,width)} { set vTcl(tree,width) $size }

            set d2 [expr $depth - 1]
            for {set k 1} {$k <= $d2} {incr k} {
                if {$depth > 1} {
                    set xx2 [expr $k * 30 + 15]
                    set xx1 [expr $k * 30]
                    set yy1 [expr $y + 30]
                    set yy2 [expr $y + 30 - 15]
                    if {$k == $d2} {
                        if {$l($k) > 0} {
                            $b create line $xx1 $y $xx1 $yy1 -tags LINE
                            $b create line $xx1 $yy2 $xx2 $yy2 -tags LINE
                        } else {
                            $b create line $xx1 $y $xx1 $yy2 -tags LINE
                            $b create line $xx1 $yy2 $xx2 $yy2 -tags LINE
                        }
                    } elseif {$l($k) > 0} {
                        $b create line $xx1 $y $xx1 $yy1 -tags LINE
                    }
                }
            }
        } else {
            $b coords $b.$j $x $y
        }
        incr y 30
    }
    $b configure -scrollregion "0 0 [expr $vTcl(tree,width) + 30] $y"

    if {!$wants_destroy_handles} {
        vTcl:create_handles $vTcl(w,widget)
        vTcl:place_handles $vTcl(w,widget)
    }

    # Restore scrolling position
    $b yview moveto $vTcl(tree,last_yview)
}

proc vTclWindow.vTcl.tree {args} {
    global vTcl
    set base .vTcl.tree
    if {[winfo exists .vTcl.tree]} {
        wm deiconify .vTcl.tree; return
    }
    toplevel .vTcl.tree -class vTcl
    wm transient .vTcl.tree .vTcl
    wm focusmodel .vTcl.tree passive
    wm geometry .vTcl.tree 296x243+75+142
    wm maxsize .vTcl.tree 1137 870
    wm minsize .vTcl.tree 1 1
    wm overrideredirect .vTcl.tree 0
    wm resizable .vTcl.tree 1 1
    wm deiconify .vTcl.tree
    wm title .vTcl.tree "Widget Tree"

    frame .vTcl.tree.fra11 \
    	-relief flat

    pack .vTcl.tree.fra11 \
    	-in .vTcl.tree -anchor center -expand 0 -fill both -ipadx 0 -ipady 0 \
	-padx 2 -pady 2 -side top
    frame .vTcl.tree.fra4 \
        -height 30 -width 30
    pack .vTcl.tree.fra4 \
        -in .vTcl.tree -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side top
    canvas .vTcl.tree.fra4.can8 \
        -borderwidth 2 -height 0 -highlightthickness 0 -relief ridge \
        -scrollregion {0 0 0 0} -width 0 \
        -xscrollcommand {.vTcl.tree.fra6.scr7 set} \
        -yscrollcommand {.vTcl.tree.fra4.scr9 set}
    pack .vTcl.tree.fra4.can8 \
        -in .vTcl.tree.fra4 -anchor center -expand 1 -fill both -ipadx 0 \
        -ipady 0 -padx 2 -pady 2 -side left
    scrollbar .vTcl.tree.fra4.scr9 \
        -command {.vTcl.tree.fra4.can8 yview} \
        -highlightthickness 0
    pack .vTcl.tree.fra4.scr9 \
        -in .vTcl.tree.fra4 -anchor center -expand 0 -fill y -ipadx 0 \
        -ipady 0 -padx 0 -pady 2 -side right
    frame .vTcl.tree.fra6 \
        -height 30 -width 30
    pack .vTcl.tree.fra6 \
        -in .vTcl.tree -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 \
        -padx 2 -pady 0 -side top
    scrollbar .vTcl.tree.fra6.scr7 \
        -command {.vTcl.tree.fra4.can8 xview} \
        -highlightthickness 0 -orient horizontal
    pack .vTcl.tree.fra6.scr7 \
        -in .vTcl.tree.fra6 -anchor center -expand 1 -fill both -ipadx 0 \
        -ipady 0 -padx 2 -pady 0 -side left
    frame .vTcl.tree.fra6.fra10 \
        -borderwidth 1 -height 12 -relief flat
    pack .vTcl.tree.fra6.fra10 \
        -in .vTcl.tree.fra6 -anchor center -expand 0 -fill none -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side right

    button .vTcl.tree.fra11.but3 \
        -command vTcl:init_wtree \
        -highlightthickness 0 -padx 5 -pady 2 \
	-image [vTcl:image:get_image refresh.gif]
    pack .vTcl.tree.fra11.but3 \
        -in .vTcl.tree.fra11 -anchor center -expand 0 -fill none -ipadx 0 \
        -ipady 0 -padx 2 -pady 2 -side left
    vTcl:set_balloon .vTcl.tree.fra11.but3 "Refresh the widget tree"

    button .vTcl.tree.fra11.but4 \
    	-command "wm withdraw .vTcl.tree" \
	-highlightthickness 0 \
	-image [vTcl:image:get_image ok.gif]
    pack .vTcl.tree.fra11.but4 \
    	-in .vTcl.tree.fra11 -anchor center -expand 0 -fill none -ipadx 0 \
	-ipady 0 -padx 2 -pady 2 -side right
    vTcl:set_balloon .vTcl.tree.fra11.but4 "Close"

    catch {wm geometry .vTcl.tree $vTcl(geometry,.vTcl.tree)}
    vTcl:init_wtree
    vTcl:setup_vTcl:bind .vTcl.tree
    vTcl:BindHelp .vTcl.tree WidgetTree
}
