##############################################################################
#
# propmgr.tcl - procedures used by the widget properites manager
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

set vTcl(w,last_widget_in) ""
set vTcl(w,last_value) ""

proc vTcl:show_propmgr {} {
    vTclWindow.vTcl.ae
}

proc vTcl:grid:height {parent {col 0}} {
    update idletasks
    set h 0
    set s [grid slaves $parent -column $col]
    foreach i $s {
        incr h [winfo height $i]
    }
    return $h
}

proc vTcl:grid:width {parent {row 0}} {
    update idletasks
    set w 0
    set s [grid slaves $parent -row $row]
    foreach i $s {
        incr w [winfo width $i]
    }
    return $w
}

proc vTcl:prop:set_visible {which {on ""}} {
    global vTcl
    set var ${which}_on
    switch $which {
        info {
            set f $vTcl(gui,ae).c.f1
            set name "Widget"
        }
        attr {
            set f $vTcl(gui,ae).c.f2
            set name "Attributes"
        }
        geom {
            set f $vTcl(gui,ae).c.f3
            set name "Geometry"
        }
        default {
            return
        }
    }
    if {$on == ""} {
        set on [expr - $vTcl(pr,$var)]
    }
    if {$on == 1} {
        pack $f.f -side top -expand 1 -fill both
        $f.l conf -text "$name (-)"
        set vTcl(pr,$var) 1
    } else {
        pack forget $f.f
        $f.l conf -text "$name (+)"
        set vTcl(pr,$var) -1
    }
    update idletasks
    vTcl:prop:recalc_canvas
}

proc vTclWindow.vTcl.ae {args} {
    global vTcl tcl_platform

    set ae $vTcl(gui,ae)
    if {[winfo exists $ae]} {wm deiconify $ae; return}
    toplevel $ae -class vTcl
    wm withdraw $ae
    wm transient $ae .vTcl
    wm title $ae "Attribute Editor"
    wm geometry $ae 206x325
    wm resizable $ae 1 1
    wm transient $vTcl(gui,ae) .vTcl
    wm overrideredirect $ae 0

    canvas $ae.c -highlightthickness 0 \
	-xscrollcommand "$ae.sh set" \
	-yscrollcommand "$ae.sv set" \
	-yscrollincrement 20
    scrollbar $ae.sh -orient horiz -command "$ae.c xview" -takefocus 0
    scrollbar $ae.sv -orient vert  -command "$ae.c yview" -takefocus 0

    grid $ae.c  -column 0 -row 0 -sticky news
    grid $ae.sh -column 0 -row 1 -sticky ew
    grid $ae.sv -column 1 -row 0 -sticky ns

    grid columnconf $ae 0 -weight 1
    grid rowconf    $ae 0 -weight 1

    set f1 $ae.c.f1; frame $f1       ; # Widget Info
        $ae.c create window 0 0 -window $f1 -anchor nw -tag info
    set f2 $ae.c.f2; frame $f2       ; # Widget Attributes
        $ae.c create window 0 0 -window $f2 -anchor nw -tag attr
    set f3 $ae.c.f3; frame $f3       ; # Widget Geometry
        $ae.c create window 0 0 -window $f3 -anchor nw -tag geom

    label $f1.l -text "Widget"     -relief raised -bg #aaaaaa -bd 1 -width 30 \
    	-anchor center
        pack $f1.l -side top -fill x
    label $f2.l -text "Attributes" -relief raised -bg #aaaaaa -bd 1 -width 30 \
    	-anchor center
        pack $f2.l -side top -fill x
    label $f3.l -text "Geometry"   -relief raised -bg #aaaaaa -bd 1 -width 30 \
    	-anchor center
        pack $f3.l -side top -fill x

    bind $f1.l <ButtonPress> {vTcl:prop:set_visible info}
    bind $f2.l <ButtonPress> {vTcl:prop:set_visible attr}
    bind $f3.l <ButtonPress> {vTcl:prop:set_visible geom}

    set w $f1.f
    frame $w; pack $w -side top -expand 1 -fill both

    label $w.ln -text "Widget" -width 11 -anchor w
        vTcl:entry $w.en -width 12 -textvariable vTcl(w,widget) \
        -relief sunken -bd 1 -state disabled
    label $w.lc -text "Class"  -width 11 -anchor w
        vTcl:entry $w.ec -width 12 -textvariable vTcl(w,class) \
        -relief sunken -bd 1 -state disabled
    label $w.lm -text "Manager" -width 11 -anchor w
        vTcl:entry $w.em -width 12 -textvariable vTcl(w,manager) \
        -relief sunken -bd 1 -state disabled
    label $w.la -text "Alias"  -width 11 -anchor w
        vTcl:entry $w.ea -width 12 -textvariable vTcl(w,alias) \
        -relief sunken -bd 1 -state disabled
    label $w.li -text "Insert Point" -width 11 -anchor w
        vTcl:entry $w.ei -width 12 -textvariable vTcl(w,insert) \
        -relief sunken -bd 1 -state disabled

    grid columnconf $w 1 -weight 1

    grid $w.ln $w.en -padx 0 -pady 1 -sticky news
    grid $w.lc $w.ec -padx 0 -pady 1 -sticky news
    grid $w.lm $w.em -padx 0 -pady 1 -sticky news
    grid $w.la $w.ea -padx 0 -pady 1 -sticky news
    grid $w.li $w.ei -padx 0 -pady 1 -sticky news

    set w $f2.f
    frame $w; pack $w -side top -expand 1 -fill both

    set w $f3.f
    frame $w; pack $w -side top -expand 1 -fill both

    vTcl:prop:set_visible info $vTcl(pr,info_on)
    vTcl:prop:set_visible attr $vTcl(pr,attr_on)
    vTcl:prop:set_visible geom $vTcl(pr,geom_on)

    if { $vTcl(w,widget) != "" } {
        vTcl:prop:update_attr
    }
    vTcl:setup_vTcl:bind $vTcl(gui,ae)
    if {$tcl_platform(platform) == "macintosh"} {
        set w [expr [winfo vrootwidth .] - 206]
        wm geometry $vTcl(gui,ae) 200x300+$w+20
    }
    catch {wm geometry .vTcl.ae $vTcl(geometry,.vTcl.ae)}
    update idletasks
    vTcl:prop:recalc_canvas

    vTcl:BindHelp $ae PropManager

    wm deiconify $ae
}

