##############################################################################
#
# attrbar.tcl - attribute icon bar under menus
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

proc vTcl:fill_font_menu {menu} {
    global vTcl
    set fams [font families]
    foreach i $fams {
        $menu add radiobutton -label $i -variable vTcl(w,font) \
        -value $i -command "vTcl:set_font base \$vTcl(w,widget) \{$i\}"
    }
}

proc vTcl:fill_fontsize_menu {menu} {
    global vTcl
    foreach i {8 9 10 11 12 14 18 24 36 48 72} {
        $menu add radiobutton -label $i -variable vTcl(w,font) \
        -value $i -command "vTcl:set_font size \$vTcl(w,widget) $i"
    }
    $menu add separator
    $menu add command -label other
}

proc vTcl:set_justify {widget option} {
    catch {
        $widget conf -justify $option
    }
}

proc vTcl:set_font {which widget option} {
    global vTcl
    if {[catch {set was [$widget cget -font]}]} {return}
    set base [lindex $was 0]
    set size [lindex $was 1]
    set style [lindex $was 2]
    switch $which {
        base {
            $widget conf -font [list $option $size $style]
        }
        size {
            $widget conf -font [list $base $option $style]
        }
        style {
            set style ""
            foreach i {bold italic underline} {
                if {$vTcl(w,fontstyle,$i)} {
                    lappend style $i
                }
            }
            $widget conf -font [list $base $size $style]
        }
    }
}

proc vTcl:widget_set_relief {relief} {
    global vTcl
    if {$vTcl(w,widget) == ""} {return}
    if {[catch {$vTcl(w,widget) cget -relief}]} {return}
    $vTcl(w,widget) conf -relief $relief
}

proc vTcl:widget_set_border {border} {
    global vTcl
    if {$vTcl(w,widget) == ""} {return}
    if {[catch {$vTcl(w,widget) cget -bd}]} {return}
    $vTcl(w,widget) conf -bd $border
}

proc vTcl:widget_set_anchor {anchor} {
    global vTcl
    if {$vTcl(w,widget) == ""} {return}
    if {[catch {$vTcl(w,widget) cget -anchor}]} {return}
    $vTcl(w,widget) conf -anchor $anchor
}

proc vTcl:widget_set_fg {target} {
    global vTcl
    if {$vTcl(w,widget) == ""} {return}
    if {[catch {set fg [$vTcl(w,widget) cget -foreground]}]} {return}
    set vTcl(w,opt,-foreground) $fg
    vTcl:show_color $target -foreground vTcl(w,opt,-foreground)
}

proc vTcl:widget_set_bg {target} {
    global vTcl
    if {$vTcl(w,widget) == ""} {return}
    if {[catch {set bg [$vTcl(w,widget) cget -background]}]} {return}
    set vTcl(w,opt,-background) $bg
    vTcl:show_color $target -background vTcl(w,opt,-background)
}

proc vTcl:set_manager {mgr} {
    global vTcl
    foreach i $vTcl(w,mgrs) {
        if { $i == $mgr } { 
            $vTcl(mgrs,$i,widget) configure -relief sunken
        } else {
            $vTcl(mgrs,$i,widget) configure -relief raised
        }
    }
    set vTcl(w,def_mgr) $mgr
}

proc vTcl:attrbar_color {target} {
    set dbg [lindex [. conf -bg] 3]
    if {[catch {set fg [$target cget -fg]}] == 1} {
        set fg $dbg
    } else {
        set fg [$target cget -fg]
    }
    if {[catch {set bg [$target cget -bg]}] == 1} {
        set fg $dbg
    } else {
        set bg [$target cget -bg]
    }
    catch {
        .vTcl.attr.010.lab41 conf -bg $fg
        .vTcl.attr.010.lab42 conf -bg $bg
    }
}

proc vTcl:attrbar:toggle_console {} {
	
    global vTcl
    
    if {$vTcl(attrbar,console_state) == 1} {
    	
    	set vTcl(attrbar,console_state) 0
    	vTcl:show_console hide
    	.vTcl.attr.console.console_toggle configure -relief raised

    } else {
    
        if {$vTcl(attrbar,console_state) == 0} {
    	
            set vTcl(attrbar,console_state) 1
    	    vTcl:show_console show
    	    .vTcl.attr.console.console_toggle configure -relief sunken
    	}
    }
}

