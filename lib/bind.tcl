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

    if [winfo exists .vTcl.bind] {
        ::widgets_bindings::fill_bindings $target
    }
}

proc vTclWindow.vTcl.bind {args} {
    global vTcl
    set container 0
    set base .vTcl.bind

    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }

    global widget
    set widget(rev,$base) {BindingsEditor}
    set {widget(BindingsEditor)} "$base"
    set {widget(child,BindingsEditor)} ""
    interp alias {} BindingsEditor {} vTcl:Toplevel:WidgetProc $base
    set widget(rev,$base.cpd21) {Frame4}
    set {widget(Frame4)} "$base.cpd21"
    set {widget(child,Frame4)} "cpd21"
    interp alias {} Frame4 {} vTcl:WidgetProc $base.cpd21
    set widget(rev,$base.cpd21.01) {Frame1}
    set {widget(Frame1)} "$base.cpd21.01"
    set {widget(child,Frame1)} "cpd21.01"
    interp alias {} Frame1 {} vTcl:WidgetProc $base.cpd21.01
    set widget(rev,$base.cpd21.01.cpd25) {Frame5}
    set {widget(Frame5)} "$base.cpd21.01.cpd25"
    set {widget(child,Frame5)} "cpd21.01.cpd25"
    interp alias {} Frame5 {} vTcl:WidgetProc $base.cpd21.01.cpd25
    set widget(rev,$base.cpd21.01.cpd25.01) {ListboxBindings}
    set {widget(ListboxBindings)} "$base.cpd21.01.cpd25.01"
    set {widget(child,ListboxBindings)} "cpd21.01.cpd25.01"
    interp alias {} ListboxBindings {} vTcl:WidgetProc $base.cpd21.01.cpd25.01
    set widget(rev,$base.cpd21.01.cpd25.02) {Scrollbar1}
    set {widget(Scrollbar1)} "$base.cpd21.01.cpd25.02"
    set {widget(child,Scrollbar1)} "cpd21.01.cpd25.02"
    interp alias {} Scrollbar1 {} vTcl:WidgetProc $base.cpd21.01.cpd25.02
    set widget(rev,$base.cpd21.01.cpd25.03) {Scrollbar2}
    set {widget(Scrollbar2)} "$base.cpd21.01.cpd25.03"
    set {widget(child,Scrollbar2)} "cpd21.01.cpd25.03"
    interp alias {} Scrollbar2 {} vTcl:WidgetProc $base.cpd21.01.cpd25.03
    set widget(rev,$base.cpd21.01.fra22.but24) {RemoveBinding}
    set {widget(RemoveBinding)} "$base.cpd21.01.fra22.but24"
    set {widget(child,RemoveBinding)} "cpd21.01.fra22.but24"
    interp alias {} RemoveBinding {} vTcl:WidgetProc $base.cpd21.01.fra22.but24
    set widget(rev,$base.cpd21.01.fra22.men20) {AddBinding}
    set {widget(AddBinding)} "$base.cpd21.01.fra22.men20"
    set {widget(child,AddBinding)} "cpd21.01.fra22.men20"
    interp alias {} AddBinding {} vTcl:WidgetProc $base.cpd21.01.fra22.men20
    set widget(rev,$base.cpd21.02) {Frame2}
    set {widget(Frame2)} "$base.cpd21.02"
    set {widget(child,Frame2)} "cpd21.02"
    interp alias {} Frame2 {} vTcl:WidgetProc $base.cpd21.02
    set widget(rev,$base.cpd21.02.cpd21) {Frame6}
    set {widget(Frame6)} "$base.cpd21.02.cpd21"
    set {widget(child,Frame6)} "cpd21.02.cpd21"
    interp alias {} Frame6 {} vTcl:WidgetProc $base.cpd21.02.cpd21
    set widget(rev,$base.cpd21.02.cpd21.01) {Scrollbar3}
    set {widget(Scrollbar3)} "$base.cpd21.02.cpd21.01"
    set {widget(child,Scrollbar3)} "cpd21.02.cpd21.01"
    interp alias {} Scrollbar3 {} vTcl:WidgetProc $base.cpd21.02.cpd21.01
    set widget(rev,$base.cpd21.02.cpd21.02) {Scrollbar4}
    set {widget(Scrollbar4)} "$base.cpd21.02.cpd21.02"
    set {widget(child,Scrollbar4)} "cpd21.02.cpd21.02"
    interp alias {} Scrollbar4 {} vTcl:WidgetProc $base.cpd21.02.cpd21.02
    set widget(rev,$base.cpd21.02.cpd21.03) {TextBindings}
    set {widget(TextBindings)} "$base.cpd21.02.cpd21.03"
    set {widget(child,TextBindings)} "cpd21.02.cpd21.03"
    interp alias {} TextBindings {} vTcl:WidgetProc $base.cpd21.02.cpd21.03
    set widget(rev,$base.cpd21.03) {Frame3}
    set {widget(Frame3)} "$base.cpd21.03"
    set {widget(child,Frame3)} "cpd21.03"
    interp alias {} Frame3 {} vTcl:WidgetProc $base.cpd21.03
    set widget(MoveTagUp) $base.cpd21.01.fra22.but25
    set widget(MoveTagDown) $base.cpd21.01.fra22.but26
    set widget(AddTag) $base.cpd21.01.fra22.but27
    
    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
        toplevel $base -class Toplevel \
            -background #dcdcdc -highlightbackground #dcdcdc \
            -highlightcolor #000000 
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
        -image [vTcl:image:get_image "/home/cgavin/vtcl/images/edit/ok.gif"] \
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
        -image [vTcl:image:get_image "/home/cgavin/vtcl/images/edit/add.gif"] \
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
        -image [vTcl:image:get_image "/home/cgavin/vtcl/images/edit/remove.gif"] \
        -padx 0 -pady 0 -text button -width 23 
    button $base.cpd21.01.fra22.but25 \
        -command "tk_messageBox -message {To be implemented}" \
        -height 23 \
        -highlightthickness 0 \
        -image up \
        -padx 0 -pady 0 -text button -width 23 
    button $base.cpd21.01.fra22.but26 \
        -command "tk_messageBox -message {To be implemented}" \
        -height 23 \
        -highlightthickness 0 \
        -image down \
        -padx 0 -pady 0 -text button -width 23 
    button $base.cpd21.01.fra22.but27 \
        -command "tk_messageBox -message {To be implemented}" \
        -height 23 \
        -highlightthickness 0 \
        -padx 0 -pady 0 -image icon_message.gif -width 23 
    frame $base.cpd21.01.cpd25 \
        -background #dcdcdc -borderwidth 1 -height 30 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -relief raised \
        -width 30 
    listbox $base.cpd21.01.cpd25.01 \
        -selectmode single \
        -xscrollcommand "$base.cpd21.01.cpd25.02 set" \
        -yscrollcommand "$base.cpd21.01.cpd25.03 set" 
    bind $base.cpd21.01.cpd25.01 <Button-3> {
        ListboxBindings selection clear 0 end
        ListboxBindings selection set @%x,%y
        ::widgets_bindings::enable_toolbar_buttons
        ::widgets_bindings::select_binding
    }
    bind $base.cpd21.01.cpd25.01 <ButtonRelease-1> {
        set n [vTcl:rename $widget(BindingsEditor)]
        set ${n}::lastselected [lindex [ListboxBindings curselection] 0]

        ::widgets_bindings::enable_toolbar_buttons
        after idle "::widgets_bindings::select_binding"
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
        -highlightbackground #dcdcdc -highlightcolor #000000 \
        -orient horizontal -troughcolor #dcdcdc  
    scrollbar $base.cpd21.01.cpd25.03 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.cpd21.01.cpd25.01 yview" \
        -highlightbackground #dcdcdc -highlightcolor #000000 \
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
        -highlightbackground #dcdcdc -highlightcolor #000000 \
        -orient horizontal -troughcolor #dcdcdc  
    scrollbar $base.cpd21.02.cpd21.02 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.cpd21.02.cpd21.03 yview"  \
        -highlightbackground #dcdcdc -highlightcolor #000000 \
        -troughcolor #dcdcdc  
    text $base.cpd21.02.cpd21.03 \
        -background white \
        -foreground #000000 -height 1 -highlightbackground #ffffff \
        -highlightcolor #000000 -selectbackground #008080 \
        -selectforeground #ffffff -width 8 \
        -xscrollcommand "$base.cpd21.02.cpd21.01 set" \
        -yscrollcommand "$base.cpd21.02.cpd21.02 set" 
    bind $base.cpd21.02.cpd21.03 <ButtonRelease-3> {
        if {! [winfo exists %W.menu] } {
            menu %W.menu
        }

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
        -side left -padx 5
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
    set widget(rev,$base.fra23.cpd34) {Frame7}
    set {widget(Frame7)} "$base.fra23.cpd34"
    set {widget(child,Frame7)} "fra23.cpd34"
    interp alias {} Frame7 {} vTcl:WidgetProc $base.fra23.cpd34
    set widget(rev,$base.fra23.cpd34.01) {BindingsModifiers}
    set {widget(BindingsModifiers)} "$base.fra23.cpd34.01"
    set {widget(child,BindingsModifiers)} "fra23.cpd34.01"
    interp alias {} BindingsModifiers {} vTcl:WidgetProc $base.fra23.cpd34.01
    set widget(rev,$base.fra23.cpd34.02) {Scrollbar5}
    set {widget(Scrollbar5)} "$base.fra23.cpd34.02"
    set {widget(child,Scrollbar5)} "fra23.cpd34.02"
    interp alias {} Scrollbar5 {} vTcl:WidgetProc $base.fra23.cpd34.02
    set widget(rev,$base.fra23.cpd34.03) {Scrollbar6}
    set {widget(Scrollbar6)} "$base.fra23.cpd34.03"
    set {widget(child,Scrollbar6)} "fra23.cpd34.03"
    interp alias {} Scrollbar6 {} vTcl:WidgetProc $base.fra23.cpd34.03
    set widget(rev,$base.fra23.cpd35) {Frame8}
    set {widget(Frame8)} "$base.fra23.cpd35"
    set {widget(child,Frame8)} "fra23.cpd35"
    interp alias {} Frame8 {} vTcl:WidgetProc $base.fra23.cpd35
    set widget(rev,$base.fra23.cpd35.01) {BindingsEvents}
    set {widget(BindingsEvents)} "$base.fra23.cpd35.01"
    set {widget(child,BindingsEvents)} "fra23.cpd35.01"
    interp alias {} BindingsEvents {} vTcl:WidgetProc $base.fra23.cpd35.01
    set widget(rev,$base.fra23.cpd35.02) {Scrollbar7}
    set {widget(Scrollbar7)} "$base.fra23.cpd35.02"
    set {widget(child,Scrollbar7)} "fra23.cpd35.02"
    interp alias {} Scrollbar7 {} vTcl:WidgetProc $base.fra23.cpd35.02
    set widget(rev,$base.fra23.cpd35.03) {Scrollbar8}
    set {widget(Scrollbar8)} "$base.fra23.cpd35.03"
    set {widget(child,Scrollbar8)} "fra23.cpd35.03"
    interp alias {} Scrollbar8 {} vTcl:WidgetProc $base.fra23.cpd35.03
    set widget(rev,$base.fra36.ent38) {BindingsEventEntry}
    set {widget(BindingsEventEntry)} "$base.fra36.ent38"
    set {widget(child,BindingsEventEntry)} "fra36.ent38"
    interp alias {} BindingsEventEntry {} vTcl:WidgetProc $base.fra36.ent38

    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
        toplevel $base -class Toplevel \
            -background #dcdcdc -highlightbackground #dcdcdc \
            -highlightcolor #000000 
        wm focusmodel $base passive
        wm geometry $base 541x457+418+226
        update
        wm maxsize $base 1284 1010
        wm minsize $base 100 1
        wm overrideredirect $base 0
        wm resizable $base 1 1
        wm deiconify $base
        wm title $base "Insert new binding"
        wm transient .vTcl.newbind .vTcl
    }
    frame $base.fra20 \
        -background #dcdcdc -borderwidth 2 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -width 125 
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
    frame $base.fra23 \
        -background #dcdcdc -borderwidth 2 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -width 125 
    label $base.fra23.lab24 \
        -borderwidth 1 \
        -text {Select a mouse event or a key event} 
    bind $base.fra23.lab24 <Double-Key-a> {
        puts "aa"
    }
    frame $base.fra23.cpd34 \
        -background #dcdcdc -borderwidth 1 -height 30 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -relief raised \
        -width 30 
    listbox $base.fra23.cpd34.01 \
        -background #dcdcdc \
        -foreground #000000 -highlightbackground #ffffff \
        -highlightcolor #000000 -selectbackground #008080 \
        -selectforeground #ffffff -xscrollcommand "$base.fra23.cpd34.02 set" \
        -yscrollcommand "$base.fra23.cpd34.03 set" 
    bind $base.fra23.cpd34.01 <Button-1> {
        set modifier [BindingsModifiers get @%x,%y]
        set bindingsEventEntry [::widgets_bindings::set_modifier_in_event \
            $bindingsEventEntry $modifier]
    }
    scrollbar $base.fra23.cpd34.02 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.fra23.cpd34.01 xview"  \
        -highlightbackground #dcdcdc -highlightcolor #000000 \
        -orient horizontal -troughcolor #dcdcdc  
    scrollbar $base.fra23.cpd34.03 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.fra23.cpd34.01 yview"  \
        -highlightbackground #dcdcdc -highlightcolor #000000 \
        -troughcolor #dcdcdc  
    frame $base.fra23.cpd35 \
        -background #dcdcdc -borderwidth 1 -height 30 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -relief raised \
        -width 30 
    listbox $base.fra23.cpd35.01 \
        -background #dcdcdc \
        -foreground #000000 -highlightbackground #ffffff \
        -highlightcolor #000000 -selectbackground #008080 \
        -selectforeground #ffffff -xscrollcommand "$base.fra23.cpd35.02 set" \
        -yscrollcommand "$base.fra23.cpd35.03 set" 
    bind $base.fra23.cpd35.01 <Button-1> {
        set event [BindingsEvents get @%x,%y]
        if {![string match <<*>> $event]} {
            set event <$event>
        }
        set bindingsEventEntry $bindingsEventEntry$event
    }
    scrollbar $base.fra23.cpd35.02 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.fra23.cpd35.01 xview"  \
        -highlightbackground #dcdcdc -highlightcolor #000000 \
        -orient horizontal -troughcolor #dcdcdc  
    scrollbar $base.fra23.cpd35.03 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.fra23.cpd35.01 yview"  \
        -highlightbackground #dcdcdc -highlightcolor #000000 \
        -troughcolor #dcdcdc  
    frame $base.fra36 \
        -background #dcdcdc -borderwidth 2 -height 75 \
        -highlightbackground #dcdcdc -highlightcolor #000000 
    label $base.fra36.lab37 \
        -borderwidth 1 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -text Event 
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
    frame $base.fra39 \
        -background #dcdcdc -borderwidth 2 -height 75 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -width 125 
    button $base.fra39.but40 \
        -activebackground #dcdcdc -activeforeground #000000 \
        -background #dcdcdc \
        -command {
             if {$bindingsEventEntry != ""} {
                 BindingsInsert hide
                 ::widgets_bindings::add_binding $bindingsEventEntry
             }
         } \
        -foreground #000000 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -padx 9 -pady 3 -text Add -width 8 
    button $base.fra39.but41 \
        -activebackground #dcdcdc -activeforeground #000000 \
        -background #dcdcdc -command {BindingsInsert hide} \
        -foreground #000000 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -padx 9 -pady 3 -text Cancel -width 8 
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
}