proc vTcl:prop:recalc_canvas {} {
    global vTcl

    set ae $vTcl(gui,ae)
    if {![winfo exists $ae]} { return }

    set f1 $ae.c.f1                              ; # Widget Info Frame
    set f2 $ae.c.f2                              ; # Widget Attribute Frame
    set f3 $ae.c.f3                              ; # Widget Geometry Frame

    $ae.c coords attr 0 [winfo height $f1]
    $ae.c coords geom 0 [expr [winfo height $f1] + [winfo height $f2]]

    set w [vTcl:util:greatest_of "[winfo width $f1] \
                                  [winfo width $f2] \
                                  [winfo width $f3]" ]
    set h [expr [winfo height $f1] + \
                [winfo height $f2] + \
                [winfo height $f3] ]
    $ae.c configure -scrollregion "0 0 $w $h"
    wm minsize .vTcl.ae $w 200

    set vTcl(propmgr,frame,$f1) 0
    lassign [vTcl:split_geom [winfo geometry $f1]] w h
    set vTcl(propmgr,frame,$f2) $h
    lassign [vTcl:split_geom [winfo geometry $f2]] w h2
    set vTcl(propmgr,frame,$f3) [expr $h + $h2]
}

proc vTcl:focus_out_cmd {option} {
    global vTcl
    if {$vTcl(mode) == "TEST"} return

    if {$vTcl(w,last_widget_in) != "" && $vTcl(w,last_value) != ""} {
	set w $vTcl(w,last_widget_in)
	set val $vTcl(w,last_value)

	set vTcl(w,last_widget_in) ""
	set vTcl(w,last_value)     ""

	$w configure $option $val
	vTcl:prop:save_opt $w $option ::widgets::${w}::options($option)
	vTcl:place_handles $vTcl(w,widget)
    } else {
	vTcl:log "oops:$vTcl(w,widget),$vTcl(w,last_widget_in)!"
    }
}

proc vTcl:focus_out_geometry_cmd {option cmd {cmd2 ""}} {
    global vTcl

    if {$vTcl(mode) == "TEST"} return

    if {$vTcl(w,last_widget_in) != "" && \
	$vTcl(w,last_value)     != ""} {

	set back_last_widget_in $vTcl(w,last_widget_in)
	set back_last_value $vTcl(w,last_value)

	set vTcl(w,last_widget_in) ""
	set vTcl(w,last_value)     ""

	if {$cmd2==""} {
	    $cmd $back_last_widget_in $option $back_last_value
	} else {
	    $cmd $cmd2 $back_last_widget_in $option $back_last_value
	}
     } else {
	vTcl:log "oops2:$vTcl(w,widget),$vTcl(w,last_widget_in)!"
     }
}

