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

    vTcl:show_selection .vTcl.tree.cpd21.03.[vTcl:rename $widget_path] \
    	$widget_path
}

proc vTcl:show_selection {button_path target} {
    global vTcl

    # do not refresh the widget tree if it does not exist
    if {![winfo exists .vTcl.tree]} return

    if {[vTcl:streq $target "."]} { return }

    vTcl:log "widget tree select: $button_path"
    set b .vTcl.tree.cpd21.03

    if {$vTcl(tree,last_selected)!=""} {
	    $b itemconfigure "TEXT$vTcl(tree,last_selected)" -fill #000000
    }

    $b itemconfigure "TEXT$button_path" -fill #0000ff

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
    set b .vTcl.tree.cpd21.03
    foreach i [winfo children $b] {
        destroy $i
    }
    $b delete TEXT LINE
    $b configure -scrollregion "0 0 0 0"
}

proc vTcl:display_widget_tree {} {

    global classes
    set tree [vTcl:list_widget_tree .]

    set result ""
    foreach i $tree {
        lappend result $i

        set childrenCmd [lindex $classes([vTcl:get_class $i],treeChildrenCmd) 0]
        if {$childrenCmd == ""} {
            continue
        }

        set children [$childrenCmd $i]
        foreach j $children {
            lappend result $j
        }
    }

    return $result
}

proc vTcl:right_click_tree {i X Y x y} {

    global vTcl

    vTcl:active_widget $i
    vTcl:set_mouse_coords $X $Y $x $y
    $vTcl(gui,rc_menu) post $X $Y
    grab $vTcl(gui,rc_menu)
    bind $vTcl(gui,rc_menu) <ButtonRelease> {
        grab release $vTcl(gui,rc_menu)
        $vTcl(gui,rc_menu) unpost
    }
}

proc vTcl:init_wtree {{wants_destroy_handles 1}} {
    global vTcl widgets classes

    # do not refresh the widget tree if it does not exist
    if {![winfo exists .vTcl.tree]} return
    if {![info exists vTcl(tree,width)]} { set vTcl(tree,width) 0 }

    set b .vTcl.tree.cpd21.03

    # save scrolling position first
    set vTcl(tree,last_yview) [lindex [$b yview] 0]

    vTcl:destroy_handles

    vTcl:clear_wtree
    set y 10
    set tree [vTcl:display_widget_tree]
    foreach ii $tree {
        set ii   [split $ii \#]
        set i    [lindex $ii 0]
        set diff [lindex $ii 1]
        if {$i == "."} {
            set depth 1
        } else {
            set depth [llength [split $i "."]]
        }
        if {$diff!=""} {set depth [expr $depth + $diff]}
        set depth_minus_one [expr $depth - 1]
        set x [expr $depth * 30 - 15]
        set x2 [expr $x + 40]
        set y2 [expr $y + 15]
        set j [vTcl:rename $i]
        if {$i == "."} {
            set c vTclRoot
            set t "Visual Tcl"
        } else {
            set c [vTcl:get_class $i]
            set t {}
        }
        if {![winfo exists $b.$j]} {

            if {$i != "." && $classes(${c},megaWidget)} {
                set childSites [lindex $classes($c,treeChildrenCmd) 1]
                if {$childSites != ""} {
                    set l($depth) [llength [$childSites $i]]
                } else {
                    set l($depth) 0
                }
            } else {
                set l($depth) [llength [vTcl:get_children $i]]
            }
            if {$i == "."} {
                incr l($depth) -1
            }
            if {$depth > 1} {
                if {[info exists l($depth_minus_one)]} {
                    incr l($depth_minus_one) -1
                } else {
                    set l($depth_minus_one) 1
                }
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
            bind $b.$j <ButtonRelease-3> "vTcl:right_click_tree $i %X %Y %x %y"
            vTcl:set_balloon $b.$j $i
            $b create window $x $y -window $b.$j -anchor nw -tags $b.$j

            if {[lempty $t]} { set t [vTcl:widget:get_tree_label $i] }

            set t [$b create text $x2 $y2 -text $t -anchor w \
                -tags "TEXT TEXT$b.$j"]

            set size [lindex [$b bbox $t] 2]
            if {$size > $vTcl(tree,width)} { set vTcl(tree,width) $size }

            set d2 $depth_minus_one
            for {set k 1} {$k <= $d2} {incr k} {
                if {![info exists l($k)]} {set l($k) 1}
                if {$depth > 1} {
                    set xx2 [expr $k * 30 + 15]
                    set xx1 [expr $k * 30]
                    set yy1 [expr $y + 30]
                    set yy2 [expr $y + 30 - 15]
                    if {$k == $d2} {
                        if {$l($k) > 0} {
                            $b create line $xx1 $y $xx1 $yy1 -tags LINE
                            $b create line $xx1 $yy2 $xx2 $yy2  -tags LINE
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
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    toplevel $base -class vTcl
    wm transient $base .vTcl
    wm focusmodel $base passive
    wm geometry $base 296x243+75+142
    wm maxsize $base 1137 870
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Widget Tree"

    frame $base.frameTop
    button $base.frameTop.buttonRefresh \
        -image [vTcl:image:get_image "refresh.gif"] \
        -command vTcl:init_wtree
    button $base.frameTop.buttonClose \
        -image [vTcl:image:get_image "ok.gif"] \
        -command "wm withdraw .vTcl.tree"
    frame $base.cpd21 -relief raised
    scrollbar $base.cpd21.01 \
        -command "$base.cpd21.03 xview" -orient horizontal
    scrollbar $base.cpd21.02 \
        -command "$base.cpd21.03 yview"
    canvas $base.cpd21.03 \
        -background #ffffff -borderwidth 2 -closeenough 1.0 -relief sunken \
        -xscrollcommand "$base.cpd21.01 set" \
        -yscrollcommand "$base.cpd21.02 set"

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.frameTop \
        -in $base -anchor center -expand 0 -fill x -side top
    pack $base.frameTop.buttonRefresh \
        -in $base.frameTop -anchor center -expand 0 -fill none -side left
    pack $base.frameTop.buttonClose \
        -in $base.frameTop -anchor center -expand 0 -fill none -side right
    pack $base.cpd21 \
        -in $base -anchor center -expand 1 -fill both -side top
    grid columnconf $base.cpd21 0 -weight 1
    grid rowconf $base.cpd21 0 -weight 1
    grid $base.cpd21.01 \
        -in $base.cpd21 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew
    grid $base.cpd21.02 \
        -in $base.cpd21 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns
    grid $base.cpd21.03 \
        -in $base.cpd21 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw

    vTcl:set_balloon $base.frameTop.buttonRefresh "Refresh the widget tree"
    vTcl:set_balloon $base.frameTop.buttonClose   "Close"

    catch {wm geometry .vTcl.tree $vTcl(geometry,.vTcl.tree)}
    vTcl:init_wtree
    vTcl:setup_vTcl:bind $base
    vTcl:BindHelp $base WidgetTree
}
