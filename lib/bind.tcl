##############################################################################
#
# bind.tcl - procedures to control widget bindings
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

proc vTclWindow(post).vTcl.bind {args} {
    vTcl:setup_vTcl:bind .vTcl.bind
}

proc vTcl:get_bind {target} {
    if {[winfo exists .vTcl.bind]} {
        ::widgets_bindings::fill_bindings $target 0
    }
}

proc vTclWindow.vTcl.bind {args} {
    global vTcl
    set container 0
    set base .vTcl.bind

    if {[winfo exists $base] && (!$container)} { wm deiconify $base; return }

    global widget
    set widget(rev,$base) {BindingsEditor}
    set {widget(BindingsEditor)} "$base"
    set {widget(child,BindingsEditor)} ""
    interp alias {} BindingsEditor {} vTcl:Toplevel:WidgetProc $base
    set widget(rev,$base.cpd21.01.cpd25.01) {ListboxBindings}
    set {widget(ListboxBindings)} "$base.cpd21.01.cpd25.01"
    set {widget(child,ListboxBindings)} "cpd21.01.cpd25.01"
    interp alias {} ListboxBindings {} vTcl:WidgetProc $base.cpd21.01.cpd25.01
    set widget(rev,$base.cpd21.01.fra22.but24) {RemoveBinding}
    set {widget(RemoveBinding)} "$base.cpd21.01.fra22.but24"
    set {widget(child,RemoveBinding)} "cpd21.01.fra22.but24"
    interp alias {} RemoveBinding {} vTcl:WidgetProc $base.cpd21.01.fra22.but24
    set widget(rev,$base.cpd21.01.fra22.men20) {AddBinding}
    set {widget(AddBinding)} "$base.cpd21.01.fra22.men20"
    set {widget(child,AddBinding)} "cpd21.01.fra22.men20"
    interp alias {} AddBinding {} vTcl:WidgetProc $base.cpd21.01.fra22.men20
    set widget(rev,$base.cpd21.02.cpd21.03) {TextBindings}
    set {widget(TextBindings)} "$base.cpd21.02.cpd21.03"
    set {widget(child,TextBindings)} "cpd21.02.cpd21.03"
    interp alias {} TextBindings {} vTcl:WidgetProc $base.cpd21.02.cpd21.03
    set widget(MoveTagUp) $base.cpd21.01.fra22.but25
    interp alias {} MoveTagUp {} vTcl:WidgetProc $base.cpd21.01.fra22.but25
    set widget(MoveTagDown) $base.cpd21.01.fra22.but26
    interp alias {} MoveTagDown {} vTcl:WidgetProc $base.cpd21.01.fra22.but26
    set widget(AddTag) $base.cpd21.01.fra22.but27
    set widget(DeleteTag) $base.cpd21.01.fra22.but28
    interp alias {} DeleteTag {} vTcl:WidgetProc $base.cpd21.01.fra22.but28
    
    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
        toplevel $base -class Toplevel
        wm focusmodel $base passive
        wm withdraw $base
        wm geometry $base 660x514+264+138
        wm maxsize $base 1284 1010
        wm minsize $base 100 1
        wm overrideredirect $base 0
        wm resizable $base 1 1
        wm title $base "Widget bindings"
        wm transient .vTcl.bind .vTcl
    }
    frame $base.fra22 \
        -borderwidth 2 -height 75 \
        -width 125 
    button $base.fra22.but24 \
        -image [vTcl:image:get_image "ok.gif"] \
        -padx 9 -pady 3 -text button -command "Window hide .vTcl.bind"
    vTcl:set_balloon $base.fra22.but24 "Close"
    frame $base.cpd21 \
        -background #000000 -height 100 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -width 200 
    frame $base.cpd21.01 \
        -background #9900991B99FE -highlightbackground #dcdcdc \
        -highlightcolor #000000 
    frame $base.cpd21.01.fra22 \
        -background #dcdcdc -borderwidth 2 -height 75 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -width 125 
    menubutton $base.cpd21.01.fra22.men20 \
        -height 23 \
        -image [vTcl:image:get_image "add.gif"] \
        -menu "$base.cpd21.01.fra22.men20.m" -padx 0 -pady 0 -relief raised \
        -text menu -width 23 
    menu $base.cpd21.01.fra22.men20.m \
        -borderwidth 1 \
        -tearoff 0 
    $base.cpd21.01.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <Button-1>} -label Button-1 
    $base.cpd21.01.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <Button-2>} -label Button-2
    $base.cpd21.01.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <Button-3>} -label Button-3 
    $base.cpd21.01.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <ButtonRelease-1>} \
        -label ButtonRelease-1
    $base.cpd21.01.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <ButtonRelease-2>} \
        -label ButtonRelease-2 
    $base.cpd21.01.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <ButtonRelease-3>} \
        -label ButtonRelease-3 
    $base.cpd21.01.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <Motion>} -label Motion 
    $base.cpd21.01.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <Enter>} -label Enter 
    $base.cpd21.01.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <Leave>} -label Leave 
    $base.cpd21.01.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <KeyPress>} -label KeyPress
    $base.cpd21.01.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <KeyRelease>} \
        -label KeyRelease 
    $base.cpd21.01.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <FocusIn>} -label FocusIn
    $base.cpd21.01.fra22.men20.m add command \
        -command {::widgets_bindings::add_binding <FocusOut>} -label FocusOut
    $base.cpd21.01.fra22.men20.m add command \
        -command {Window show .vTcl.newbind} -label Advanced...
    button $base.cpd21.01.fra22.but24 \
        -command ::widgets_bindings::delete_binding \
        -height 23 \
        -highlightthickness 0 \
        -image [vTcl:image:get_image "remove.gif"] \
        -padx 0 -pady 0 -text button -width 23
    button $base.cpd21.01.fra22.but25 \
        -command "::widgets_bindings::movetag up" \
        -height 23 \
        -highlightthickness 0 \
        -image up \
        -padx 0 -pady 0 -text button -width 23
    button $base.cpd21.01.fra22.but26 \
        -command "::widgets_bindings::movetag down" \
        -height 23 \
        -highlightthickness 0 \
        -image down \
        -padx 0 -pady 0 -text button -width 23
    button $base.cpd21.01.fra22.but27 \
        -command "vTcl:Toplevel:WidgetProc .vTcl.newtag ShowModal" \
        -height 23 \
        -highlightthickness 0 \
        -padx 0 -pady 0 -image icon_message.gif -width 23
    button $base.cpd21.01.fra22.but28 \
        -command "::widgets_bindings::delete_tag" \
        -height 23 \
        -highlightthickness 0 \
        -padx 0 -pady 0 -image delete_tag -width 23
    frame $base.cpd21.01.cpd25 \
        -background #dcdcdc -borderwidth 1 -height 30 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -relief raised \
        -width 30
    listbox $base.cpd21.01.cpd25.01 \
        -xscrollcommand "$base.cpd21.01.cpd25.02 set" \
        -yscrollcommand "$base.cpd21.01.cpd25.03 set" \
        -background white
    bindtags $base.cpd21.01.cpd25.01 "Listbox $base.cpd21.01.cpd25.01 $base all"
    bind $base.cpd21.01.cpd25.01 <Button-3> {
        ListboxBindings selection clear 0 end
        ListboxBindings selection set @%x,%y
        ListboxBindings activate @%x,%y
        ::widgets_bindings::enable_toolbar_buttons
        ::widgets_bindings::select_binding
    }
    bind $base.cpd21.01.cpd25.01 <ButtonRelease-1> {
        ::widgets_bindings::listbox_click
    }
    bind $base.cpd21.01.cpd25.01 <KeyRelease-Up> {
        ::widgets_bindings::listbox_click
    }
    bind $base.cpd21.01.cpd25.01 <KeyRelease-Prior> {
        ::widgets_bindings::listbox_click
    }
    bind $base.cpd21.01.cpd25.01 <KeyRelease-Down> {
        ::widgets_bindings::listbox_click
    }
    bind $base.cpd21.01.cpd25.01 <KeyRelease-Next> {
        ::widgets_bindings::listbox_click
    }
    bind $base.cpd21.01.cpd25.01 <ButtonRelease-3> {
        if {[::widgets_bindings::can_change_modifier %W \
            [lindex [%W curselection] 0] ]} {
            tk_popup %W.menu %X %Y
        }
    }
    bind $base.cpd21.01.cpd25.01 <KeyRelease-Delete> {
        ::widgets_bindings::delete_binding
    }
    menu $base.cpd21.01.cpd25.01.menu \
        -borderwidth 1 \
        -tearoff 0
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier ""} \
        -label {<no modifier>} 
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Double} \
        -label Double 
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Triple} \
        -label Triple 
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Control} \
        -label Control 
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Shift} \
        -label Shift 
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Meta} -label Meta
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Alt} -label Alt 
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Button1} \
        -label Button1 
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Button2} \
        -label Button2 
    $base.cpd21.01.cpd25.01.menu add command \
        -command {::widgets_bindings::right_click_modifier Button3} \
        -label Button3 
    scrollbar $base.cpd21.01.cpd25.02 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.cpd21.01.cpd25.01 xview" \
        -orient horizontal -troughcolor #dcdcdc  
    scrollbar $base.cpd21.01.cpd25.03 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.cpd21.01.cpd25.01 yview" \
        -troughcolor #dcdcdc  
    frame $base.cpd21.02 \
        -background #9900991B99FE -highlightbackground #dcdcdc \
        -highlightcolor #000000 
    frame $base.cpd21.02.cpd21 \
        -background #dcdcdc -borderwidth 1 -height 30 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -relief raised \
        -width 30 
    scrollbar $base.cpd21.02.cpd21.01 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.cpd21.02.cpd21.03 xview"  \
        -orient horizontal -troughcolor #dcdcdc  
    scrollbar $base.cpd21.02.cpd21.02 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.cpd21.02.cpd21.03 yview"  \
        -troughcolor #dcdcdc  
    text $base.cpd21.02.cpd21.03 \
        -background white \
        -foreground #000000 -height 1 -highlightbackground #ffffff \
        -highlightcolor #000000 -selectbackground #008080 \
        -selectforeground #ffffff -width 8 \
        -xscrollcommand "$base.cpd21.02.cpd21.01 set" \
        -yscrollcommand "$base.cpd21.02.cpd21.02 set" 
    bind $base.cpd21.02.cpd21.03 <ButtonRelease-3> {
        if {![winfo exists %W.menu]} { menu %W.menu }

        %W.menu configure -tearoff 0
        %W.menu delete 0 end
        %W.menu add command -label "%%%% Single percent"  \
            -command "TextBindings insert insert %%"
        %W.menu add command -label "%%\# Request number"  \
            -command "TextBindings insert insert %%\#"
        %W.menu add command -label "%%W Window name"  \
            -command "TextBindings insert insert %%W"
        %W.menu add command -label "%%b Mouse button number"  \
            -command "TextBindings insert insert %%b"
        %W.menu add command -label "%%d Detail"  \
            -command "TextBindings insert insert %%d"
        %W.menu add command -label "%%A Key pressed/released (ASCII)"  \
            -command "TextBindings insert insert %%A"
        %W.menu add command -label "%%K Key pressed/released (Keysym)"  \
            -command "TextBindings insert insert %%K"
        %W.menu add command -label "%%x Mouse x coordinate widget-relative"  \
            -command "TextBindings insert insert %%x"
        %W.menu add command -label "%%y Mouse y coordinate widget-relative"  \
            -command "TextBindings insert insert %%y"
        %W.menu add command -label "%%T Event type"  \
            -command "TextBindings insert insert %%T"
        %W.menu add command -label "%%X Mouse x coordinate desktop-relative"  \
            -command "TextBindings insert insert %%X"
        %W.menu add command -label "%%Y Mouse y coordinate desktop-relative"  \
            -command "TextBindings insert insert %%Y"
        tk_popup %W.menu %X %Y
    }
    bind $base.cpd21.02.cpd21.03 <FocusOut> {
        ::widgets_bindings::save_current_binding
    }

    frame $base.cpd21.03 \
        -background #ff0000 -borderwidth 2 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -relief raised 
    bind $base.cpd21.03 <B1-Motion> {
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
    pack $base.fra22 \
        -in $base -anchor center -expand 0 -fill x -side top 
    pack $base.fra22.but24 \
        -in $base.fra22 -anchor center -expand 0 -fill none -side right 
    pack $base.cpd21 \
        -in $base -anchor center -expand 1 -fill both -side top
    place $base.cpd21.01 \
        -x 0 -y 0 -width -1 -relwidth 0.3681 -relheight 1 -anchor nw \
        -bordermode ignore 
    pack $base.cpd21.01.fra22 \
        -in $base.cpd21.01 -anchor center -expand 0 -fill x -side top 
    pack $base.cpd21.01.fra22.men20 \
        -in $base.cpd21.01.fra22 -anchor center -expand 0 -fill none \
        -side left
    pack $base.cpd21.01.fra22.but24 \
        -in $base.cpd21.01.fra22 -anchor center -expand 0 -fill none \
        -side left 
    pack $base.cpd21.01.fra22.but27  \
        -in $base.cpd21.01.fra22 -anchor center -expand 0 -fill none \
        -side left
    pack $base.cpd21.01.fra22.but28  \
        -in $base.cpd21.01.fra22 -anchor center -expand 0 -fill none \
        -side left
    pack $base.cpd21.01.fra22.but25  \
        -in $base.cpd21.01.fra22 -anchor center -expand 0 -fill none \
        -side left 
    pack $base.cpd21.01.fra22.but26  \
        -in $base.cpd21.01.fra22 -anchor center -expand 0 -fill none \
        -side left 
    pack $base.cpd21.01.cpd25 \
        -in $base.cpd21.01 -anchor center -expand 1 -fill both -side top 
    grid columnconf $base.cpd21.01.cpd25 0 -weight 1
    grid rowconf $base.cpd21.01.cpd25 0 -weight 1
    grid $base.cpd21.01.cpd25.01 \
        -in $base.cpd21.01.cpd25 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.cpd21.01.cpd25.02 \
        -in $base.cpd21.01.cpd25 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew 
    grid $base.cpd21.01.cpd25.03 \
        -in $base.cpd21.01.cpd25 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns 
    place $base.cpd21.02 \
        -x 0 -relx 1 -y 0 -width -1 -relwidth 0.6319 -relheight 1 -anchor ne \
        -bordermode ignore 
    pack $base.cpd21.02.cpd21 \
        -in $base.cpd21.02 -anchor center -expand 1 -fill both -side top 
    grid columnconf $base.cpd21.02.cpd21 0 -weight 1
    grid rowconf $base.cpd21.02.cpd21 0 -weight 1
    grid $base.cpd21.02.cpd21.01 \
        -in $base.cpd21.02.cpd21 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew 
    grid $base.cpd21.02.cpd21.02 \
        -in $base.cpd21.02.cpd21 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns 
    grid $base.cpd21.02.cpd21.03 \
        -in $base.cpd21.02.cpd21 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    place $base.cpd21.03 \
        -x 0 -relx 0.3681 -y 0 -rely 0.9 -width 10 -height 10 -anchor s \
        -bordermode ignore

    vTcl:set_balloon $widget(AddBinding)    "Add a binding"
    vTcl:set_balloon $widget(RemoveBinding) "Remove a binding"
    vTcl:set_balloon $widget(MoveTagUp)     "Move tag up"
    vTcl:set_balloon $widget(MoveTagDown)   "Move tag down"
    vTcl:set_balloon $widget(AddTag)        "Add/Reuse tag"
    vTcl:set_balloon $widget(DeleteTag)     "Delete tag"

    Window hide .vTcl.newbind

    ::widgets_bindings::init

    catch {wm geometry $base $vTcl(geometry,$base)}
    wm deiconify $base
}