proc vTcl:prop:update_attr {} {
    global vTcl options specialOpts
    if {$vTcl(var_update) == "no"} {
        return
    }

    if {[vTcl:streq $vTcl(w,widget) "."]} {
    	vTcl:prop:clear
	return
    }

    vTcl:log "vTcl:prop:update_attr"
    #
    # Update Widget Attributes
    #
    set fr $vTcl(gui,ae).c.f2.f
    set top $fr._$vTcl(w,class)
    update idletasks
    if {[winfo exists $top]} {
        if {$vTcl(w,class) != $vTcl(w,last_class)} {
            catch {pack forget $fr._$vTcl(w,last_class)}
	    update
            pack $top -side left -fill both -expand 1
        }
        foreach i $vTcl(options) {
	    set type $options($i,type)
	    if {[info exists specialOpts($vTcl(w,class),$i,type)]} {
	    	set type $specialOpts($vTcl(w,class),$i,type)
	    }
	    if {$type == "synonym"} { continue }
            if {[lsearch $vTcl(w,optlist) $i] >= 0} {
		if {$type == "color"} {
                    $top.t${i}.f configure -bg $vTcl(w,opt,$i)
                }
            }
        }
    } elseif [winfo exists $fr] {
        catch {pack forget $fr._$vTcl(w,last_class)}
        frame $top
        pack $top -side top -expand 1 -fill both
        grid columnconf $top 1 -weight 1
        set type ""
        foreach i $vTcl(options) {
	    if {$options($i,type) == "synonym"} { continue }
	    set newtype $options($i,title)
            if {$type != $newtype} {
                set type $newtype
            }
            if {[lsearch $vTcl(w,optlist) $i] < 0} { continue }
	    set variable "vTcl(w,opt,$i)"
	    set config_cmd "\$vTcl(w,widget) configure $i \$$variable; "
	    set focus_out_cmd "vTcl:focus_out_cmd $i"

	    append config_cmd "vTcl:place_handles \$vTcl(w,widget)"
	    vTcl:prop:new_attr $top $i $variable $config_cmd opt $focus_out_cmd
        }

	# special stuff to edit menu items (cascaded items)
	if {$vTcl(w,class) == "Menu"} {
        global dummy
        set dummy ""
	    vTcl:prop:new_attr $top -menuspecial dummy "" opt ""
	}
    }

    if {$vTcl(w,manager) == ""} {
        update idletasks
        vTcl:prop:recalc_canvas
        return
    }

    #
    # Update Widget Geometry
    #
    set fr $vTcl(gui,ae).c.f3.f
    set top $fr._$vTcl(w,manager)
    set mgr $vTcl(w,manager)
    update idletasks
    if {[winfo exists $top]} {
    	vTcl:log "here!"
        if {$vTcl(w,manager) != $vTcl(w,last_manager)} {
            catch {pack forget $fr._$vTcl(w,last_manager)}
            pack $top -side left -fill both -expand 1
        }
    } elseif [winfo exists $fr] {
        catch {pack forget $fr._$vTcl(w,last_manager)}
        frame $top
        pack $top -side top -expand 1 -fill both
        grid columnconf $top 1 -weight 1

	catch {
	    foreach i "$vTcl(m,$mgr,list) $vTcl(m,$mgr,extlist)" {
		set variable "vTcl(w,$mgr,$i)"
		set cmd [lindex $vTcl(m,$mgr,$i) 4]
		set config_cmd "$cmd \$vTcl(w,widget) $i \$$variable"
		set focus_out_cmd "vTcl:focus_out_geometry_cmd $i $cmd"

		if {$cmd == ""} {
		    set config_cmd "$mgr conf \$vTcl(w,widget) $i \$$variable"
		    set focus_out_cmd "vTcl:focus_out_geometry_cmd $i $mgr conf"
		}
		append config_cmd ";vTcl:place_handles \$vTcl(w,widget)"
		vTcl:prop:new_attr $top $i $variable $config_cmd m,$mgr \
		    $focus_out_cmd -geomOpt
	    }
	}
    }

    update idletasks
    vTcl:prop:recalc_canvas
    vTcl:prop:update_saves $vTcl(w,widget)
}

