##############################################################################
#
# menus.tcl procedures to edit application menus
#
# Copyright (C) 2000 Christian Gavin
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
#
##############################################################################

namespace eval ::menu_edit {

    # this contains a list of currently open menu editors
    variable menu_edit_windows ""

    proc {::menu_edit::delete_item} {top} {
        global widget

        set ::${top}::current_menu ""
        set ::${top}::current_index ""

        # this proc deletes the currently selected menu item

        set indices [$top.MenuListbox curselection]
        set index [lindex $indices 0]

        if {$index == ""} return

        set listboxitems [vTcl:at ::${top}::listboxitems]

        set reference [lindex $listboxitems $index]

        set menu [lindex $reference end-1]
        set pos  [lindex $reference end]

        if {$pos != -1} {
            set mtype [$menu type $pos]

            if {$mtype == "cascade"} {
                set submenu [$menu entrycget $pos -menu]
                ::menu_edit::delete_menu_recurse $submenu
            }

            $menu delete $pos
        }

        ::menu_edit::fill_menu_list $top [vTcl:at ::${top}::menu]
    }

    proc {::menu_edit::delete_menu_recurse} {menu} {
        global widget vTcl

        # unregister
        catch {namespace delete ::widgets::$menu} error

        set last [$menu index end]

        while {$last != "none"} {

            set mtype [$menu type $last]

            if {$mtype == "cascade"} {
                set submenu [$menu entrycget $last -menu]
                ::menu_edit::delete_menu_recurse $submenu
            }

            if {$mtype == "tearoff"} {
                $menu configure -tearoff 0
            } else {
                $menu delete $last
            }

            set last [$menu index end]
        }

        destroy $menu
    }

    proc {::menu_edit::enable_editor} {top enable} {

        global widget

        set ctrls "$top.EntryLabel    $top.EntryImage   $top.EntryAccelerator
                   $top.EntryVariable $top.EntryValueOn $top.EntryValueOff 
                   $top.MenuText      $top.NewMenu      $top.DeleteMenu 
                   $top.MoveMenuUp    $top.MoveMenuDown $top.BrowseImage"

        switch $enable {
            0 - false - no {
                set ::${top}::backup_bindings [bindtags $widget($top,MenuListbox)]
                bindtags $widget($top,MenuListbox) dummy
                bindtags $widget($top,NewMenu)     dummy
                $top.MenuListbox configure -background gray

                foreach ctrl $ctrls {
                    set ::${top}::$ctrl.state      [$ctrl cget -state]
                    set ::${top}::$ctrl.background [$ctrl cget -background]

                    $ctrl configure -state disabled -background gray
                }

            }
            1 - true - yes {
                foreach ctrl $ctrls {
                    if {[info exists ::${top}::$ctrl.state]} {
                        $ctrl configure -state      [vTcl:at ::${top}::$ctrl.state] \
                                        -background [vTcl:at ::${top}::$ctrl.background]
                    }
                }

                if {[info exists ::${top}::backup_bindings]} {
                    bindtags $widget($top,MenuListbox) [vTcl:at ::${top}::backup_bindings]
                }
                bindtags $widget($top,NewMenu) ""
                $top.MenuListbox configure -background white
            }
        }
    }

    proc {::menu_edit::enable_controls} {top args} {
        global widget

        foreach ctrl "$top.EntryLabel   $top.EntryImage  $top.EntryAccelerator
                    $top.EntryVariable $top.EntryValueOn $top.EntryValueOff" {

            set [$ctrl cget -textvariable] ""
        }

        $top.MenuText         delete 0.0 end