#################################
# USER DEFINED PROCEDURES
#

namespace eval ::widgets_bindings {

    proc {::widgets_bindings::add_binding} {event} {

        global widget
        
        # before selecting a different binding, make sure we
        # save the current one
        ::widgets_bindings::save_current_binding
        
        set w $widget(BindingsEditor)
        set n [vTcl:rename $w]
        eval set index $${n}::lastselected
        
        set tag ""
        set tmp_event ""
        
        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag tmp_event
        
        eval set target $${n}::target
        
        if {$tag != $target} {
           return
        }
        
        # event already bound ?
        set old_code [bind $tag $event]
        if {$old_code == ""} {
            bind $tag $event "\#TODO: your $event event handler here"
        }
        
        ::widgets_bindings::fill_bindings $target
        ::widgets_bindings::select_show_binding $tag $event     
    }

    proc {::widgets_bindings::can_change_modifier} {l index} {

        global widget

        set tag ""
        set event ""
        
        ::widgets_bindings::find_tag_event $l $index tag event
        
        set n [vTcl:rename $widget(BindingsEditor)]
        eval set target $${n}::target
        
        if {$tag   == $target && 
            $event != ""} {
            return 1
        } else {
            return 0
        }    
    }

    proc {::widgets_bindings::change_binding} {tag event modifier} {

        global widget
        set w $widget(BindingsEditor)
         
        set n [vTcl:rename $w]
        eval set target $${n}::target
         
        if {$tag != $target} return
        regexp <(.*)> $event matchAll event_name
         
        # unbind old event first
        bind $target $event ""
        set ::${n}::lasttag ""
        set ::${n}::lastevent ""
         
        # rebind new event
        set event [::widgets_bindings::set_modifier_in_event  $event $modifier]
            
        bind $target $event [TextBindings get 0.0 end]
         
        ::widgets_bindings::fill_bindings $target
        ::widgets_bindings::select_show_binding $tag $event
    }