proc vTcl:prop:new_attr {top option variable config_cmd prefix focus_out_cmd
			{isGeomOpt ""}} {
    global vTcl $variable options specialOpts propmgrLabels

    set base $top.t${option}

    # Hack for Tix
    if {[winfo exists $top.$option]} { return }

    if {$prefix == "opt"} {
	if {[info exists specialOpts($vTcl(w,class),$option,type)]} {
	    set text    $specialOpts($vTcl(w,class),$option,text)
	    set type    $specialOpts($vTcl(w,class),$option,type)
	    set choices $specialOpts($vTcl(w,class),$option,choices)
	} else {
	    set text    $options($option,text)
	    set type    $options($option,type)
	    set choices $options($option,choices)
	}
    } else {
    	set text    [lindex $vTcl($prefix,$option) 0]
	set type    [lindex $vTcl($prefix,$option) 2]
	set choices [lindex $vTcl($prefix,$option) 3]
    }

    if {[vTcl:streq $type "relief"]} {
	set type    choice
    	set choices $vTcl(reliefs)
    }

    set label $top.$option
    label $label -text $text -anchor w -width 11 -fg black \
    	-relief $vTcl(propmgr,relief)

    # @@change by Christian Gavin 3/10/2000
    # added font browser for individual properties

    set focusControl $base

    append config_cmd "; vTcl:prop:save_opt \$vTcl(w,widget) $option $variable"

    switch $type {
        boolean {
            frame $base
            radiobutton ${base}.y \
                -variable $variable -value 1 -text "Yes" -relief sunken -bd 1 \
                -command "$config_cmd" -selectcolor #0077ff -padx 0 -pady 1
            radiobutton ${base}.n \
                -variable $variable -value 0 -text "No" -relief sunken -bd 1 \
                -command "$config_cmd" -selectcolor #0077ff -padx 0 -pady 1
            pack ${base}.y ${base}.n -side left -expand 1 -fill both
        }
        choice {
            frame $base
            menubutton ${base}.l \
                -textvariable $variable -bd 1 -width 12 -menu ${base}.l.m \
                -highlightthickness 1 -relief sunken -anchor w -fg black \
                -padx 0 -pady 1
            menu ${base}.l.m -tearoff 0
            foreach i $choices {
                ${base}.l.m add command -label "$i" -command \
                    "set $variable $i; $config_cmd; "
            }
            button ${base}.f -relief raised -bd 1 -image file_down \
                -height 5 -command "
		    focus $base.l
		    vTcl:propmgr:select_attr $top $option
		    tkMbPost ${base}.l
		"
            pack ${base}.l -side left -expand 1 -fill x
            pack ${base}.f -side right -fill y -pady 1 -padx 1

	    bind $base.l <Button-1> "
	    	focus $base.l
		vTcl:propmgr:select_attr $top $option
	    "

	    set focusControl ${base}.l
        }
        menu {
            button $base \
                -text "<click to edit>" -relief sunken -bd 1 -width 12 \
                -highlightthickness 1 -fg black -padx 0 -pady 1 \
                -command "
		    focus $base
		    vTcl:propmgr:select_attr $top $option
                    set current \$vTcl(w,widget)
                    vTcl:edit_target_menu \$current
                    set $variable \[\$current cget -menu\]
                    vTcl:prop:save_opt \$current $option $variable
                " -anchor w
        }
	menuspecial {
            button $base \
                -text "<click to edit>" -relief sunken -bd 1 -width 12 \
                -highlightthickness 1 -fg black -padx 0 -pady 1 \
                -command "
		    vTcl:propmgr:select_attr $top $option
                    set current \$vTcl(w,widget)
                    vTcl:edit_menu \$current
                    vTcl:prop:save_opt \$current $option $variable
                " -anchor w
	}
        color {
            frame $base
            vTcl:entry ${base}.l -relief sunken -bd 1 \
                -textvariable $variable -width 8 \
                -highlightthickness 1 -fg black -bg white
            bind ${base}.l <KeyRelease-Return> \
                "$config_cmd; ${base}.f conf -bg \$$variable"
            frame ${base}.f -relief raised -bd 1 \
                -bg [subst $$variable] -width 20 -height 5
            bind ${base}.f <ButtonPress> \
                "
		vTcl:propmgr:select_attr $top $option
		vTcl:show_color $top.t${option}.f $option $variable
		vTcl:prop:save_opt \$vTcl(w,widget) $option $variable
		"
            pack ${base}.l -side left -expand 1 -fill x
            pack ${base}.f -side right -fill y -pady 1 -padx 1
	    set focusControl ${base}.l
        }
        command {
            frame $base
            vTcl:entry ${base}.l -relief sunken -bd 1 \
                -textvariable $variable -width 8 \
                -highlightthickness 1 -fg black -bg white

	    if {[info tclversion] > 8.2} {
		${base}.l configure -validate key \
		-vcmd "
		    vTcl:prop:save_opt \$vTcl(w,widget) $option $variable
		    return 1
		"
	    }

            button ${base}.f \
                -image ellipses -bd 1 -width 12 \
                -highlightthickness 1 -fg black -padx 0 -pady 1 \
                -command "
		    vTcl:propmgr:select_attr $top $option
		    vTcl:set_command \$vTcl(w,widget) $option $variable
		"
            pack ${base}.l -side left -expand 1 -fill x
            pack ${base}.f -side right -fill y -pady 1 -padx 1
	    set focusControl ${base}.l
        }
        font {
            frame $base
            vTcl:entry ${base}.l -relief sunken -bd 1 \
                -textvariable $variable -width 8 \
                -highlightthickness 1 -fg black -bg white
            button ${base}.f \
                -image ellipses -bd 1 -width 12 \
                -highlightthickness 1 -fg black -padx 0 -pady 1 \
                -command "
		vTcl:propmgr:select_attr $top $option
		vTcl:font:prompt_user_font \$vTcl(w,widget) $option
		vTcl:prop:save_opt \$vTcl(w,widget) $option $variable
		"
            pack ${base}.l -side left -expand 1 -fill x
            pack ${base}.f -side right -fill y -pady 1 -padx 1
	    set focusControl ${base}.l
        }
        image {
            frame $base
            vTcl:entry ${base}.l -relief sunken -bd 1 \
                -textvariable $variable -width 8 \
                -highlightthickness 1 -fg black -bg white
            button ${base}.f \
                -image ellipses -bd 1 -width 12 \
                -highlightthickness 1 -fg black -padx 0 -pady 1 \
                -command "
		vTcl:propmgr:select_attr $top $option
		vTcl:prompt_user_image \$vTcl(w,widget) $option
		vTcl:prop:save_opt \$vTcl(w,widget) $option $variable
		"
            pack ${base}.l -side left -expand 1 -fill x
            pack ${base}.f -side right -fill y -pady 1 -padx 1
	    set focusControl ${base}.l
        }
        default {
            vTcl:entry $base \
                -textvariable $variable -relief sunken -bd 1 -width 12 \
                -highlightthickness 1 -bg white -fg black

	    if {[info tclversion] > 8.2} {
		${base} configure -validate key \
		-vcmd "
		    vTcl:prop:save_opt \$vTcl(w,widget) $option $variable
		    return 1
		"
	    }
        }
    }
    # @@end_change

    ## Append the label to the list for this widget and add the focusControl
    ## to the lookup table.  This is used when scrolling through the property
    ## manager with the directional keys.  We don't want to append geometry
    ## options, we just handle them later.
    set c [vTcl:get_class $vTcl(w,widget)]
    if {[lempty $isGeomOpt]} {
	lappend vTcl(propmgr,labels,$c) $label
    } else {
	lappend vTcl(propmgr,labels,$vTcl(w,manager)) $label
    }
    set propmgrLabels($label) $focusControl

    ## If they click the label, select the focus control.
    bind $label <Button-1> "focus $focusControl"
    bind $label <Enter> "
	if {\[vTcl:streq \[$label cget -relief] $vTcl(propmgr,relief)]} {
	    $label configure -relief raised
	}
    "
    bind $label <Leave> "
	if {\[vTcl:streq \[$label cget -relief] raised]} {
	    $label configure -relief $vTcl(propmgr,relief)
	}
    "

    ## If they right-click the label, show the context menu
    bind $label <ButtonRelease-3> \
	"vTcl:propmgr:show_rightclick_menu $vTcl(gui,ae) $option $variable %X %Y"

    set focus_in_cmd "vTcl:propmgr:select_attr $top $option"

    ## Don't change if the user presses a directional key.
    set key_release_cmd "
	if {%k < 37 || %k > 40} {
	    set vTcl(w,last_widget_in) \$vTcl(w,widget)
	    set vTcl(w,last_value) \$$variable
	}
    "

    bind $focusControl <FocusIn>    $focus_in_cmd
    bind $focusControl <FocusOut>   $focus_out_cmd
    bind $focusControl <KeyRelease> $key_release_cmd
    bind $focusControl <KeyRelease-Return> $config_cmd
    bind $focusControl <Key-Up>     "vTcl:propmgr:focusPrev $label"
    bind $focusControl <Key-Down>   "vTcl:propmgr:focusNext $label"

    if {[vTcl:streq $prefix "opt"]} {
    	set saveCheck [checkbutton ${base}_save -pady 0]
	vTcl:set_balloon $saveCheck "Check to save option"
	grid $top.$option $base $saveCheck -sticky news
    } else {
	grid $top.$option $base -sticky news
    }
}