proc vTcl:attrbar {args} {
    global vTcl tk_version
    
    set vTcl(attrbar,console_state) [info exists vTcl(geometry,.vTcl.con)]
    
    set base .vTcl
    frame .vTcl.attr \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    pack .vTcl.attr \
        -expand 1 -fill x -side top 
    frame .vTcl.attr.01 \
        -borderwidth 1 -height 20 -relief raised -width 20 
    pack .vTcl.attr.01 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 3 -pady 2 \
        -side left 
    entry .vTcl.attr.01.02 \
        -highlightthickness 0 -width 15 -textvariable vTcl(w,opt,-text)
    bind .vTcl.attr.01.02 <Return> {
        .vTcl.attr.01.02 insert end "\n"
        vTcl:update_label $vTcl(w,widget)
    }
    bind .vTcl.attr.01.02 <KeyRelease> {
        vTcl:update_label $vTcl(w,widget)
    }
    vTcl:set_balloon .vTcl.attr.01.02 "text"
    pack .vTcl.attr.01.02 \
        -anchor center -expand 1 -fill both -padx 2 -pady 2 -side left
    button .vTcl.attr.01.03 \
        -highlightthickness 0 -bd 1 -padx 4 -pady 1 -image ellipses -command {
            vTcl:set_command $vTcl(w,widget)
        }
    vTcl:set_balloon .vTcl.attr.01.03 "command"
    pack .vTcl.attr.01.03 \
        -anchor center -padx 2 -pady 2 -side left

    frame .vTcl.attr.console -borderwidth 1 -relief raised
    button .vTcl.attr.console.console_toggle -image tconsole -highlightthickness 0 \
        -command vTcl:attrbar:toggle_console
    if {$vTcl(attrbar,console_state)} {
    	.vTcl.attr.console.console_toggle configure -relief sunken }
    vTcl:set_balloon .vTcl.attr.console.console_toggle "show/hide console"
    pack .vTcl.attr.console -side left -padx 5
    pack .vTcl.attr.console.console_toggle -side left -padx 2 -pady 1
    
    frame .vTcl.attr.04 \
        -borderwidth 1 -height 20 -relief raised -width 20 
    pack .vTcl.attr.04 \
        -anchor center -expand 0 -fill none -padx 3 -pady 2 -side left
    menubutton .vTcl.attr.04.relief -bd 1 -relief raised -image relief \
        -highlightthickness 0 -menu .vTcl.attr.04.relief.m
    menu .vTcl.attr.04.relief.m -tearoff 0
    .vTcl.attr.04.relief.m add radiobutton -image rel_raised -command {
        vTcl:widget_set_relief raised
    } -variable vTcl(w,opt,-relief) -value raised
    .vTcl.attr.04.relief.m add radiobutton -image rel_sunken -command {
        vTcl:widget_set_relief sunken
    } -variable vTcl(w,opt,-relief) -value sunken
    .vTcl.attr.04.relief.m add radiobutton -image rel_groove -command {
        vTcl:widget_set_relief groove
    } -variable vTcl(w,opt,-relief) -value groove
    .vTcl.attr.04.relief.m add radiobutton -image rel_ridge -command {
        vTcl:widget_set_relief ridge
    } -variable vTcl(w,opt,-relief) -value ridge
    .vTcl.attr.04.relief.m add separator
    .vTcl.attr.04.relief.m add radiobutton -label "none" -command {
        vTcl:widget_set_relief flat
    } -variable vTcl(w,opt,-relief) -value flat
    vTcl:set_balloon .vTcl.attr.04.relief "border"
    menubutton .vTcl.attr.04.border -bd 1 -relief raised -image border \
        -highlightthickness 0 -menu .vTcl.attr.04.border.m
    menu .vTcl.attr.04.border.m -tearoff 0
    .vTcl.attr.04.border.m add radiobutton -label 1 -command {
        vTcl:widget_set_border 1
    } -variable vTcl(w,opt,-borderwidth) -value 1
    .vTcl.attr.04.border.m add radiobutton -label 2 -command {
        vTcl:widget_set_border 2
    } -variable vTcl(w,opt,-borderwidth) -value 2
    .vTcl.attr.04.border.m add radiobutton -label 3 -command {
        vTcl:widget_set_border 3
    } -variable vTcl(w,opt,-borderwidth) -value 3
    .vTcl.attr.04.border.m add radiobutton -label 4 -command {
        vTcl:widget_set_border 4
    } -variable vTcl(w,opt,-borderwidth) -value 4
    .vTcl.attr.04.border.m add separator
    .vTcl.attr.04.border.m add radiobutton -label none -command {
        vTcl:widget_set_border 0
    } -variable vTcl(w,opt,-borderwidth) -value 0
    vTcl:set_balloon .vTcl.attr.04.border "border width"
    menubutton .vTcl.attr.04.anchor -bd 1 -relief raised -image anchor \
        -highlightthickness 0 -menu .vTcl.attr.04.anchor.m
    menu .vTcl.attr.04.anchor.m -tearoff 0
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_c -command {
        vTcl:widget_set_anchor center
    } -variable vTcl(w,opt,-anchor) -value center
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_n -command {
        vTcl:widget_set_anchor n
    } -variable vTcl(w,opt,-anchor) -value n
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_s -command {
        vTcl:widget_set_anchor s
    } -variable vTcl(w,opt,-anchor) -value s
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_e -command {
        vTcl:widget_set_anchor e
    } -variable vTcl(w,opt,-anchor) -value e
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_w -command {
        vTcl:widget_set_anchor w
    } -variable vTcl(w,opt,-anchor) -value w
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_nw -command {
        vTcl:widget_set_anchor nw
    } -variable vTcl(w,opt,-anchor) -value nw
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_ne -command {
        vTcl:widget_set_anchor ne
    } -variable vTcl(w,opt,-anchor) -value ne
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_sw -command {
        vTcl:widget_set_anchor sw
    } -variable vTcl(w,opt,-anchor) -value sw
    .vTcl.attr.04.anchor.m add radiobutton -image anchor_se -command {
        vTcl:widget_set_anchor se
    } -variable vTcl(w,opt,-anchor) -value se
    vTcl:set_balloon .vTcl.attr.04.anchor "label anchor"
    pack .vTcl.attr.04.relief -side left -padx 2 -pady 2
    pack .vTcl.attr.04.border -side left -padx 2 -pady 2
    pack .vTcl.attr.04.anchor -side left -padx 2 -pady 2

    frame .vTcl.attr.010 \
        -borderwidth 1 -height 20 -relief raised -width 20 
    pack .vTcl.attr.010 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 3 -pady 2 \
        -side left 
    button .vTcl.attr.010.lab41 \
        -bd 1 -image fg -pady 3 -padx 2 -highlightthickness 0 -command {
            vTcl:widget_set_fg .vTcl.attr.010.lab41
        }
    vTcl:set_balloon .vTcl.attr.010.lab41 "foreground"
    pack .vTcl.attr.010.lab41 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left 
    button .vTcl.attr.010.lab42 \
        -bd 1 -pady 3 -image bg -padx 2 -highlightthickness 0 -command {
            vTcl:widget_set_bg .vTcl.attr.010.lab42
        }
    vTcl:set_balloon .vTcl.attr.010.lab42 "background"
    pack .vTcl.attr.010.lab42 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left 

    # Font Browsing in tk8.0 or later
    #
    if {$tk_version >= 8} {

    frame .vTcl.attr.011 \
        -borderwidth 1 -height 20 -relief raised -width 20 
    pack .vTcl.attr.011 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 3 -pady 2 \
        -side left 
    menubutton .vTcl.attr.011.lab41 \
        -bd 1 -relief raised -image fontbase -pady 3 -padx 2 \
        -highlightthickness 0 -menu .vTcl.attr.011.lab41.m
    menu .vTcl.attr.011.lab41.m -tearoff 0
    vTcl:fill_font_menu .vTcl.attr.011.lab41.m
    vTcl:set_balloon .vTcl.attr.011.lab41 "font"
    menubutton .vTcl.attr.011.lab42 \
        -bd 1 -relief raised -image fontsize -pady 3 -padx 2 \
        -highlightthickness 0 -menu .vTcl.attr.011.lab42.m
    menu .vTcl.attr.011.lab42.m -tearoff 0
    vTcl:fill_fontsize_menu .vTcl.attr.011.lab42.m
    vTcl:set_balloon .vTcl.attr.011.lab42 "font size"
    menubutton .vTcl.attr.011.lab43 \
        -bd 1 -relief raised -image fontstyle -pady 3 -padx 2 \
        -highlightthickness 0 -menu .vTcl.attr.011.lab43.m
    menu .vTcl.attr.011.lab43.m -tearoff 0
    .vTcl.attr.011.lab43.m add check -variable vTcl(w,fontstyle,bold) \
        -label bold -command "vTcl:set_font style \$vTcl(w,widget) bold"
    .vTcl.attr.011.lab43.m add check -variable vTcl(w,fontstyle,italic) \
        -label italic -command "vTcl:set_font style \$vTcl(w,widget) italic"
    .vTcl.attr.011.lab43.m add check -variable vTcl(w,fontstyle,underline) \
        -label underline -comm "vTcl:set_font style \$vTcl(w,widget) underline"
    vTcl:set_balloon .vTcl.attr.011.lab43 "font style"
    menubutton .vTcl.attr.011.lab44 \
        -bd 1 -relief raised -image justify -pady 3 -padx 2 \
        -highlightthickness 0 -menu .vTcl.attr.011.lab44.m
    menu .vTcl.attr.011.lab44.m -tearoff 0
    .vTcl.attr.011.lab44.m add radiobutton -variable vTcl(w,opt,-justify) \
        -label left -command "vTcl:set_justify \$vTcl(w,widget) left"
    .vTcl.attr.011.lab44.m add radiobutton -variable vTcl(w,opt,-justify) \
        -label center -command "vTcl:set_justify \$vTcl(w,widget) center"
    .vTcl.attr.011.lab44.m add radiobutton -variable vTcl(w,opt,-justify) \
        -label right -command "vTcl:set_justify \$vTcl(w,widget) right"
    vTcl:set_balloon .vTcl.attr.011.lab44 "justification"
    pack .vTcl.attr.011.lab41 .vTcl.attr.011.lab42 .vTcl.attr.011.lab43 \
        .vTcl.attr.011.lab44 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left 

    }

    frame .vTcl.attr.016 \
        -borderwidth 1 -height 20 -relief raised -width 20 
    pack .vTcl.attr.016 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 3 -pady 2 \
        -side left 
    set vTcl(mgrs,grid,widget) .vTcl.attr.016.017
    button .vTcl.attr.016.017 \
        -command {vTcl:set_manager grid} \
        -highlightthickness 0 -image mgr_grid -padx 0 -pady 0 
    vTcl:set_balloon .vTcl.attr.016.017 "use grid manager"
    pack .vTcl.attr.016.017 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left 
    set vTcl(mgrs,pack,widget) .vTcl.attr.016.018
    button .vTcl.attr.016.018 \
        -command {vTcl:set_manager pack} \
        -highlightthickness 0 -image mgr_pack -padx 0 -pady 0 
    vTcl:set_balloon .vTcl.attr.016.018 "use packer manager"
    pack .vTcl.attr.016.018 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left 
    set vTcl(mgrs,place,widget) .vTcl.attr.016.019
    button .vTcl.attr.016.019 \
        -command {vTcl:set_manager place} \
        -highlightthickness 0 -image mgr_place -padx 0 -pady 0 
    vTcl:set_balloon .vTcl.attr.016.019 "use place manager"
    pack .vTcl.attr.016.019 \
        -anchor center -expand 0 -fill none -ipadx 0 -ipady 0 -padx 2 -pady 2 \
        -side left 
    set vTcl(mgrs,wm,widget) .vTcl.attr.016.020
    button .vTcl.attr.016.020
}


