##############################################################################
#
# compounds.tcl - bundled system compound widgets
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

namespace eval {vTcl::compounds::system::{Scrollable Listbox}} {

set bindtags {}

set source .top80.cpd85

set class Frame

set procs {}


proc bindtagsCmd {} {}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-background 1 -xscrollcommand 1 -yscrollcommand 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-command 1 -orient 1}
    }
    namespace eval ::widgets::$site_3_0.03 {
        array set save {-command 1}
    }

}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -height 30 -width 30 
    vTcl:DefineAlias "$target" "Frame8" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $target
    listbox $site_3_0.01  -background white -xscrollcommand "$site_3_0.02 set" -yscrollcommand "$site_3_0.03 set" 
    vTcl:DefineAlias "$site_3_0.01" "Listbox1" vTcl:WidgetProc "Toplevel1" 1
    scrollbar $site_3_0.02  -command "$site_3_0.01 xview" -orient horizontal 
    vTcl:DefineAlias "$site_3_0.02" "Scrollbar3" vTcl:WidgetProc "Toplevel1" 1
    scrollbar $site_3_0.03  -command "$site_3_0.01 yview" 
    vTcl:DefineAlias "$site_3_0.03" "Scrollbar4" vTcl:WidgetProc "Toplevel1" 1
    grid $site_3_0.01  -in $site_3_0 -column 0 -row 0 -columnspan 1 -rowspan 1 -sticky nesw 
    grid $site_3_0.02  -in $site_3_0 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew 
    grid $site_3_0.03  -in $site_3_0 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns 

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Labeled Frame}} {

set bindtags {}

set source .top80.cpd81

set class Frame

set procs {}


proc bindtagsCmd {} {}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-borderwidth 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.01
    namespace eval ::widgets::$site_4_0.fra82 {
        array set save {-borderwidth 1 -height 1}
    }
    namespace eval ::widgets::$site_4_0.fra83 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-borderwidth 1 -text 1}
    }

}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -borderwidth 2 
    vTcl:DefineAlias "$target" "Frame2" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $target
    frame $site_3_0.01  -borderwidth 2 -height 75 -relief groove -width 125 
    vTcl:DefineAlias "$site_3_0.01" "Frame1" vTcl:WidgetProc "Toplevel1" 1
    set site_4_0 $site_3_0.01
    frame $site_4_0.fra82  -borderwidth 2 -height 10 
    vTcl:DefineAlias "$site_4_0.fra82" "Frame3" vTcl:WidgetProc "Toplevel1" 1
    frame $site_4_0.fra83  -background #cccccc -borderwidth 2 -height 75 -width 150 
    vTcl:DefineAlias "$site_4_0.fra83" "Frame4" vTcl:WidgetProc "Toplevel1" 1
    pack $site_4_0.fra82  -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_4_0.fra83  -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -pady 2  -side top 
    label $site_3_0.02  -borderwidth 1 -text {TODO: type label here} 
    vTcl:DefineAlias "$site_3_0.02" "Label1" vTcl:WidgetProc "Toplevel1" 1
    pack $site_3_0.01  -in $site_3_0 -anchor center -expand 1 -fill both -padx 5 -pady 5  -side top 
    place $site_3_0.02  -x 15 -y 0 -anchor nw -bordermode ignore 

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Scrollable Text}} {

set bindtags {}

set source .top82.cpd83

set class Frame

set procs {}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-command 1 -orient 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-command 1}
    }
    namespace eval ::widgets::$site_3_0.03 {
        array set save {-height 1 -width 1 -xscrollcommand 1 -yscrollcommand 1}
    }

}


proc bindtagsCmd {} {}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -height 30 -width 30 
    vTcl:DefineAlias "$target" "Frame1" vTcl:WidgetProc "Toplevel2" 1
    set site_3_0 $target
    scrollbar $site_3_0.01  -command "$site_3_0.03 xview" -orient horizontal 
    vTcl:DefineAlias "$site_3_0.01" "Scrollbar1" vTcl:WidgetProc "Toplevel2" 1
    scrollbar $site_3_0.02  -command "$site_3_0.03 yview" 
    vTcl:DefineAlias "$site_3_0.02" "Scrollbar2" vTcl:WidgetProc "Toplevel2" 1
    text $site_3_0.03  -height 10 -width 20 -xscrollcommand "$site_3_0.01 set"  -yscrollcommand "$site_3_0.02 set" 
    vTcl:DefineAlias "$site_3_0.03" "Text1" vTcl:WidgetProc "Toplevel2" 1
    grid $site_3_0.01  -in $site_3_0 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew 
    grid $site_3_0.02  -in $site_3_0 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns 
    grid $site_3_0.03  -in $site_3_0 -column 0 -row 0 -columnspan 1 -rowspan 1 -sticky nesw 

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Label And Entry}} {

set bindtags {}

set source .top80.cpd82

set class Frame

set procs {}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-borderwidth 1 -height 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-anchor 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-cursor 1}
    }

}