proc vTcl:prop:clear {} {
    global vTcl

    if {![winfo exists $vTcl(gui,ae)]} return

    vTcl:propmgr:deselect_attr

    if {![winfo exists $vTcl(gui,ae).c]} {
        frame $vTcl(gui,ae).c
        pack $vTcl(gui,ae).c
    }
    foreach fr {f2 f3} {
        set fr $vTcl(gui,ae).c.$fr
        if {![winfo exists $fr]} {
            frame $fr
            pack $fr -side top -expand 1 -fill both
        }
    }

    ## Destroy and rebuild the Attributes frame
    set fr $vTcl(gui,ae).c.f2.f
    catch {destroy $fr}
    frame $fr; pack $fr -side top -expand 1 -fill both

    ## Destroy and rebuild the Geometry frame
    set fr $vTcl(gui,ae).c.f3.f
    catch {destroy $fr}
    frame $fr; pack $fr -side top -expand 1 -fill both

    set vTcl(w,widget)  {}
    set vTcl(w,insert)  {}
    set vTcl(w,class)   {}
    set vTcl(w,alias)   {}
    set vTcl(w,manager) {}

    update
    vTcl:prop:recalc_canvas
}

###
## Update all the option save checkboxes in the property manager.
###
proc vTcl:prop:update_saves {w} {
    global vTcl

    set class [vTcl:get_class $w]
    foreach opt $vTcl(w,optlist) {
    	set check .vTcl.ae.c.f2.f._$class.t${opt}_save
	if {![winfo exists $check]} { continue }
	$check configure -variable ::widgets::${w}::save($opt)
    }
}