proc vTclWindow.vTcl.newbind {base {container 0}} {
    if {$base == ""} {
        set base .vTcl.newbind
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }

    global widget
    set widget(rev,$base) {BindingsInsert}
    set {widget(BindingsInsert)} "$base"
    set {widget(child,BindingsInsert)} ""
    interp alias {} BindingsInsert {} vTcl:Toplevel:WidgetProc $base
    set widget(rev,$base.fra23.cpd34.01) {BindingsModifiers}
    set {widget(BindingsModifiers)} "$base.fra23.cpd34.01"
    set {widget(child,BindingsModifiers)} "fra23.cpd34.01"
    interp alias {} BindingsModifiers {} vTcl:WidgetProc $base.fra23.cpd34.01
    set widget(rev,$base.fra23.cpd35.01) {BindingsEvents}
    set {widget(BindingsEvents)} "$base.fra23.cpd35.01"
    set {widget(child,BindingsEvents)} "fra23.cpd35.01"
    interp alias {} BindingsEvents {} vTcl:WidgetProc $base.fra23.cpd35.01
    set widget(rev,$base.fra36.ent38) {BindingsEventEntry}
    set {widget(BindingsEventEntry)} "$base.fra36.ent38"
    set {widget(child,BindingsEventEntry)} "fra36.ent38"
    interp alias {} BindingsEventEntry {} vTcl:WidgetProc $base.fra36.ent38

    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
        toplevel $base -class Toplevel
        wm focusmodel $base passive
        wm withdraw $base
        wm geometry $base 500x400+418+226
        update
        wm maxsize $base 1284 1010
        wm minsize $base 100 1
        wm overrideredirect $base 0
        wm resizable $base 1 1
        wm title $base "Insert new binding"
        wm transient .vTcl.newbind .vTcl
    }
    frame $base.fra20
    label $base.fra20.lab21 \
        -borderwidth 1 -foreground #000000 \
        -text {Type keystrokes}
    entry $base.fra20.ent22 \
        -background #ffffff -cursor {} -foreground #000000 \
        -textvariable bindingsKeystrokes -width 10
    bind $base.fra20.ent22 <Key> {
        set bindingsEventEntry "$bindingsEventEntry<Key-%K>"
        after idle {set bindingsKeystrokes ""}
    }
    frame $base.fra23
    label $base.fra23.lab24 \
        -borderwidth 1 \
        -text {Select a mouse event or a key event}
    frame $base.fra23.cpd34 \
        -background #dcdcdc -borderwidth 1 -height 30 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -relief raised \
        -width 30
    listbox $base.fra23.cpd34.01 \
        -xscrollcommand "$base.fra23.cpd34.02 set" \
        -yscrollcommand "$base.fra23.cpd34.03 set"
    bind $base.fra23.cpd34.01 <Button-1> {
        set modifier [BindingsModifiers get @%x,%y]
        set bindingsEventEntry [::widgets_bindings::set_modifier_in_event \
            $bindingsEventEntry $modifier]
    }
    scrollbar $base.fra23.cpd34.02 \
        -command "$base.fra23.cpd34.01 xview" \
        -orient horizontal
    scrollbar $base.fra23.cpd34.03 \
        -command "$base.fra23.cpd34.01 yview" \
        -orient vertical
    frame $base.fra23.cpd35 \
        -borderwidth 1 -relief raised
    listbox $base.fra23.cpd35.01 \
        -xscrollcommand "$base.fra23.cpd35.02 set" \
        -yscrollcommand "$base.fra23.cpd35.03 set"
    bind $base.fra23.cpd35.01 <Button-1> {
        set event [BindingsEvents get @%x,%y]
        if {![string match <<*>> $event]} {
            set event <$event>
        }
        set bindingsEventEntry $bindingsEventEntry$event
    }
    scrollbar $base.fra23.cpd35.02 \
        -command "$base.fra23.cpd35.01 xview"  \
        -orient horizontal
    scrollbar $base.fra23.cpd35.03 \
        -command "$base.fra23.cpd35.01 yview"  \
        -orient vertical
    frame $base.fra36
    label $base.fra36.lab37 \
        -borderwidth 1 -text Event
    entry $base.fra36.ent38 \
        -background #ffffff -cursor {} -foreground #000000 \
        -textvariable bindingsEventEntry
    bind $base.fra36.ent38 <ButtonRelease-1> {
        set index [BindingsEventEntry index @%x]
        set stindex ""
        set endindex ""
        ::widgets_bindings::find_event_in_sequence \
            $bindingsEventEntry $index stindex endindex
        BindingsEventEntry selection range $stindex [expr $endindex + 1]
    }
    bind $base.fra36.ent38 <Control-KeyRelease-Left> {
        set index [BindingsEventEntry index insert]
        set stindex ""
        set endindex ""
        ::widgets_bindings::find_event_in_sequence \
            $bindingsEventEntry $index stindex endindex
        BindingsEventEntry selection range $stindex [expr $endindex + 1]
    }
    bind $base.fra36.ent38 <Control-KeyRelease-Right> {
        set index [BindingsEventEntry index insert]
        set stindex ""
        set endindex ""
        ::widgets_bindings::find_event_in_sequence \
            $bindingsEventEntry $index stindex endindex
        BindingsEventEntry selection range $stindex [expr $endindex + 1]
    }
    frame $base.fra39
    button $base.fra39.but40 \
        -command {
             if {$bindingsEventEntry != ""} {
                 BindingsInsert hide
                 ::widgets_bindings::add_binding $bindingsEventEntry
             }
         } \
        -padx 9 -text Add -width 8
    button $base.fra39.but41 \
        -command {BindingsInsert hide} \
        -padx 9 -text Cancel -width 8
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra20 \
        -in $base -anchor center -expand 0 -fill x -ipady 10 -side top
    pack $base.fra20.lab21 \
        -in $base.fra20 -anchor center -expand 0 -fill none -side left
    pack $base.fra20.ent22 \
        -in $base.fra20 -anchor center -expand 0 -fill none -padx 5 \
        -side left
    pack $base.fra23 \
        -in $base -anchor center -expand 1 -fill both -side top
    pack $base.fra23.lab24 \
        -in $base.fra23 -anchor center -expand 0 -fill none -ipady 10 \
        -side top 
    pack $base.fra23.cpd34 \
        -in $base.fra23 -anchor center -expand 1 -fill both -side right 
    grid columnconf $base.fra23.cpd34 0 -weight 1
    grid rowconf $base.fra23.cpd34 0 -weight 1
    grid $base.fra23.cpd34.01 \
        -in $base.fra23.cpd34 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra23.cpd34.02 \
        -in $base.fra23.cpd34 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew 
    grid $base.fra23.cpd34.03 \
        -in $base.fra23.cpd34 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns 
    pack $base.fra23.cpd35 \
        -in $base.fra23 -anchor center -expand 1 -fill both -side left 
    grid columnconf $base.fra23.cpd35 0 -weight 1
    grid rowconf $base.fra23.cpd35 0 -weight 1
    grid $base.fra23.cpd35.01 \
        -in $base.fra23.cpd35 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw
    grid $base.fra23.cpd35.02 \
        -in $base.fra23.cpd35 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew 
    grid $base.fra23.cpd35.03 \
        -in $base.fra23.cpd35 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns 
    pack $base.fra36 \
        -in $base -anchor center -expand 0 -fill x -ipady 10 -side top 
    pack $base.fra36.lab37 \
        -in $base.fra36 -anchor center -expand 0 -fill none -side left 
    pack $base.fra36.ent38 \
        -in $base.fra36 -anchor center -expand 1 -fill x -side left 
    pack $base.fra39 \
        -in $base -anchor center -expand 0 -fill none -pady 5 -side top 
    pack $base.fra39.but40 \
        -in $base.fra39 -anchor center -expand 0 -fill none -padx 10 \
        -side left 
    pack $base.fra39.but41 \
        -in $base.fra39 -anchor center -expand 0 -fill none -padx 10 \
        -side right 

    BindingsModifiers delete 0 end
    foreach modifier {
        "<no modifier>" Double Triple Control
        Shift Meta Alt Lock
        Button1 Button2 Button3
    } {
        BindingsModifiers insert end $modifier
    }
    
    BindingsEvents delete 0 end
    foreach event {
        Button-1 Button-2 Button-3
        ButtonRelease-1 ButtonRelease-2 ButtonRelease-3
        Motion KeyPress KeyRelease Enter Leave
        FocusIn FocusOut Activate Deactivate MouseWheel 
        Map Unmap Configure
    } {
        BindingsEvents insert end $event
    }

    foreach event [event info] {
        BindingsEvents insert end $event
    }

    vTcl:center $base 500 400
    wm deiconify $base
}