proc bindtagsCmd {} {}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -borderwidth 1 -height 30 
    vTcl:DefineAlias "$target" "Frame5" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $target
    label $site_3_0.01  -anchor w -text Label: 
    vTcl:DefineAlias "$site_3_0.01" "Label2" vTcl:WidgetProc "Toplevel1" 1
    entry $site_3_0.02  -cursor {} 
    vTcl:DefineAlias "$site_3_0.02" "Entry1" vTcl:WidgetProc "Toplevel1" 1
    pack $site_3_0.01  -in $site_3_0 -anchor center -expand 0 -fill none -padx 2 -pady 2  -side left 
    pack $site_3_0.02  -in $site_3_0 -anchor center -expand 1 -fill x -padx 2 -pady 2  -side right 

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Split Vertical Panel}} {

set bindtags {}

set source .top80.cpd82

set class Frame

set procs {}


proc bindtagsCmd {} {}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-background 1 -height 1 -width 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-background 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-background 1}
    }
    namespace eval ::widgets::$site_3_0.03 {
        array set save {-background 1 -borderwidth 1 -relief 1}
    }

}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -background #000000 -height 100 -width 200 
    vTcl:DefineAlias "$target" "Frame8" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $target
    frame $site_3_0.01  -background #9900991B99FE 
    vTcl:DefineAlias "$site_3_0.01" "Frame5" vTcl:WidgetProc "Toplevel1" 1
    frame $site_3_0.02  -background #9900991B99FE 
    vTcl:DefineAlias "$site_3_0.02" "Frame6" vTcl:WidgetProc "Toplevel1" 1
    frame $site_3_0.03  -background #ff0000 -borderwidth 2 -relief raised 
    vTcl:DefineAlias "$site_3_0.03" "Frame7" vTcl:WidgetProc "Toplevel1" 1
    bind $site_3_0.03 <B1-Motion> {
        set root [ split %W . ]
    set nb [ llength $root ]
    incr nb -1
    set root [ lreplace $root $nb $nb ]
    set root [ join $root . ]
    set height [ winfo height $root ].0
    
    set val [ expr (%Y - [winfo rooty $root]) /$height ]

    if { $val >= 0 && $val <= 1.0 } {
    
        place $root.01 -relheight $val
        place $root.03 -rely $val
        place $root.02 -relheight [ expr 1.0 - $val ]
    }
    }
    place $site_3_0.01  -x 0 -y 0 -relwidth 1 -height -1 -relheight 0.6595 -anchor nw  -bordermode ignore 
    place $site_3_0.02  -x 0 -y 0 -rely 1 -relwidth 1 -height -1 -relheight 0.3405 -anchor sw  -bordermode ignore 
    place $site_3_0.03  -x 0 -relx 0.9 -y 0 -rely 0.6595 -width 10 -height 10 -anchor e  -bordermode ignore 

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Split Horizontal Panel}} {

set bindtags {}

set source .top80.cpd81

set class Frame

set procs {}


proc bindtagsCmd {} {}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-background 1 -height 1 -width 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-background 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-background 1}
    }
    namespace eval ::widgets::$site_3_0.03 {
        array set save {-background 1 -borderwidth 1 -relief 1}
    }

}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -background #000000 -height 100 -width 200 
    vTcl:DefineAlias "$target" "Frame4" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $target
    frame $site_3_0.01  -background #9900991B99FE 
    vTcl:DefineAlias "$site_3_0.01" "Frame1" vTcl:WidgetProc "Toplevel1" 1
    frame $site_3_0.02  -background #9900991B99FE 
    vTcl:DefineAlias "$site_3_0.02" "Frame2" vTcl:WidgetProc "Toplevel1" 1
    frame $site_3_0.03  -background #ff0000 -borderwidth 2 -relief raised 
    vTcl:DefineAlias "$site_3_0.03" "Frame3" vTcl:WidgetProc "Toplevel1" 1
    bind $site_3_0.03 <B1-Motion> {
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
    place $site_3_0.01  -x 0 -y 0 -width -1 -relwidth 0.6595 -relheight 1 -anchor nw  -bordermode ignore 
    place $site_3_0.02  -x 0 -relx 1 -y 0 -width -1 -relwidth 0.3405 -relheight 1 -anchor ne  -bordermode ignore 
    place $site_3_0.03  -x 0 -relx 0.6595 -y 0 -rely 0.9 -width 10 -height 10 -anchor s  -bordermode ignore 

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Menu Bar}} {

set bindtags {}

set source .top80.cpd82

set class Frame

set procs {}


proc bindtagsCmd {} {}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-anchor 1 -menu 1 -padx 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.01.02 {
        array set save {-activeborderwidth 1 -borderwidth 1 -font 1 -tearoff 1}
    }
    namespace eval ::widgets::$site_3_0.03 {
        array set save {-anchor 1 -menu 1 -padx 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.03.04 {
        array set save {-activeborderwidth 1 -borderwidth 1 -font 1 -tearoff 1}
    }
    namespace eval ::widgets::$site_3_0.05 {
        array set save {-anchor 1 -menu 1 -padx 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.05.06 {
        array set save {-activeborderwidth 1 -borderwidth 1 -font 1 -tearoff 1}
    }

}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -borderwidth 1 -height 25 -relief sunken -width 225 
    vTcl:DefineAlias "$target" "Frame1" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $target
    menubutton $site_3_0.01  -anchor w -menu "$site_3_0.01.02" -padx 4 -pady 3 -text File -width 4 
    vTcl:DefineAlias "$site_3_0.01" "Menubutton1" vTcl:WidgetProc "Toplevel1" 1
    menu $site_3_0.01.02  -activeborderwidth 1 -borderwidth 1 -font {Tahoma 8} -tearoff 0 
    vTcl:DefineAlias "$site_3_0.01.02" "Menu1" vTcl:WidgetProc "" 1
    $site_3_0.01.02 add command  -accelerator Ctrl+O -label Open 
    $site_3_0.01.02 add command  -accelerator Ctrl+W -label Close 
    menubutton $site_3_0.03  -anchor w -menu "$site_3_0.03.04" -padx 4 -pady 3 -text Edit -width 4 
    vTcl:DefineAlias "$site_3_0.03" "Menubutton2" vTcl:WidgetProc "Toplevel1" 1
    menu $site_3_0.03.04  -activeborderwidth 1 -borderwidth 1 -font {Tahoma 8} -tearoff 0 
    vTcl:DefineAlias "$site_3_0.03.04" "Menu1" vTcl:WidgetProc "" 1
    $site_3_0.03.04 add command  -accelerator Ctrl+X -label Cut 
    $site_3_0.03.04 add command  -accelerator Ctrl+C -label Copy 
    $site_3_0.03.04 add command  -accelerator Ctrl+V -label Paste 
    $site_3_0.03.04 add command  -accelerator Del -label Delete 
    menubutton $site_3_0.05  -anchor w -menu "$site_3_0.05.06" -padx 4 -pady 3 -text Help -width 4 
    vTcl:DefineAlias "$site_3_0.05" "Menubutton3" vTcl:WidgetProc "Toplevel1" 1
    menu $site_3_0.05.06  -activeborderwidth 1 -borderwidth 1 -font {Tahoma 8} -tearoff 0 
    vTcl:DefineAlias "$site_3_0.05.06" "Menu1" vTcl:WidgetProc "" 1
    $site_3_0.05.06 add command  -label About 
    pack $site_3_0.01  -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.03  -in $site_3_0 -anchor center -expand 0 -fill none -side left 
    pack $site_3_0.05  -in $site_3_0 -anchor center -expand 0 -fill none -side right 

}


proc procsCmd {} {}

}

namespace eval {vTcl::compounds::system::{Scrollable Canvas}} {

set bindtags {}

set source .top80.cpd82

set class Frame

set procs {}


proc vTcl:DefineAlias {target alias args} {
    set class [vTcl:get_class $target]
    vTcl:set_alias $target [vTcl:next_widget_name $class $target $alias] -noupdate
}


proc infoCmd {target} {
    namespace eval ::widgets::$target {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $target
    namespace eval ::widgets::$site_3_0.01 {
        array set save {-command 1 -orient 1}
    }
    namespace eval ::widgets::$site_3_0.02 {
        array set save {-command 1}
    }
    namespace eval ::widgets::$site_3_0.03 {
        array set save {-borderwidth 1 -closeenough 1 -height 1 -highlightthickness 1 -relief 1 -width 1 -xscrollcommand 1 -yscrollcommand 1}
    }

}


proc bindtagsCmd {} {}


proc compoundCmd {target} {
    set items [split $target .]
    set parent [join [lrange $items 0 end-1] .]
    set top [winfo toplevel $parent]
    frame $target  -borderwidth 1 -height 182 -width 222 
    vTcl:DefineAlias "$target" "Frame2" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $target
    scrollbar $site_3_0.01  -command "$site_3_0.03 xview" -orient horizontal 
    vTcl:DefineAlias "$site_3_0.01" "Scrollbar1" vTcl:WidgetProc "Toplevel1" 1
    scrollbar $site_3_0.02  -command "$site_3_0.03 yview" 
    vTcl:DefineAlias "$site_3_0.02" "Scrollbar2" vTcl:WidgetProc "Toplevel1" 1
    canvas $site_3_0.03  -borderwidth 2 -closeenough 1.0 -height 100 -highlightthickness 1  -relief sunken -width 100 -xscrollcommand "$site_3_0.01 set"  -yscrollcommand "$site_3_0.02 set" 
    vTcl:DefineAlias "$site_3_0.03" "Canvas1" vTcl:WidgetProc "Toplevel1" 1
    grid $site_3_0.01  -in $site_3_0 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew 
    grid $site_3_0.02  -in $site_3_0 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns 
    grid $site_3_0.03  -in $site_3_0 -column 0 -row 0 -columnspan 1 -rowspan 1 -sticky nesw 

}


proc procsCmd {} {}

}