###
## Update the checkbox for an option in the property manager.
##
## If the option becomes the default option, we uncheck the checkbox.
## This will save on space because we're not storing options we don't need to.
###
proc vTcl:prop:save_opt {w opt varName} {
    if {[vTcl:streq $w "."]} { return }

    upvar #0 $varName var
    vTcl:WidgetVar $w options
    vTcl:WidgetVar $w defaults
    vTcl:WidgetVar $w save

    if {![info exists options($opt)]} { return }
    if {[vTcl:streq $options($opt) $var]} { return }

    set options($opt) $var

    if {$options($opt) == $defaults($opt)} {
	set save($opt) 0
    } else {
	set save($opt) 1
    }
    ::vTcl::change
}

proc vTcl:propmgr:select_attr {top opt} {
    global vTcl
    vTcl:propmgr:deselect_attr
    $top.$opt configure -relief sunken
    set vTcl(propmgr,lastAttr) [list $top $opt]
    set vTcl(propmgr,opt) $opt
}

proc vTcl:propmgr:deselect_attr {} {
    global vTcl
    if {![info exists vTcl(propmgr,lastAttr)]} { return }
    [join $vTcl(propmgr,lastAttr) .] configure -relief $vTcl(propmgr,relief)
    unset vTcl(propmgr,lastAttr)
}

proc vTcl:propmgr:focusOnLabel {w dir} {
    global vTcl propmgrLabels

    set m $vTcl(w,manager)
    set c [vTcl:get_class $vTcl(w,widget)]
    set list [concat $vTcl(propmgr,labels,$c) $vTcl(propmgr,labels,$m)]

    set ind [lsearch $list $w]
    incr ind $dir

    if {$ind < 0} { return }

    set next [lindex $list $ind]

    if {[lempty $next]} { return }

    ## We want to set the focus to the focusControl, but we want the canvas
    ## to scroll to the label of the focusControl.
    focus $propmgrLabels($next)

    vTcl:propmgr:scrollToLabel $vTcl(gui,ae).c $next $dir
}

proc vTcl:propmgr:focusPrev {w} {
    vTcl:propmgr:focusOnLabel $w -1
}

proc vTcl:propmgr:focusNext {w} {
    vTcl:propmgr:focusOnLabel $w 1
}

proc vTcl:propmgr:scrollToLabel {c w units} {
    global vTcl
    set split [split $w .]
    set split [lrange $split 0 4]
    set frame [join $split .]

    lassign [$c cget -scrollregion] foo foo cx cy
    lassign [vTcl:split_geom [winfo geometry $w]] foo foo ix iy
    set yt [expr $iy.0 + $vTcl(propmgr,frame,$frame) + 20]
    lassign [$c yview] topY botY
    set topY [expr $topY * $cy]
    set botY [expr $botY * $cy]

    ## If the total new height is lower than the current view, scroll up.
    ## If the total new height is higher than the current view, scroll down.
    if {$yt < $topY || $yt > $botY} {
	$c yview scroll $units units
    }
}