proc vTclWindow.vTcl.newtag {base} {
    set container 0

    if {$base == ""} {
        set base .vTcl.newtag
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }

    # this window will be a modal one (I have to figure
    # out how to make this work) so this is why I
    # am destroying it when the user clicks "Cancel"

    global widget
    set widget(rev,$base.fra20.but21) {NewBindingTagOK}
    set {widget(NewBindingTagOK)} "$base.fra20.but21"
    set {widget(child,NewBindingTagOK)} "fra20.but21"
    interp alias {} NewBindingTagOK {} vTcl:WidgetProc $base.fra20.but21
    set widget(rev,$base.fra20.but23) {NewBindingTagCancel}
    set {widget(NewBindingTagCancel)} "$base.fra20.but23"
    set {widget(child,NewBindingTagCancel)} "fra20.but23"
    interp alias {} NewBindingTagCancel {} vTcl:WidgetProc $base.fra20.but23
    set widget(rev,$base.fra24.cpd26.01) {ListboxTags}
    set {widget(ListboxTags)} "$base.fra24.cpd26.01"
    set {widget(child,ListboxTags)} "fra24.cpd26.01"
    interp alias {} ListboxTags {} vTcl:WidgetProc $base.fra24.cpd26.01
    set widget(rev,$base.fra24.ent28) {NewBindingTagEntry}
    set {widget(NewBindingTagEntry)} "$base.fra24.ent28"
    set {widget(child,NewBindingTagEntry)} "fra24.ent28"
    interp alias {} NewBindingTagEntry {} vTcl:WidgetProc $base.fra24.ent28

    global NewBindingTagName
    set NewBindingTagName ""

    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
        toplevel $base -class Toplevel
        wm focusmodel $base passive
        wm geometry $base 340x319+149+138
        wm withdraw $base
        wm maxsize $base 1009 738
        wm minsize $base 1 1
        wm overrideredirect $base 0
        wm resizable $base 1 1
        vTcl:center $base 340 319
        wm deiconify $base
        wm title $base "Binding tags"
        wm transient .vTcl.newtag .vTcl
    }
    frame $base.fra20
    button $base.fra20.but21 \
        -text OK -width 8 \
        -command {
            if {$NewBindingTagName != ""} {
                ::widgets_bindings::addtag $NewBindingTagName
            } else {
                ::widgets_bindings::addtag \
                     [ListboxTags get [lindex [ListboxTags curselection] 0] ]
            }
            Window destroy .vTcl.newtag } \
        -state disabled
    button $base.fra20.but23 \
        -text Cancel -width 8 \
        -command "Window destroy .vTcl.newtag"
    frame $base.fra24 \
        -borderwidth 2 -height 75
    label $base.fra24.lab25 \
        -text {Select an existing tag:}
    frame $base.fra24.cpd26 \
        -borderwidth 1 \
        -relief raised \
        -width 30
    listbox $base.fra24.cpd26.01 \
        -xscrollcommand "$base.fra24.cpd26.02 set" \
        -yscrollcommand "$base.fra24.cpd26.03 set"
    scrollbar $base.fra24.cpd26.02 \
        -command "$base.fra24.cpd26.01 xview" \
        -orient horizontal
    scrollbar $base.fra24.cpd26.03 \
        -command "$base.fra24.cpd26.01 yview"  \
        -orient vertical
    label $base.fra24.lab27 \
        -text {Or name a new tag:}
    entry $base.fra24.ent28 \
        -textvariable NewBindingTagName -bg white
    bind $base.fra24.ent28 <KeyRelease> {
        if {$NewBindingTagName == ""} {
            NewBindingTagOK configure -state disabled
        } else {
            ListboxTags selection clear 0 end
            NewBindingTagOK configure -state normal
        }
    }
    bind $base.fra24.ent28 <ButtonRelease-1> {
        ListboxTags selection clear 0 end
    }
    bind $base.fra24.cpd26.01 <ButtonRelease-1> {
        set indices [ListboxTags curselection]
        if { [llength $indices] > 0} {
            NewBindingTagOK configure -state normal
            set NewBindingTagName \
                [ListboxTags get [lindex $indices 0] ]
        }
    }

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra20 \
        -in $base -anchor center -expand 0 -fill none -pady 5 -side bottom
    pack $base.fra20.but21 \
        -in $base.fra20 -anchor center -expand 0 -fill none -padx 5 \
        -side left
    pack $base.fra20.but23 \
        -in $base.fra20 -anchor center -expand 0 -fill none -padx 5 \
        -side right
    pack $base.fra24 \
        -in $base -anchor center -expand 1 -fill both -side top
    pack $base.fra24.lab25 \
        -in $base.fra24 -anchor center -expand 0 -fill none -side top
    pack $base.fra24.cpd26 \
        -in $base.fra24 -anchor center -expand 1 -fill both -side top
    grid columnconf $base.fra24.cpd26 0 -weight 1
    grid rowconf $base.fra24.cpd26 0 -weight 1
    grid $base.fra24.cpd26.01 \
        -in $base.fra24.cpd26 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw
    grid $base.fra24.cpd26.02 \
        -in $base.fra24.cpd26 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew
    grid $base.fra24.cpd26.03 \
        -in $base.fra24.cpd26 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns
    pack $base.fra24.lab27 \
        -in $base.fra24 -anchor center -expand 0 -fill none -side top
    pack $base.fra24.ent28 \
        -in $base.fra24 -anchor center -expand 0 -fill x -side top

    ListboxTags delete 0 end

    foreach tag $::widgets_bindings::tagslist {
        ListboxTags insert end $tag
    }
}