        foreach arg $args {

            set ctrl     [lindex $arg 0]
            set value    [lindex $arg 1]

            switch $value {
                0 {set newstate disabled
                set newbg    gray}
                1 {set newstate normal
                set newbg    white}
            }

            switch $ctrl {
                "label" {
                    $top.RadioLabel configure -state $newstate
                    $top.EntryLabel configure -state $newstate -bg $newbg
                }
                "image" {
                    $top.RadioImage configure -state $newstate
                    $top.EntryImage configure -state $newstate -bg $newbg
                }
                "accelerator" {
                    $top.LabelAccelerator configure -state $newstate
                    $top.EntryAccelerator configure -state $newstate \
                        -bg $newbg
                }
                "variable" {
                    $top.LabelVariable configure -state $newstate
                    $top.EntryVariable configure -state $newstate -bg $newbg
                }
                "value_on" {
                    $top.LabelValueOn configure -state $newstate
                    $top.EntryValueOn configure -state $newstate -bg $newbg
                }
                "value_off" {
                    $top.LabelValueOff configure -state $newstate
                    $top.EntryValueOff configure -state $newstate -bg $newbg
                }
                "text" {
                    $top.LabelCommand configure -state $newstate
                    $top.MenuText configure -state $newstate -bg $newbg
                }
            }
        }
    }

    proc {::menu_edit::enable_all_editors} {enable} {

        variable menu_edit_windows

        set wnds $menu_edit_windows

        foreach wnd $wnds {
            ::menu_edit::enable_editor $wnd $enable
        }
    }

    proc {::menu_edit::enable_toolbar_buttons} {top} {
        set indices [$top.MenuListbox curselection]
        set index [lindex $indices 0]

        if {$index == "" || $index == 0} {
            $top.DeleteMenu   configure -state disabled
            $top.MoveMenuUp   configure -state disabled
            $top.MoveMenuDown configure -state disabled
            return
        }

        $top.DeleteMenu   configure -state normal

        set m ""
        set i ""

        ::menu_edit::get_menu_index $top $index m i
        if {[$m cget -tearoff] == 1 && $i == 1} {
        incr i -1
        }

        if {$i == 0} {
            $top.MoveMenuUp   configure -state disabled
        } else {
            $top.MoveMenuUp   configure -state normal
        }

        if {$i < [$m index end]} {
            $top.MoveMenuDown configure -state normal
        } else {
            $top.MoveMenuDown configure -state disabled
        }
    }

    proc {::menu_edit::fill_command} {top command} {
        global widget

        $top.MenuText delete 0.0 end
        $top.MenuText insert end $command

        vTcl:syntax_color $widget($top,MenuText)
    }

    proc {::menu_edit::fill_menu} {top m {level 0} {path {}}} {

        set size [$m index end]

        if {$path == ""} {
            set path $m
        } else {
            lappend path $m
        }

        if {$size == "none"} {return}

        for {set i 0} {$i <= $size} {incr i} {

            set mtype [$m type $i]
            if {$mtype == "tearoff"} continue

            lappend ::${top}::listboxitems [concat $path $i]

            set indent "    "
            for {set j 0} {$j < $level} {incr j} {
                append indent "    "
            }

            switch -exact $mtype {
                "cascade" {
                    set tearoff ""
                    set mlabel [$m entrycget $i -label]
                    set maccel [$m entrycget $i -accel]
                    set submenu [$m entrycget $i -menu]
                    if {$submenu != ""} {
                        if {[$submenu cget -tearoff] == 1} {
                            set tearoff " ---X---"}}
                    if {$maccel != ""} {
                        $top.MenuListbox insert end \
                            "$indent${mlabel}   ($maccel)$tearoff"
                    } else {
                        $top.MenuListbox insert end "$indent${mlabel}$tearoff"
                    }
                    if {$submenu != ""} {
                        ::menu_edit::fill_menu \
                            $top $submenu [expr $level + 1] [concat $path $i]
                    }
                }
                "command" {
                    set mlabel   [$m entrycget $i -label]
                    set maccel   [$m entrycget $i -accel]
                    set mcommand [$m entrycget $i -command]

                    if {$maccel != ""} {
                        $top.MenuListbox insert end \
                            "$indent${mlabel}   ($maccel)"
                    } else {
                        $top.MenuListbox insert end \
                            "$indent${mlabel}"
                    }
                }
                "separator" {
                    $top.MenuListbox insert end "$indent<separator>"
                }
                "radiobutton" -
                "checkbutton" {
                    set mlabel [$m entrycget $i -label]
                    set maccel [$m entrycget $i -accel]
                    if {$mtype == "radiobutton"} {
                        set prefix "o "
                    } else {
                        set prefix "x "}
                    if {$maccel != ""} {
                        $top.MenuListbox insert end \
                            "$indent$prefix${mlabel}   ($maccel)"
                    } else {
                        $top.MenuListbox insert end \
                            "$indent$prefix${mlabel}"
                    }
                }
            }
        }
    }

    proc {::menu_edit::fill_menu_list} {top m} {
        global widget

        # let's try to save the context
        set indices [$top.MenuListbox curselection]
        set index [lindex $indices 0]
        set yview [lindex [$top.MenuListbox yview] 0]

        set ::${top}::listboxitems ""
        $top.MenuListbox delete 0 end

        lappend ::${top}::listboxitems [list $m -1]
        $top.MenuListbox insert end "<Menu>"

        ::menu_edit::fill_menu $top $m
        set ::${top}::menu $m

        if {$index != ""} {
            $top.MenuListbox selection clear 0 end
            $top.MenuListbox selection set $index
        }

        $top.MenuListbox yview moveto $yview
    }

    proc {::menu_edit::get_menu_index} {top index ref_m ref_i} {
        upvar $ref_m m
        upvar $ref_i i

        set reference [vTcl:at ::${top}::listboxitems]
        set reference [lindex $reference $index]
        set m [lindex $reference end-1]
        set i [lindex $reference end]
    }

    proc {::menu_edit::move_item} {top direction} {
        set indices [$top.MenuListbox curselection]
        set index   [lindex $indices 0]

        if {$index == ""} return

        set m ""
        set i ""

        ::menu_edit::get_menu_index $top $index m i

        # what is the new index ?
        switch $direction {
            up {
                set new_i [expr $i - 1]
            }
            down {
                set new_i [expr $i + 1]
            }
        }

        # let's save the old menu
        set old_config [$m entryconfigure $i]
        set mtype      [$m type $i]

        set optval ""

        # build a list of option/value pairs
        foreach option $old_config {
            lappend optval [list [lindex $option 0] [lindex $option 4]]
        }

        # delete the old menu
        $m delete $i

        # insert menu at the new place
        eval $m insert $new_i $mtype [join $optval]

        ::menu_edit::fill_menu_list $top [vTcl:at ::${top}::menu]
        ::menu_edit::show_menu $top $index
    }

    proc {::menu_edit::new_item} {top type} {
        global widget

        set indices [$top.MenuListbox curselection]
        set index [lindex $indices 0]

        if {$index == ""} return

        set listboxitems [vTcl:at ::${top}::listboxitems]

        set reference [lindex $listboxitems $index]

        set menu [lindex $reference end-1]
        set pos  [lindex $reference end]

        if {$pos != -1} {
            set mtype [$menu type $pos]
            if {$mtype == "cascade"} {
                set menu [$menu entrycget $pos -menu]
            }
        }

        switch $type {
            "cascade" {
                set nmenu [vTcl:new_widget_name menu $menu]
                menu $nmenu
                vTcl:widget:register_widget $nmenu -tearoff
                vTcl:setup_vTcl:bind $nmenu
                $menu add $type -label "New cascade" -menu $nmenu
            }
            "command" {
                $menu add $type -label "New command"  \
                    -command "\# TODO: Your menu handler here"
            }
            "radiobutton" {
                $menu add $type -label "New radio"  \
                    -command "\# TODO: Your menu handler here"
            }
            "checkbutton" {
                $menu add $type -label "New check"  \
                    -command "\# TODO: Your menu handler here"
            }
            "separator" {
                $menu add $type
            }
        }

        ::menu_edit::fill_menu_list $top [vTcl:at ::${top}::menu]
    }

    proc {::menu_edit::post_context_new_menu} {top X Y} {
        global widget

        tk_popup $widget(NewMenuContextPopup) $X $Y
    }


    proc {::menu_edit::post_new_menu} {top} {
        global widget

        set x [winfo rootx  $widget(NewMenu)]
        set y [winfo rooty  $widget(NewMenu)]
        set h [winfo height $widget(NewMenu)]

        tk_popup $widget(NewMenuToolbarPopup)  $x [expr $y + $h]
    }

    proc {::menu_edit::indicate_label_or_image} {top} {

        if { [vTcl:at ${top}::entry_image] != ""} {
            set ${top}::label image
        } else {
            set ${top}::label label
        }
    }

    proc {::menu_edit::show_menu} {top index} {
        global widget

        set name ::${top}::listboxitems
        eval set reference $\{$name\}

        set reference [lindex $reference $index]
        set m [lindex $reference end-1]
        set i [lindex $reference end]

        if {$i == -1} {
            ::menu_edit::enable_controls $top {"label" 0} \
                {"image" 0} {"accelerator" 0} {"variable" 0} \
                {"value_on" 0} {"value_off" 0} {"text" 0}
            set ::${top}::current_menu  $m
            set ::${top}::current_index $i
            ::menu_edit::enable_toolbar_buttons $top
            return
        }

        set mtype  [$m type $i]
        #puts "show_menu: $m $i $mtype"

        switch $mtype {
            "command" {
                ::menu_edit::enable_controls $top  {"label" 1} \
                    {"image" 1} {"accelerator" 1} {"variable" 0} \
                    {"value_on" 0} {"value_off" 0} {"text" 1}
                set ${top}::entry_label        [$m entrycget $i -label]
                set ${top}::entry_image        [$m entrycget $i -image]
                set ${top}::entry_accelerator  [$m entrycget $i -accelerator]
                ::menu_edit::fill_command $top [$m entrycget $i -command]
                ::menu_edit::indicate_label_or_image $top
            }
            "cascade" {
                ::menu_edit::enable_controls $top {"label" 1} \
                    {"image" 1} {"accelerator" 1} {"variable" 0} \
                    {"value_on" 0} {"value_off" 0}  {"text" 0}
                set ${top}::entry_label [$m entrycget $i -label]
                set ${top}::entry_image [$m entrycget $i -image]
                set ${top}::entry_accelerator ""
                ::menu_edit::indicate_label_or_image $top
            }
            "separator" {
                ::menu_edit::enable_controls $top {"label" 0} \
                    {"image" 0} {"accelerator" 0} {"variable" 0} \
                    {"value_on" 0} {"value_off" 0}  {"text" 0}
                set ${top}::entry_label ""
                set ${top}::entry_accelerator ""
            }
            "radiobutton" {
                ::menu_edit::enable_controls $top  {"label" 1} \
                    {"image" 1} {"accelerator" 1} {"variable" 1} \
                    {"value_on" 1} {"value_off" 0} {"text" 1}
                set ${top}::entry_label        [$m entrycget $i -label]
                set ${top}::entry_image        [$m entrycget $i -image]
                set ${top}::entry_accelerator  [$m entrycget $i -accelerator]
                set ${top}::entry_variable     [$m entrycget $i -variable]
                set ${top}::entry_value_on     [$m entrycget $i -value]
                ::menu_edit::fill_command $top [$m entrycget $i -command]
                ::menu_edit::indicate_label_or_image $top
            }
            "checkbutton" {
                ::menu_edit::enable_controls $top  {"label" 1} \
                    {"image" 1} {"accelerator" 1} {"variable" 1} \
                    {"value_on" 1} {"value_off" 1} {"text" 1}
                set ${top}::entry_label        [$m entrycget $i -label]
                set ${top}::entry_image        [$m entrycget $i -image]
                set ${top}::entry_accelerator  [$m entrycget $i -accelerator]
                set ${top}::entry_variable     [$m entrycget $i -variable]
                set ${top}::entry_value_on     [$m entrycget $i -onvalue]
                set ${top}::entry_value_off    [$m entrycget $i -offvalue]
                ::menu_edit::fill_command $top [$m entrycget $i -command]
                ::menu_edit::indicate_label_or_image $top
            }
        }

        set ::${top}::current_menu  $m
        set ::${top}::current_index $i

        ::menu_edit::enable_toolbar_buttons $top
    }

    proc {::menu_edit::toggle_tearoff} {top} {
        set indices [$top.MenuListbox curselection]
        set index   [lindex $indices 0]

        if {$index == ""} return

        set m ""
        set i ""

        ::menu_edit::get_menu_index $top $index m i

        set mtype [$m type $i]
        if {$mtype != "cascade"} return

        set submenu [$m entrycget $i -menu]
        if {$submenu == ""} return

        set tearoff [$submenu cget -tearoff]
        set tearoff [expr 1-$tearoff]
        $submenu configure -tearoff $tearoff

        ::menu_edit::fill_menu_list $top [vTcl:at ::${top}::menu]
        ::menu_edit::show_menu $top $index
    }

    proc {::menu_edit::update_current} {top} {
        if {! [info exists ::${top}::current_menu] }  return
        if {! [info exists ::${top}::current_index] } return

        set index [vTcl:at ::${top}::current_index]
        if {$index == -1 || $index == ""} {
            return
        }

        set menu  [vTcl:at ::${top}::current_menu]
        if {$menu == ""} {
            return
        }

        set type [$menu type $index]

        switch $type {
            "cascade" {
                ::menu_edit::update_option $top $menu $index \
                    -label [vTcl:at ::${top}::entry_label]
                ::menu_edit::update_option $top $menu $index \
                    -image [vTcl:at ::${top}::entry_image]
                ::menu_edit::update_option $top $menu $index \
                    -accelerator [vTcl:at ::${top}::entry_accelerator]
            }
            "command"  {
                ::menu_edit::update_option $top $menu $index \
                    -label [vTcl:at ::${top}::entry_label]
                ::menu_edit::update_option $top $menu $index \
                    -image [vTcl:at ::${top}::entry_image]
                ::menu_edit::update_option $top $menu $index \
                    -accelerator [vTcl:at ::${top}::entry_accelerator]
                ::menu_edit::update_option $top $menu $index \
                    -command [string trim [$top.MenuText get 0.0 end]]
            }
            "separator"  {
            }
            "radiobutton"  {
                ::menu_edit::update_option $top $menu $index \
                    -label [vTcl:at ::${top}::entry_label]
                ::menu_edit::update_option $top $menu $index \
                    -image [vTcl:at ::${top}::entry_image]
                ::menu_edit::update_option $top $menu $index \
                    -accelerator [vTcl:at ::${top}::entry_accelerator]
                ::menu_edit::update_option $top $menu $index \
                    -command  [string trim [$top.MenuText get 0.0 end]]
                ::menu_edit::update_option $top $menu $index \
                    -variable [vTcl:at ::${top}::entry_variable]
                ::menu_edit::update_option $top $menu $index \
                    -value    [vTcl:at ::${top}::entry_value_on]
            }
            "checkbutton" {
                ::menu_edit::update_option $top $menu $index \
                    -label [vTcl:at ::${top}::entry_label]
                ::menu_edit::update_option $top $menu $index \
                    -image [vTcl:at ::${top}::entry_image]
                ::menu_edit::update_option $top $menu $index \
                    -accelerator [vTcl:at ::${top}::entry_accelerator]
                ::menu_edit::update_option $top $menu $index \
                    -command  [string trim [$top.MenuText get 0.0 end]]
                ::menu_edit::update_option $top $menu $index \
                    -variable [vTcl:at ::${top}::entry_variable]
                ::menu_edit::update_option $top $menu $index \
                    -onvalue  [vTcl:at ::${top}::entry_value_on]
                ::menu_edit::update_option $top $menu $index \
                    -offvalue [vTcl:at ::${top}::entry_value_off]
            }
        }
    }

    proc {::menu_edit::update_option} {top menu index option value} {
        global widget

        set oldvalue [$menu entrycget $index $option]

        if {$value != $oldvalue} {
            $menu entryconfigure $index $option $value

            if {$option == "-label" || $option == "-accelerator"} {
                ::menu_edit::fill_menu_list $top [vTcl:at ::${top}::menu]
            }

            #puts "Updating: $menu $index $option $value"
        }
    }

    proc {::menu_edit::close_all_editors} {} {

        variable menu_edit_windows

        set wnds $menu_edit_windows

        foreach wnd $wnds {
            destroy $wnd
        }

        set menu_edit_windows ""
    }

    proc {::menu_edit::browse_image} {top} {

        set image [vTcl:at ::${top}::entry_image]
        set r [vTcl:prompt_user_image2 $image]
        set ::${top}::entry_image $r
    }

    proc {::menu_edit::click_listbox} {top} {

        ::menu_edit::update_current $top

        set indices [MenuListbox curselection]
        set index [lindex $indices 0]

        if {$index != ""} {
            ::menu_edit::show_menu $top $index
        }
    }

    proc {::menu_edit::ask_delete_menu} {top} {

        if {[tk_messageBox -message {Delete menu ?} \
                           -title {Menu editor} -type yesno] == "yes"} {
            ::menu_edit::delete_item $top
        }
    }

} ; # namespace eval