proc vTcl:propmgr:show_rightclick_menu {base option variable X Y} {

    if {![winfo exists $base.menu_rightclk]} {

        menu $base.menu_rightclk -tearoff 0
        $base.menu_rightclk add cascade \
                -menu "$base.menu_rightclk.men22" -accelerator {} -command {} -font {} \
                -label {Reset to default}
        $base.menu_rightclk add separator
        $base.menu_rightclk add cascade \
                -menu "$base.menu_rightclk.men24" -accelerator {} -command {} -font {} \
                -label {Do not save option for}
        $base.menu_rightclk add cascade \
                -menu "$base.menu_rightclk.men25" -accelerator {} -command {} -font {} \
                -label {Save option for}
        $base.menu_rightclk add separator
        $base.menu_rightclk add cascade \
                -menu "$base.menu_rightclk.men26" -accelerator {} -command {} -font {} \
                -label {Apply to}
        menu $base.menu_rightclk.men24 -tearoff 0
        $base.menu_rightclk.men24 add command \
                -accelerator {} \
		-command {vTcl:prop:apply_opt $vTcl(w,widget) \
			$::vTcl::_rclick_option $::vTcl::_rclick_variable \
			subwidgets vTcl:prop:save_or_unsave_opt \
                        0} \
                -label {Similar Subwidgets}
        $base.menu_rightclk.men24 add command \
                -accelerator {} \
		-command {vTcl:prop:apply_opt $vTcl(w,widget) \
			$::vTcl::_rclick_option $::vTcl::_rclick_variable \
			toplevel vTcl:prop:save_or_unsave_opt \
                        0} \
                -label {All Similar Widgets in toplevel}
        $base.menu_rightclk.men24 add command \
                -accelerator {} \
		-command {vTcl:prop:apply_opt $vTcl(w,widget) \
			$::vTcl::_rclick_option $::vTcl::_rclick_variable \
			all vTcl:prop:save_or_unsave_opt \
                        0} \
                -label {All Similar Widgets in this project}
        menu $base.menu_rightclk.men25 -tearoff 0
        $base.menu_rightclk.men25 add command \
                -accelerator {} \
		-command {vTcl:prop:apply_opt $vTcl(w,widget) \
			$::vTcl::_rclick_option $::vTcl::_rclick_variable \
			subwidgets vTcl:prop:save_or_unsave_opt \
                        1} \
                -label {Similar Subwidgets}
        $base.menu_rightclk.men25 add command \
                -accelerator {} \
		-command {vTcl:prop:apply_opt $vTcl(w,widget) \
			$::vTcl::_rclick_option $::vTcl::_rclick_variable \
			toplevel vTcl:prop:save_or_unsave_opt \
                        1} \
                -label {All Similar Widgets in toplevel}
        $base.menu_rightclk.men25 add command \
                -accelerator {} \
		-command {vTcl:prop:apply_opt $vTcl(w,widget) \
			$::vTcl::_rclick_option $::vTcl::_rclick_variable \
			all vTcl:prop:save_or_unsave_opt \
                        1} \
                -label {All Similar Widgets in this project}
        menu $base.menu_rightclk.men26 -tearoff 0
        $base.menu_rightclk.men26 add command \
                -accelerator {} \
		-command {vTcl:prop:apply_opt $vTcl(w,widget) \
			$::vTcl::_rclick_option $::vTcl::_rclick_variable \
			subwidgets vTcl:prop:set_opt \
                        [vTcl:at $::vTcl::_rclick_variable]} \
                -label {Similar Subwidgets}
        $base.menu_rightclk.men26 add command \
                -accelerator {} \
		-command {vTcl:prop:apply_opt $vTcl(w,widget) \
			$::vTcl::_rclick_option $::vTcl::_rclick_variable \
			toplevel vTcl:prop:set_opt \
                        [vTcl:at $::vTcl::_rclick_variable]} \
                -label {All Similar Widgets in toplevel}
        $base.menu_rightclk.men26 add command \
                -accelerator {} \
		-command {vTcl:prop:apply_opt $vTcl(w,widget) \
			$::vTcl::_rclick_option $::vTcl::_rclick_variable \
			all vTcl:prop:set_opt \
                        [vTcl:at $::vTcl::_rclick_variable]} \
                -label {All Similar Widgets in this project}
        menu $base.menu_rightclk.men22 -tearoff 0
        $base.menu_rightclk.men22 add command \
                -accelerator {} \
		-command {vTcl:prop:default_opt $vTcl(w,widget) \
			$::vTcl::_rclick_option $::vTcl::_rclick_variable} \
                -label {This Widget}
        $base.menu_rightclk.men22 add command \
                -accelerator {} \
		-command {vTcl:prop:apply_opt $vTcl(w,widget) \
			$::vTcl::_rclick_option $::vTcl::_rclick_variable \
			subwidgets vTcl:prop:default_opt} \
                -label {Similar Subwidgets}
        $base.menu_rightclk.men22 add command \
                -accelerator {} \
		-command {vTcl:prop:apply_opt $vTcl(w,widget) \
			$::vTcl::_rclick_option $::vTcl::_rclick_variable \
			toplevel vTcl:prop:default_opt} \
                -label {All Similar Widgets in toplevel}
        $base.menu_rightclk.men22 add command \
                -accelerator {} \
		-command {vTcl:prop:apply_opt $vTcl(w,widget) \
			$::vTcl::_rclick_option $::vTcl::_rclick_variable \
			all vTcl:prop:default_opt} \
                -label {All Similar Widgets in this project}
    }

    set ::vTcl::_rclick_option   $option
    set ::vTcl::_rclick_variable $variable

    tk_popup $base.menu_rightclk $X $Y
}