####################################
# code to manage the bindings editor
#

namespace eval ::widgets_bindings {

    variable tagslist ""

    proc {::widgets_bindings::listbox_click} {} {

        set widgets_bindings::lastselected [lindex [ListboxBindings curselection] 0]

        ::widgets_bindings::enable_toolbar_buttons
        after idle "::widgets_bindings::select_binding"
    }

    proc {::widgets_bindings::delete_tag} {} {
        global vTcl widget

        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]

        if {$index == ""} return

        set tag ""
        set event ""

        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag event

        if {![::widgets_bindings::is_editable_tag $tag]} return

        set target $widgets_bindings::target

        lremove vTcl(bindtags,$target) $tag

        ::widgets_bindings::fill_bindings $target
        ::widgets_bindings::select_show_binding $target ""
    }

    proc {::widgets_bindings::movetag} {moveupdown} {
        global vTcl widget

        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]

        if {$index == ""} return

        set tag ""
        set event ""

        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag event

        set target $widgets_bindings::target

        set tags $vTcl(bindtags,$target)

        # what position is the existing tag at ?
        set index [lsearch -exact $tags $tag]

        # what new position should it be
        if {$moveupdown == "down"} {
            set newindex [expr $index + 1]
            set oldtag [lindex $tags $newindex]
            set tags [lreplace $tags $index $newindex $oldtag $tag]
        } else {
            set newindex [expr $index - 1]
            set oldtag [lindex $tags $newindex]
            set tags [lreplace $tags $newindex $index $tag $oldtag]
        }

        set vTcl(bindtags,$target) $tags
        ::widgets_bindings::fill_bindings $target
        ::widgets_bindings::select_show_binding $tag ""
        ::widgets_bindings::enable_toolbar_buttons
    }

    proc {::widgets_bindings::addtag} {tag} {

        global vTcl widget

        # new tag ?
        if {[lsearch -exact $::widgets_bindings::tagslist $tag] == -1} {
            lappend ::widgets_bindings::tagslist $tag
        }

        set target $widgets_bindings::target

        # target has tag in its list ?
        if {[lsearch -exact $vTcl(bindtags,$target) $tag] == -1} {
            lappend vTcl(bindtags,$target) $tag
        }

        ::widgets_bindings::fill_bindings $target
        ::widgets_bindings::select_show_binding $tag ""     
        ::widgets_bindings::enable_toolbar_buttons
    }

    proc {::widgets_bindings::is_editable_tag} {tag} {
        global widget

        set target $widgets_bindings::target

        if {$tag == $target} {
            return 1
        }

        if {[lsearch -exact $::widgets_bindings::tagslist $tag] >= 0} {
            return 1
        }

        return 0
    }

    proc {::widgets_bindings::add_binding} {event} {
        global widget

        # before selecting a different binding, make sure we
        # save the current one
        ::widgets_bindings::save_current_binding

        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]

        if {$index == ""} {
            set index $::widgets_bindings::lastselected
        }

        set tag ""
        set tmp_event ""

        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag tmp_event

        set target $widgets_bindings::target

        if {![::widgets_bindings::is_editable_tag $tag]} return

        # event already bound ?
        set old_code [bind $tag $event]
        if {$old_code == ""} {
            bind $tag $event "\#TODO: your $event event handler here"
        }

        ::widgets_bindings::fill_bindings $target
        ::widgets_bindings::select_show_binding $tag $event
        ::widgets_bindings::enable_toolbar_buttons
    }

    proc {::widgets_bindings::can_change_modifier} {l index} {

        global widget

        set tag ""
        set event ""
        
        ::widgets_bindings::find_tag_event $l $index tag event
             
        if {[::widgets_bindings::is_editable_tag $tag] && 
            $event != ""} {
            return 1
        } else {
            return 0
        }
    }

    proc {::widgets_bindings::change_binding} {tag event modifier} {

        global widget
        set target $widgets_bindings::target
         
        if {![::widgets_bindings::is_editable_tag $tag]} return

        regexp <(.*)> $event matchAll event_name
         
        # unbind old event first
        bind $tag $event ""
        set ::widgets_bindings::lasttag ""
        set ::widgets_bindings::lastevent ""
        
        # rebind new event
        set event [::widgets_bindings::set_modifier_in_event  $event $modifier]
            
        bind $tag $event [TextBindings get 0.0 end]
        
        ::widgets_bindings::fill_bindings $target
        ::widgets_bindings::select_show_binding $tag $event
    }

    proc {::widgets_bindings::delete_binding} {} {

        global widget
        
        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]
        
        if {$index == ""} return
        
        set tag ""
        set event ""
        
        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag event
        
        set target $widgets_bindings::target

        if {![::widgets_bindings::is_editable_tag $tag] ||
            $event == ""} return
        
        bind $tag $event ""
        set ::widgets_bindings::lasttag ""
        set ::widgets_bindings::lastevent ""
        
        ::widgets_bindings::fill_bindings $target
    }

    proc {::widgets_bindings::enable_toolbar_buttons} {} {

        global widget vTcl
        
        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]
        
        if {$index == ""} {
            AddBinding    configure -state disabled
            RemoveBinding configure -state disabled
            MoveTagUp     configure -state disabled
            MoveTagDown   configure -state disabled
            DeleteTag     configure -state disabled
            return
        }
        
        set tag ""
        set event ""
        
        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag event
        
        if {[::widgets_bindings::is_editable_tag $tag]} {
            AddBinding configure -state normal
            
            if {$event == ""} {
            	DeleteTag configure -state normal
                RemoveBinding configure -state disabled
            } else {
                RemoveBinding configure -state normal
                DeleteTag     configure -state disabled
            }
        } else {
            AddBinding    configure -state disabled
            RemoveBinding configure -state disabled
            DeleteTag     configure -state disabled
        }

        set target $::widgets_bindings::target

        if {$event == ""} {
            if {$index > 0} {
                MoveTagUp   configure -state normal
            } else {
                MoveTagUp   configure -state disabled
            }

            set pos [lsearch -exact $vTcl(bindtags,$target) $tag]
            if {$pos == [expr [llength $vTcl(bindtags,$target)] - 1]} {
                MoveTagDown configure -state disabled
            } else {
                MoveTagDown configure -state normal
            }
        } else {
            MoveTagUp   configure -state disabled
            MoveTagDown configure -state disabled
        }
    }

    proc {::widgets_bindings::fill_bindings} {target {change 1}} {
        global widget vTcl tk_version

        # before selecting a different binding, make sure we
        # save the current one
        ::widgets_bindings::save_current_binding
        
        # w is the bindings editor window
        # target is the widgets whose bindings we want to edit
        
        set index 0
        set tags $vTcl(bindtags,$target)
        
        set ::widgets_bindings::bindingslist ""
        ListboxBindings delete 0 end
        
        set ::widgets_bindings::target $target

        foreach tag $tags {
           ListboxBindings insert end $tag
           if {[::widgets_bindings::is_editable_tag $tag]} {
               if {$tk_version > 8.2} {
                   ListboxBindings itemconfigure $index  -foreground blue
               }
           }
           
           lappend ::widgets_bindings::bindingslist [list $tag ""]
           incr index
           
           set events [bind $tag]
           foreach event $events {
               ListboxBindings insert end "   $event"
               if {[::widgets_bindings::is_editable_tag $tag]} {
                   if {$tk_version > 8.2} {
                       ListboxBindings itemconfigure $index  -foreground blue
                   }
               }
               
               lappend ::widgets_bindings::bindingslist [list $tag $event]
               incr index
           }
        }
                
        # enable/disable various buttons
        ::widgets_bindings::enable_toolbar_buttons

	if {$change} { ::vTcl::change }
    }

    proc {::widgets_bindings::find_tag_event} {l index ref_tag ref_event} {
        global widget
        
        upvar $ref_tag tag
        upvar $ref_event event
        
        if {$index == ""} {
            set tag ""
            set event ""
            return
        }
        
        set bindingslist $::widgets_bindings::bindingslist
        set tagevent [lindex $bindingslist $index]

        set tag   [lindex $tagevent 0]
        set event [lindex $tagevent 1]       
    }

    proc {::widgets_bindings::init} {} {
        global widget vTcl

        foreach tag $::widgets_bindings::tagslist {
            foreach event [bind $tag] {
                bind $tag $event ""
            }
        }

        set ::widgets_bindings::tagslist ""

        if {![winfo exists .vTcl.bind]} { return }
                
        ListboxBindings delete 0 end

        TextBindings configure -state normal
        TextBindings delete 0.0 end
        TextBindings configure -font $vTcl(pr,font_fixed) \
                               -background gray -state disabled
       
        variable lastselected 0
        variable lasttag ""
        variable lastevent ""
        variable target ""
        variable bindingslist ""

        # enable/disable various buttons
        ::widgets_bindings::enable_toolbar_buttons
    }

    proc {::widgets_bindings::right_click_modifier} {modifier} {

        global widget
        
        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]
        
        set tag ""
        set event ""
        
        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag event
        
        if {$tag == "" || $event == ""} {
            return
        }

        set target $widgets_bindings::target
        
        if {![::widgets_bindings::is_editable_tag $tag]} return
        
        ::widgets_bindings::change_binding $tag $event $modifier
    }

    proc {::widgets_bindings::save_current_binding} {} {

        global widget
              
        set target $::widgets_bindings::target
        set tag    $::widgets_bindings::lasttag
        set event  $::widgets_bindings::lastevent
        
        if {$tag == "" || $event == "" || $target == ""} { return }
        if {![winfo exists $target] } { return }
        if {![::widgets_bindings::is_editable_tag $tag]} { return }
                        
        set old_bind [string trim [bind $tag $event]]
        set new_bind [string trim [TextBindings get 0.0 end]]

        # is it really different?
        if {$new_bind != $old_bind} {
            bind $tag $event $new_bind
	    ::vTcl::change
        }
    }

    proc {::widgets_bindings::select_binding} {} {

        global widget
        
        # before selecting a different binding, make sure we
        # save the current one
        ::widgets_bindings::save_current_binding
        
        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]
        
        set tag ""
        set event ""
        
        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag event

        if {$tag == "" || $event == ""} {
        
            TextBindings configure -state normal
            TextBindings delete 0.0 end
            TextBindings configure  -state disabled -background gray
            set ::widgets_bindings::lasttag ""
            set ::widgets_bindings::lastevent ""
            return
        }
        
        ::widgets_bindings::show_binding $tag $event
        focus $widget(ListboxBindings)
        ListboxBindings selection set $index
    }

    proc {::widgets_bindings::select_show_binding} {tag event} {

        global widget
        
        # let's find it in the listbox first
        set lasttag ""
        set index 0
        
        # Tk replaces bindings with shortcuts
        regsub -all Button1 $event B1 event
        regsub -all Button2 $event B2 event
        regsub -all Button3 $event B3 event

        set bindingslist $::widgets_bindings::bindingslist
        
        foreach tag_event $bindingslist {

            set current_tag   [lindex $tag_event 0]
            set current_event [lindex $tag_event 1]

            if {$current_tag   == $tag &&
                $current_event == $event} {

                ListboxBindings selection clear 0 end
                ListboxBindings selection set $index
                ListboxBindings activate $index
                ListboxBindings see $index

                ::widgets_bindings::show_binding $tag $event
                break
            }

            incr index
        }
    }

    proc {::widgets_bindings::set_modifier_in_event} {event modifier} {
        global widget
        
        # modifiers not allowed for virtual events
        if {[string match <<*>> $event]} {
            return $event
        }
        
        # adds the modifier to the last event in the sequence
        
        set last [string last < $event]
        
        if {$last == -1} return
        
        if {$modifier == "<no modifier>" ||
            $modifier == ""} {
            regsub -all Button- $event Button_ event
            regsub -all ButtonRelease- $event ButtonRelease_ event
            regsub -all Key- $event Key_ event
            set lastmodifier [string last - $event]
            regsub -all Button_ $event Button- event
            regsub -all ButtonRelease_ $event ButtonRelease- event
            regsub -all Key_ $event Key- event
        
            if {$lastmodifier == -1} {
                return $event
            }
        
            set newbind [string range $event 0 $last]
            set newbind $newbind[string range $event [expr $lastmodifier+1] end]
            return $newbind
        }
        
        set newbind [string range $event 0 $last]
        set newbind $newbind${modifier}-[string range $event [expr $last+1] end]
        return $newbind
    }

    proc {::widgets_bindings::show_binding} {tag event} {

        global widget
        
        set bindcode [string trim [bind $tag $event]]
        
        TextBindings configure  -state normal
        TextBindings delete 0.0 end
        TextBindings insert 0.0 $bindcode
                
        if {[::widgets_bindings::is_editable_tag $tag] &&
            $event != ""} {
            TextBindings configure  -background white -state normal
            vTcl:syntax_color $widget(TextBindings) 0 -1
            
            set ::widgets_bindings::lasttag $tag
            set ::widgets_bindings::lastevent $event
        } else {
            TextBindings configure  -background gray -state disabled
        
            set ::widgets_bindings::lasttag ""
            set ::widgets_bindings::lastevent ""
        }
    }

    # given an event sequence ("eg. <Key-Space><Button-1>") and
    # an index into this event sequence (eg. 18) returns the start
    # and end index of the event pointed to
    #
    # in the example above the values returned would be 11 and 20

    proc {::widgets_bindings::find_event_in_sequence} \
       {sequence index ref_start_index ref_end_index} {

    	upvar $ref_start_index start_index
    	upvar $ref_end_index   end_index

    	if {$sequence == ""} {
            set start_index -1
            set end_index -1
            return
        }

    	regsub -all << $sequence <_ sequence
    	regsub -all >> $sequence _> sequence
    	set start_index $index
    	set end_index   $index

    	while {1} {
            set result [string range $sequence $start_index $end_index]

            if { ![string match *>  $result]} {
                incr end_index
                if {$end_index == [string length $sequence]} {
                    incr end_index -1
                    break
                }
            }

            if { ![string match <*  $result]} {
                incr start_index -1
                if {$start_index < 0} {
                    set start_index 0
                    break
                }
            }

            # exit condition ?
            if { [string match <*> $result]} {
                break
            }
    	}
    }

    proc {::widgets_bindings::get_standard_bindtags} {target} {
        # returns the default binding tags for any widget
        #
        # for example:
        #        .top19 => ".top19 Toplevel all"
        #
        #        .top19.but22 => ".top19.but22 Button .top19 all"

        set class [winfo class $target]
        if {$class == "Toplevel" || $class == "Vt" || $class == "Menu"} {
            return [list $target $class all]
        }

        set toplevel [winfo toplevel $target]
        return [list $target $class $toplevel all]
    }

} ; # namespace eval