    proc {::widgets_bindings::delete_binding} {} {

        global widget
        
        set w $widget(BindingsEditor)
        set n [vTcl:rename $w]
        
        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]
        
        if {$index == ""} return
        
        set tag ""
        set event ""
        
        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag event
        
        eval set target $${n}::target
        
        if {$tag != $target ||
            $event == ""} {
           return
        }
        
        bind $target $event ""
        set ::${n}::lasttag ""
        set ::${n}::lastevent ""
        
        ::widgets_bindings::fill_bindings $target
    }

    proc {::widgets_bindings::enable_toolbar_buttons} {} {

        global widget
        
        set w $widget(BindingsEditor)
        set n [vTcl:rename $w]
        
        set indices [ListboxBindings curselection]
        set index [lindex $indices 0]
        
        if {$index == ""} {
            AddBinding    configure -state disabled
            RemoveBinding configure -state disabled
            return
        }
        
        set tag ""
        set event ""
        
        ::widgets_bindings::find_tag_event \
            $widget(ListboxBindings) $index tag event
        
        eval set target $${n}::target
        
        if {$tag == $target} {
            AddBinding configure -state normal
            
            if {$event == ""} {
                RemoveBinding configure -state disabled
            } else {
                RemoveBinding configure -state normal
            }
        } else {
            AddBinding    configure -state disabled
            RemoveBinding configure -state disabled
        }
    }

    proc {::widgets_bindings::fill_bindings} {target} {

        global widget vTcl tk_version

        set w $widget(BindingsEditor)
        set n [vTcl:rename $w]
        
        # before selecting a different binding, make sure we
        # save the current one
        ::widgets_bindings::save_current_binding
        
        # w is the bindings editor window
        # target is the widgets whose bindings we want to edit
        
        set index 0
        set tags $vTcl(bindtags,$target)
        
        set ::${n}::bindingslist ""
        ListboxBindings delete 0 end
        
        foreach tag $tags {
        
           ListboxBindings insert end $tag
           if {$tag == $target} {
               if {$tk_version > 8.2} {
                   ListboxBindings itemconfigure $index  -foreground blue
               }
           }
           
           lappend ::${n}::bindingslist [list $tag ""]
           incr index
           
           set events [bind $tag]
           foreach event $events {
              
               ListboxBindings insert end "   $event"
               if {$tag == $target} {
                   if {$tk_version > 8.2} {
                       ListboxBindings itemconfigure $index  -foreground blue
                   }
               }
               
               lappend ::${n}::bindingslist [list $tag $event]
               incr index
           }
        }
        
        set ::${n}::target $target
        
        # enable/disable various buttons
        ::widgets_bindings::enable_toolbar_buttons
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
        
        set w $widget(BindingsEditor)
        set n [vTcl:rename $w]

        eval set bindingslist \$::${n}::bindingslist
        set tagevent [lindex $bindingslist $index]

        set tag   [lindex $tagevent 0]
        set event [lindex $tagevent 1]       
    }

    proc {::widgets_bindings::init} {} {

        global widget vTcl
                
        ListboxBindings delete 0 end

        TextBindings configure -state normal
        TextBindings delete 0.0 end
        TextBindings configure -font $vTcl(pr,font_fixed) \
                               -background gray -state disabled
 
        set w $widget(BindingsEditor)
        set n [vTcl:rename $w]
        
        namespace eval ::${n} {
            variable lastselected 0
            variable lasttag ""
            variable lastevent ""
            variable target ""
            variable bindingslist ""
        }

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
        
        set w $widget(BindingsEditor)
        set n [vTcl:rename $w]
        eval set target $${n}::target
        
        if {$tag != $target} {
           return
        }
        
        ::widgets_bindings::change_binding $tag $event $modifier
    }

    proc {::widgets_bindings::save_current_binding} {} {

        global widget
        
        set w $widget(BindingsEditor)
        set n [vTcl:rename $w]
        
        eval set target \$::${n}::target
        eval set tag    \$::${n}::lasttag
        eval set event  \$::${n}::lastevent
        
        if {$tag == "" ||
            $event == "" ||
            $target == ""} {
            return
        }
        
        if {$tag != $target} {
           return
        }
        
        # debug
        # puts "updating: $tag $event"
        # end-debug
     
        if { [winfo exists $target] } {
           
            bind $tag $event [string trim [TextBindings get 0.0 end]]
        }
        
        set ::${n}::lasttag ""
        set ::${n}::lastevent ""
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

        set w $widget(BindingsEditor)
        set n [vTcl:rename $w]

        eval set bindingslist \$::${n}::bindingslist
        
        foreach tag_event $bindingslist {

            set current_tag   [lindex $tag_event 0]
            set current_event [lindex $tag_event 1]
            
            if {$current_tag   == $tag &&
                $current_event == $event} {
                    
                ListboxBindings selection clear 0 end
                ListboxBindings selection set $index
                    
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
        
        set w $widget(BindingsEditor)
        set n [vTcl:rename $w]
        eval set target $${n}::target
        
        if {$tag == $target} {
            TextBindings configure  -background white -state normal
            vTcl:syntax_color $widget(TextBindings) 0 -1
            
            set ::${n}::lasttag $tag
            set ::${n}::lastevent $event
        } else {
            TextBindings configure  -background gray -state disabled
        
            set ::${n}::lasttag ""
            set ::${n}::lastevent ""
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
    
} ; # namespace eval