# This proc resets a given option to its default value
# The goal is to help making cross-platform applications easier by
# only saving options that are necessary

proc vTcl:prop:default_opt {w opt varName {user_param {}}} {

    global vTcl
    upvar #0 $varName var
    vTcl:WidgetVar $w options
    vTcl:WidgetVar $w defaults
    vTcl:WidgetVar $w save

    if {![info exists options($opt)]} { return }
    if {![info exists defaults($opt)]} { return }

    # only refresh the attribute editor if this is the
    # current widget, otherwise we'll get into trouble

    if {$w == $vTcl(w,widget)} {
	set var $defaults($opt)
    }

    $w configure $opt $defaults($opt)
    set options($opt) $defaults($opt)
    set save($opt) 0

    ::vTcl::change
}

# This proc applies an option to a widget

proc vTcl:prop:set_opt {w opt varName value} {

    global vTcl
    upvar #0 $varName var
    vTcl:WidgetVar $w options
    vTcl:WidgetVar $w defaults
    vTcl:WidgetVar $w save

    if {![info exists options($opt)]} { return }
    if {![info exists defaults($opt)]} { return }

    $w configure $opt $value
    set options($opt) $value

    # only refresh the attribute editor if this is the
    # current widget, otherwise we'll get into trouble

    if {$w == $vTcl(w,widget)} {
	set var $value
    }

    if {$value == $defaults($opt)} {
	set save($opt) 0
    } else {
	set save($opt) 1
    }
}

proc vTcl:prop:save_or_unsave_opt {w opt varName save_or_not} {

    vTcl:WidgetVar $w options
    vTcl:WidgetVar $w save

    if {![info exists options($opt)]} { return }

    set save($opt) $save_or_not
    ::vTcl::change
}

# Apply options settings to a range of widgets of the same
# class as w
#
# Parameters:
#   w         currently selected widget
#   opt       the option to change (eg. -background)
#   varName   name of variable for display in attributes editor
#   extent    which widgets to modify; can be one of
#             subwidgets
#                 apply to given widget and all its subwidgets
#             toplevel
#                 apply to all widgets in toplevel containing given widget
#             all
#                 apply to all widgets in the current project
#   action    name of proc to call for each widget
#             this callback proc should have the following parameters:
#                 w          widget to modify
#                 opt        option name (eg. -cursor)
#                 varName    name of variable in attributes editor
#                 user_param optional parameter
#   user_param
#             value of optional user parameter

proc vTcl:prop:apply_opt {w opt varName extent action {user_param {}}} {

    global vTcl

    # let's do it, but before that, we need to destroy the handles
    vTcl:destroy_handles

    set class [vTcl:get_class $w]

    switch $extent {
    subwidgets {
	# 0 because we don't want information for widget tree display
	set widgets [vTcl:complete_widget_tree $w 0]
    }
    toplevel {
	set top [winfo toplevel $w]
        set widgets [vTcl:complete_widget_tree $top 0]
    }
    all {
        set widgets [vTcl:complete_widget_tree . 0]
    }
    }

    foreach widget $widgets {
        if {[vTcl:get_class $widget] == $class} {
	    $action $widget $opt $varName $user_param
	}
    }

    # we are all set
    vTcl:create_handles $vTcl(w,widget)
}