proc vTclWindow.vTclMenuEdit {base menu} {

    global widget vTcl

    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    namespace eval $base {
        variable listboxitems  ""
        variable current_menu  ""
        variable current_index ""
    }

    set widget(rev,$base.cpd24.01.cpd25.01) {MenuListbox}
    set {widget(MenuListbox)} "$base.cpd24.01.cpd25.01"
    set widget($base,MenuListbox) "$base.cpd24.01.cpd25.01"
    interp alias {} MenuListbox {} vTcl:WidgetProc $base.cpd24.01.cpd25.01
    interp alias {} $base.MenuListbox {} \
        vTcl:WidgetProc $base.cpd24.01.cpd25.01
    set widget(rev,$base.cpd24.01.cpd25.01.m24) {NewMenuToolbarPopup}
    set {widget(NewMenuToolbarPopup)} "$base.cpd24.01.cpd25.01.m24"
    set widget(NewMenuToolbarPopup,NewMenuToolbarPopup) \
        "$base.cpd24.01.cpd25.01.m24"
    interp alias {} NewMenuToolbarPopup {} \
        vTcl:WidgetProc $base.cpd24.01.cpd25.01.m24
    interp alias {} NewMenuToolbarPopup.NewMenuToolbarPopup {} \
        vTcl:WidgetProc $base.cpd24.01.cpd25.01.m24
    set widget(rev,$base.cpd24.01.cpd25.01.m25) {NewMenuContextPopup}
    set {widget(NewMenuContextPopup)} "$base.cpd24.01.cpd25.01.m25"
    set widget(NewMenuContextPopup,NewMenuContextPopup) \
        "$base.cpd24.01.cpd25.01.m25"
    interp alias {} NewMenuContextPopup {} \
        vTcl:WidgetProc $base.cpd24.01.cpd25.01.m25
    interp alias {} NewMenuContextPopup.NewMenuContextPopup {} \
        vTcl:WidgetProc $base.cpd24.01.cpd25.01.m25
    set widget(rev,$base.cpd24.01.fra20.but21) {NewMenu}
    set {widget(NewMenu)} "$base.cpd24.01.fra20.but21"
    set widget($base,NewMenu) "$base.cpd24.01.fra20.but21"
    interp alias {} NewMenu {} vTcl:WidgetProc $base.cpd24.01.fra20.but21
    interp alias {} $base.NewMenu {} \
        vTcl:WidgetProc $base.cpd24.01.fra20.but21
    set widget(rev,$base.cpd24.01.fra20.but22) {DeleteMenu}
    set {widget(DeleteMenu)} "$base.cpd24.01.fra20.but22"
    set widget($base,DeleteMenu) "$base.cpd24.01.fra20.but22"
    interp alias {} DeleteMenu {} vTcl:WidgetProc $base.cpd24.01.fra20.but22
    interp alias {} $base.DeleteMenu {} \
        vTcl:WidgetProc $base.cpd24.01.fra20.but22
    set widget(rev,$base.cpd24.01.fra20.but23) {MoveMenuUp}
    set {widget(MoveMenuUp)} "$base.cpd24.01.fra20.but23"
    set widget($base,MoveMenuUp) "$base.cpd24.01.fra20.but23"
    interp alias {} MoveMenuUp {} vTcl:WidgetProc $base.cpd24.01.fra20.but23
    interp alias {} $base.MoveMenuUp {} \
        vTcl:WidgetProc $base.cpd24.01.fra20.but23
    set widget(rev,$base.cpd24.01.fra20.but24) {MoveMenuDown}
    set {widget(MoveMenuDown)} "$base.cpd24.01.fra20.but24"
    set widget($base,MoveMenuDown) "$base.cpd24.01.fra20.but24"
    interp alias {} MoveMenuDown {} vTcl:WidgetProc $base.cpd24.01.fra20.but24
    interp alias {} $base.MoveMenuDown {} \
        vTcl:WidgetProc $base.cpd24.01.fra20.but24
    set widget(rev,$base.cpd24.02.but27) {BrowseImage}
    set {widget(BrowseImage)} "$base.cpd24.02.but27"
    set widget($base,BrowseImage) "$base.cpd24.02.but27"
    interp alias {} BrowseImage {} vTcl:WidgetProc $base.cpd24.02.but27
    interp alias {} $base.BrowseImage {} vTcl:WidgetProc $base.cpd24.02.but27
    set widget(rev,$base.cpd24.02.ent23) {EntryLabel}
    set {widget(EntryLabel)} "$base.cpd24.02.ent23"
    set widget($base,EntryLabel) "$base.cpd24.02.ent23"
    interp alias {} EntryLabel {} vTcl:WidgetProc $base.cpd24.02.ent23
    interp alias {} $base.EntryLabel {} vTcl:WidgetProc $base.cpd24.02.ent23
    set widget(rev,$base.cpd24.02.ent24) {EntryImage}
    set {widget(EntryImage)} "$base.cpd24.02.ent24"
    set widget($base,EntryImage) "$base.cpd24.02.ent24"
    interp alias {} EntryImage {} vTcl:WidgetProc $base.cpd24.02.ent24
    interp alias {} $base.EntryImage {} vTcl:WidgetProc $base.cpd24.02.ent24
    set widget(rev,$base.cpd24.02.ent25) {EntryVariable}
    set {widget(EntryVariable)} "$base.cpd24.02.ent25"
    set widget($base,EntryVariable) "$base.cpd24.02.ent25"
    interp alias {} EntryVariable {} vTcl:WidgetProc $base.cpd24.02.ent25
    interp alias {} $base.EntryVariable {} \
        vTcl:WidgetProc $base.cpd24.02.ent25
    set widget(rev,$base.cpd24.02.ent27) {EntryValueOn}
    set {widget(EntryValueOn)} "$base.cpd24.02.ent27"
    set widget($base,EntryValueOn) "$base.cpd24.02.ent27"
    interp alias {} EntryValueOn {} vTcl:WidgetProc $base.cpd24.02.ent27
    interp alias {} $base.EntryValueOn {} vTcl:WidgetProc $base.cpd24.02.ent27
    set widget(rev,$base.cpd24.02.ent29) {EntryAccelerator}
    set {widget(EntryAccelerator)} "$base.cpd24.02.ent29"
    set widget($base,EntryAccelerator) "$base.cpd24.02.ent29"
    interp alias {} EntryAccelerator {} vTcl:WidgetProc $base.cpd24.02.ent29
    interp alias {} $base.EntryAccelerator {} \
        vTcl:WidgetProc $base.cpd24.02.ent29
    set widget(rev,$base.cpd24.02.ent30) {EntryValueOff}
    set {widget(EntryValueOff)} "$base.cpd24.02.ent30"
    set widget($base,EntryValueOff) "$base.cpd24.02.ent30"
    interp alias {} EntryValueOff {} vTcl:WidgetProc $base.cpd24.02.ent30
    interp alias {} $base.EntryValueOff {} \
        vTcl:WidgetProc $base.cpd24.02.ent30
    set widget(rev,$base.cpd24.02.fra22.cpd32.03) {MenuText}
    set {widget(MenuText)} "$base.cpd24.02.fra22.cpd32.03"
    set widget($base,MenuText) "$base.cpd24.02.fra22.cpd32.03"
    interp alias {} MenuText {} \
        vTcl:WidgetProc $base.cpd24.02.fra22.cpd32.03
    interp alias {} $base.MenuText {} \
        vTcl:WidgetProc $base.cpd24.02.fra22.cpd32.03
    set widget(rev,$base.cpd24.02.fra22.lab31) {LabelCommand}
    set {widget(LabelCommand)} "$base.cpd24.02.fra22.lab31"
    set widget($base,LabelCommand) "$base.cpd24.02.fra22.lab31"
    interp alias {} LabelCommand {} vTcl:WidgetProc $base.cpd24.02.fra22.lab31
    interp alias {} $base.LabelCommand {} \
        vTcl:WidgetProc $base.cpd24.02.fra22.lab31
    set widget(rev,$base.cpd24.02.lab22) {LabelVariable}
    set {widget(LabelVariable)} "$base.cpd24.02.lab22"
    set widget($base,LabelVariable) "$base.cpd24.02.lab22"
    interp alias {} LabelVariable {} vTcl:WidgetProc $base.cpd24.02.lab22
    interp alias {} $base.LabelVariable {} vTcl:WidgetProc $base.cpd24.02.lab22
    set widget(rev,$base.cpd24.02.lab26) {LabelValueOn}
    set {widget(LabelValueOn)} "$base.cpd24.02.lab26"
    set widget($base,LabelValueOn) "$base.cpd24.02.lab26"
    interp alias {} LabelValueOn {} vTcl:WidgetProc $base.cpd24.02.lab26
    interp alias {} $base.LabelValueOn {} vTcl:WidgetProc $base.cpd24.02.lab26
    set widget(rev,$base.cpd24.02.lab28) {LabelAccelerator}
    set {widget(LabelAccelerator)} "$base.cpd24.02.lab28"
    set widget($base,LabelAccelerator) "$base.cpd24.02.lab28"
    interp alias {} LabelAccelerator {} vTcl:WidgetProc $base.cpd24.02.lab28
    interp alias {} $base.LabelAccelerator {} \
        vTcl:WidgetProc $base.cpd24.02.lab28
    set widget(rev,$base.cpd24.02.lab29) {LabelValueOff}
    set {widget(LabelValueOff)} "$base.cpd24.02.lab29"
    set widget($base,LabelValueOff) "$base.cpd24.02.lab29"
    interp alias {} LabelValueOff {} vTcl:WidgetProc $base.cpd24.02.lab29
    interp alias {} $base.LabelValueOff {} vTcl:WidgetProc $base.cpd24.02.lab29
    set widget(rev,$base.cpd24.02.rad20) {RadioLabel}
    set {widget(RadioLabel)} "$base.cpd24.02.rad20"
    set widget($base,RadioLabel) "$base.cpd24.02.rad20"
    interp alias {} RadioLabel {} vTcl:WidgetProc $base.cpd24.02.rad20
    interp alias {} $base.RadioLabel {} vTcl:WidgetProc $base.cpd24.02.rad20
    set widget(rev,$base.cpd24.02.rad21) {RadioImage}
    set {widget(RadioImage)} "$base.cpd24.02.rad21"
    set widget($base,RadioImage) "$base.cpd24.02.rad21"
    interp alias {} RadioImage {} vTcl:WidgetProc $base.cpd24.02.rad21
    interp alias {} $base.RadioImage {} vTcl:WidgetProc $base.cpd24.02.rad21
    set widget(rev,$base.fra21.but22) {MenuOK}
    set {widget(MenuOK)} "$base.fra21.but22"
    set widget($base,MenuOK) "$base.fra21.but22"
    interp alias {} MenuOK {} vTcl:WidgetProc $base.fra21.but22
    interp alias {} $base.MenuOK {} vTcl:WidgetProc $base.fra21.but22

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm geometry $base 550x450+323+138; update
    wm maxsize $base 1284 1010
    wm minsize $base 100 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Menu editor"
    wm transient $base .vTcl

    frame $base.fra21 \
        -borderwidth 2 -height 75 -width 125
    button $base.fra21.but22 \
        -image [vTcl:image:get_image "ok.gif"] \
        -text button -command "destroy $base"
    frame $base.cpd24 \
        -background #000000 -height 100 -width 200
    frame $base.cpd24.01 \
        -background #9900991B99FE
    frame $base.cpd24.01.fra20 \
        -borderwidth 2 -height 75 -width 125
    button $base.cpd24.01.fra20.but21 \
        -image [vTcl:image:get_image "add.gif"] \
        -text button
    bind $base.cpd24.01.fra20.but21 <ButtonRelease-1> {
        ::menu_edit::post_new_menu [winfo toplevel %W]
    }
    button $base.cpd24.01.fra20.but22 \
        -command "::menu_edit::ask_delete_menu $base" \
        -image [vTcl:image:get_image "remove.gif"] \
        -text button
    button $base.cpd24.01.fra20.but23 \
        -command "::menu_edit::move_item $base up" -height 20 -image up \
        -text button -width 20
    button $base.cpd24.01.fra20.but24 \
        -command "::menu_edit::move_item $base down" -height 20 -image down \
        -text button -width 20
    frame $base.cpd24.01.cpd25 \
        -borderwidth 1 -height 30 -relief raised -width 30
    listbox $base.cpd24.01.cpd25.01 \
        -xscrollcommand "$base.cpd24.01.cpd25.02 set" \
        -yscrollcommand "$base.cpd24.01.cpd25.03 set" \
        -background white
    bindtags $base.cpd24.01.cpd25.01 \
        "Listbox $base.cpd24.01.cpd25.01 $base all"
    bind $base.cpd24.01.cpd25.01 <Button-1> {
        focus %W
    }
    bind $base.cpd24.01.cpd25.01 <ButtonRelease-1> {
        ::menu_edit::update_current [winfo toplevel %W]

        set indices [%W curselection]
        set index [lindex $indices 0]

        if {$index != ""} {
            ::menu_edit::show_menu [winfo toplevel %W] $index
        }
    }
    bind $base.cpd24.01.cpd25.01 <ButtonRelease-3> {
        ::menu_edit::update_current [winfo toplevel %W]

        set index [%W index @%x,%y]
        %W selection clear 0 end
        %W selection set $index
        %W activate $index

        if {$index != ""} {
            ::menu_edit::show_menu [winfo toplevel %W] $index
        }

        ::menu_edit::post_context_new_menu [winfo toplevel %W] %X %Y
    }
    bind $base.cpd24.01.cpd25.01 <KeyRelease-Down> {
        ::menu_edit::click_listbox [winfo toplevel %W]
    }
    bind $base.cpd24.01.cpd25.01 <KeyRelease-Up> {
        ::menu_edit::click_listbox [winfo toplevel %W]
    }
    bind $base.cpd24.01.cpd25.01 <KeyRelease-Prior> {
        ::menu_edit::click_listbox [winfo toplevel %W]
    }
    bind $base.cpd24.01.cpd25.01 <KeyRelease-Next> {
        ::menu_edit::click_listbox [winfo toplevel %W]
    }
    menu $base.cpd24.01.cpd25.01.m24 \
        -activeborderwidth 1 -tearoff 0
    $base.cpd24.01.cpd25.01.m24 add command \
        -accelerator {} -command "::menu_edit::new_item $base command" \
        -label {New command}
    $base.cpd24.01.cpd25.01.m24 add command \
        -accelerator {} -command "::menu_edit::new_item $base cascade" \
        -label {New cascade}
    $base.cpd24.01.cpd25.01.m24 add command \
        -accelerator {} -command "::menu_edit::new_item $base separator" \
        -label {New separator}
    $base.cpd24.01.cpd25.01.m24 add command \
        -accelerator {} \
        -command "::menu_edit::new_item $base radiobutton" \
        -label {New radio}
    $base.cpd24.01.cpd25.01.m24 add command \
        -accelerator {} \
        -command "::menu_edit::new_item $base checkbutton" \
        -label {New check}
    menu $base.cpd24.01.cpd25.01.m25 \
        -activeborderwidth 1 -tearoff 0
    $base.cpd24.01.cpd25.01.m25 add command \
        -accelerator {} -command "::menu_edit::new_item $base command" \
        -label {New command}
    $base.cpd24.01.cpd25.01.m25 add command \
        -accelerator {} -command "::menu_edit::new_item $base cascade" \
        -label {New cascade}
    $base.cpd24.01.cpd25.01.m25 add command \
        -accelerator {} -command "::menu_edit::new_item $base separator" \
        -label {New separator}
    $base.cpd24.01.cpd25.01.m25 add command \
        -accelerator {} \
        -command "::menu_edit::new_item $base radiobutton" \
        -label {New radio}
    $base.cpd24.01.cpd25.01.m25 add command \
        -accelerator {} \
        -command "::menu_edit::new_item $base checkbutton" \
        -label {New check}
    $base.cpd24.01.cpd25.01.m25 add separator
    $base.cpd24.01.cpd25.01.m25 add command \
        -accelerator {} \
        -command "::menu_edit::ask_delete_menu $base" \
        -label Delete...
    $base.cpd24.01.cpd25.01.m25 add separator
    $base.cpd24.01.cpd25.01.m25 add command \
        -accelerator {} -command "::menu_edit::toggle_tearoff $base" \
        -label Tearoff
    scrollbar $base.cpd24.01.cpd25.02 \
        -command "$base.cpd24.01.cpd25.01 xview" -orient horizontal
    scrollbar $base.cpd24.01.cpd25.03 \
        -command "$base.cpd24.01.cpd25.01 yview"
    frame $base.cpd24.02
    radiobutton $base.cpd24.02.rad20 \
        -padx 1 -pady 1 -text Label: -value label -variable ${base}::label
    radiobutton $base.cpd24.02.rad21 \
        -text Image: -value image -variable ${base}::label
    frame $base.cpd24.02.fra22 \
        -borderwidth 2 -relief flat
    label $base.cpd24.02.fra22.lab31 \
        -anchor center -text Command:
    frame $base.cpd24.02.fra22.cpd32 \
        -borderwidth 1 -height 30 -relief raised -width 30
    scrollbar $base.cpd24.02.fra22.cpd32.01 \
        -command "$base.cpd24.02.fra22.cpd32.03 xview" -orient horizontal
    scrollbar $base.cpd24.02.fra22.cpd32.02 \
        -command "$base.cpd24.02.fra22.cpd32.03 yview"
    text $base.cpd24.02.fra22.cpd32.03 \
        -background gray \
        -font $vTcl(pr,font_fixed) \
        -width 20 -xscrollcommand "$base.cpd24.02.fra22.cpd32.01 set" \
        -yscrollcommand "$base.cpd24.02.fra22.cpd32.02 set"
    bind $base.cpd24.02.fra22.cpd32.03 <FocusOut> {
        ::menu_edit::update_current [winfo toplevel %W]
    }
    entry $base.cpd24.02.ent23 \
        -background white -cursor {} -textvariable ${base}::entry_label
    bind $base.cpd24.02.ent23 <FocusOut> {
        ::menu_edit::update_current [winfo toplevel %W]
    }
    entry $base.cpd24.02.ent24 \
        -background white -cursor {} -textvariable ${base}::entry_image
    bind $base.cpd24.02.ent24 <FocusOut> {
        ::menu_edit::update_current [winfo toplevel %W]
    }
    button $base.cpd24.02.but27 \
        -padx 1 -pady 0 -text ... \
        -command "::menu_edit::browse_image $base
                  ::menu_edit::indicate_label_or_image $base"
    label $base.cpd24.02.lab28 \
        -padx 1 -pady 1 -text Accelerator:
    entry $base.cpd24.02.ent29 \
        -background white -cursor {} -textvariable ${base}::entry_accelerator
    bind $base.cpd24.02.ent29 <FocusOut> {
        ::menu_edit::update_current [winfo toplevel %W]
    }
    frame $base.cpd24.02.fra30 \
        -borderwidth 2 -height 20 -width 125
    frame $base.cpd24.02.fra21 \
        -borderwidth 2 -height 20 -width 125
    label $base.cpd24.02.lab22 \
        -padx 1 -pady 1 -text Variable:
    entry $base.cpd24.02.ent25 \
        -background gray -cursor {} -textvariable ${base}::entry_variable
    bind $base.cpd24.02.ent25 <FocusOut> {
        ::menu_edit::update_current [winfo toplevel %W]
    }
    label $base.cpd24.02.lab26 \
        -padx 1 -pady 1 -text {Value On:}
    entry $base.cpd24.02.ent27 \
        -background gray -cursor {} -textvariable ${base}::entry_value_on
    bind $base.cpd24.02.ent27 <FocusOut> {
        ::menu_edit::update_current [winfo toplevel %W]
    }
    label $base.cpd24.02.lab29 \
        -padx 1 -pady 1 -text {Value Off:}
    entry $base.cpd24.02.ent30 \
        -background gray -cursor {} -textvariable ${base}::entry_value_off
    bind $base.cpd24.02.ent30 <FocusOut> {
        ::menu_edit::update_current [winfo toplevel %W]
    }
    frame $base.cpd24.03 \
        -background #ff0000 -borderwidth 2 -relief raised
    bind $base.cpd24.03 <B1-Motion> {
        set root [ split %W . ]
        set nb [ llength $root ]
        incr nb -1
        set root [ lreplace $root $nb $nb ]
        set root [ join $root . ]
        set width [ winfo width $root ].0

        set val [ expr (%X - [winfo rootx $root]) /$width ]

        if { $val >= 0 && $val <= 1.0 } {

            place $root.01 -relwidth $val
            place $root.03 -relx $val
            place $root.02 -relwidth [ expr 1.0 - $val ]
        }
    }
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra21 \
        -in $base -anchor center -expand 0 -fill x -side top
    pack $base.fra21.but22 \
        -in $base.fra21 -anchor center -expand 0 -fill none -side right
    pack $base.cpd24 \
        -in $base -anchor center -expand 1 -fill both -side top
    place $base.cpd24.01 \
        -x 0 -y 0 -width -1 -relwidth 0.3612 -relheight 1 -anchor nw \
        -bordermode ignore
    pack $base.cpd24.01.fra20 \
        -in $base.cpd24.01 -anchor center -expand 0 -fill x -side top
    pack $base.cpd24.01.fra20.but21 \
        -in $base.cpd24.01.fra20 -anchor center -expand 0 -fill none \
        -side left
    pack $base.cpd24.01.fra20.but22 \
        -in $base.cpd24.01.fra20 -anchor center -expand 0 -fill none \
        -side left
    pack $base.cpd24.01.fra20.but23 \
        -in $base.cpd24.01.fra20 -anchor center -expand 0 -fill none \
        -side left
    pack $base.cpd24.01.fra20.but24 \
        -in $base.cpd24.01.fra20 -anchor center -expand 0 -fill none \
        -side left
    pack $base.cpd24.01.cpd25 \
        -in $base.cpd24.01 -anchor center -expand 1 -fill both -side top
    grid columnconf $base.cpd24.01.cpd25 0 -weight 1
    grid rowconf $base.cpd24.01.cpd25 0 -weight 1
    grid $base.cpd24.01.cpd25.01 \
        -in $base.cpd24.01.cpd25 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw
    grid $base.cpd24.01.cpd25.02 \
        -in $base.cpd24.01.cpd25 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew
    grid $base.cpd24.01.cpd25.03 \
        -in $base.cpd24.01.cpd25 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns
    place $base.cpd24.02 \
        -x 0 -relx 1 -y 0 -width -1 -relwidth 0.6388 -relheight 1 -anchor ne \
        -bordermode ignore
    grid columnconf $base.cpd24.02 1 -weight 1
    grid rowconf $base.cpd24.02 8 -weight 1
    grid $base.cpd24.02.rad20 \
        -in $base.cpd24.02 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nw
    grid $base.cpd24.02.rad21 \
        -in $base.cpd24.02 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky nw
    grid $base.cpd24.02.fra22 \
        -in $base.cpd24.02 -column 0 -row 8 -columnspan 3 -rowspan 1 -padx 5 \
        -pady 5 -sticky nesw
    pack $base.cpd24.02.fra22.lab31 \
        -in $base.cpd24.02.fra22 -anchor w -expand 0 -fill none -side top
    pack $base.cpd24.02.fra22.cpd32 \
        -in $base.cpd24.02.fra22 -anchor center -expand 1 -fill both \
        -side top
    grid columnconf $base.cpd24.02.fra22.cpd32 0 -weight 1
    grid rowconf $base.cpd24.02.fra22.cpd32 0 -weight 1
    grid $base.cpd24.02.fra22.cpd32.01 \
        -in $base.cpd24.02.fra22.cpd32 -column 0 -row 1 -columnspan 1 \
        -rowspan 1 -sticky ew
    grid $base.cpd24.02.fra22.cpd32.02 \
        -in $base.cpd24.02.fra22.cpd32 -column 1 -row 0 -columnspan 1 \
        -rowspan 1 -sticky ns
    grid $base.cpd24.02.fra22.cpd32.03 \
        -in $base.cpd24.02.fra22.cpd32 -column 0 -row 0 -columnspan 1 \
        -rowspan 1 -sticky nesw
    grid $base.cpd24.02.ent23 \
        -in $base.cpd24.02 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ew
    grid $base.cpd24.02.ent24 \
        -in $base.cpd24.02 -column 1 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew
    grid $base.cpd24.02.but27 \
        -in $base.cpd24.02 -column 2 -row 1 -columnspan 1 -rowspan 1 -padx 5
    grid $base.cpd24.02.lab28 \
        -in $base.cpd24.02 -column 0 -row 3 -columnspan 1 -rowspan 1 -padx 5 \
        -sticky e
    grid $base.cpd24.02.ent29 \
        -in $base.cpd24.02 -column 1 -row 3 -columnspan 1 -rowspan 1 \
        -sticky new
    grid $base.cpd24.02.fra30 \
        -in $base.cpd24.02 -column 0 -row 2 -columnspan 3 -rowspan 1 \
        -sticky new
    grid $base.cpd24.02.fra21 \
        -in $base.cpd24.02 -column 0 -row 4 -columnspan 3 -rowspan 1 \
        -sticky new
    grid $base.cpd24.02.lab22 \
        -in $base.cpd24.02 -column 0 -row 5 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5 -sticky e
    grid $base.cpd24.02.ent25 \
        -in $base.cpd24.02 -column 1 -row 5 -columnspan 1 -rowspan 1 -pady 5 \
        -sticky ew
    grid $base.cpd24.02.lab26 \
        -in $base.cpd24.02 -column 0 -row 6 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5 -sticky e
    grid $base.cpd24.02.ent27 \
        -in $base.cpd24.02 -column 1 -row 6 -columnspan 1 -rowspan 1 -pady 5 \
        -sticky ew
    grid $base.cpd24.02.lab29 \
        -in $base.cpd24.02 -column 0 -row 7 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5 -sticky e
    grid $base.cpd24.02.ent30 \
        -in $base.cpd24.02 -column 1 -row 7 -columnspan 1 -rowspan 1 -pady 5 \
        -sticky ew
    place $base.cpd24.03 \
        -x 0 -relx 0.3612 -y 0 -rely 0.9 -width 10 -height 10 -anchor s \
        -bordermode ignore

    vTcl:set_balloon $widget(NewMenu) \
        "Create a new menu item or a new submenu"
    vTcl:set_balloon $widget(DeleteMenu) \
        "Delete an existing menu item or submenu"
    vTcl:set_balloon $widget(MoveMenuUp) \
        "Move menu up"
    vTcl:set_balloon $widget(MoveMenuDown) \
        "Move menu down"

    ::menu_edit::fill_menu_list $base $menu

    # keep a record of open menu editors
    lappend ::menu_edit::menu_edit_windows $base

    # when a menu editor is closed, should be removed from the list
    bind $base <Destroy> {

        set ::menu_edit::index \
            [lsearch -exact ${::menu_edit::menu_edit_windows} %W]

        if {${::menu_edit::index} != -1} {
            set ::menu_edit::menu_edit_windows \
                [lreplace ${::menu_edit::menu_edit_windows} \
                    ${::menu_edit::index} ${::menu_edit::index}]

            # clean up after ourselves
            namespace delete %W
        }
    }

    vTcl:setup_vTcl:bind $base
}


