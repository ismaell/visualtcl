##############################################################################
#
# font.tcl - procedures to select a font and return its description
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

proc vTcl:font:prompt_user_font {target option} {
    global vTcl

    if {$target == ""} {return}
    set base ".vTcl.com_[vTcl:rename ${target}${option}]"

    if {[catch {set font_desc [$target cget $option]}] == 1} { return }

    vTcl:log "prompt_user_font: base=$base, font=$font_desc"

    set r [vTcl:font:prompt_noborder_fontlist $font_desc]
    if {$r == ""} {
        return
    } else {
        $target configure $option $r

        # refresh property manager
        vTcl:update_widget_info $target
        vTcl:prop:update_attr
    }
}

proc vTcl:font:prompt_user_font_2 {font_desc} {
    set base .vTcl.fontmgr
    set r [vTcl:font:get_font_dlg $base $font_desc]
    return $r
}

proc vTcl:font:fill_fonts {base} {
    global widget
    global vTcl

    $widget($base.listbox) delete 0 end
    eval $widget($base.listbox) insert 0 [lsort [font families] ]

    set list_contents [$widget($base.listbox) get 0 end]
    set family [font configure $vTcl(x,$base,font) -family]
    set index [lsearch -exact $list_contents $family]
    if {$index >=0 } {
	$widget($base.listbox) selection clear 0 end
	$widget($base.listbox) selection set $index
	$widget($base.listbox) see $index
    }
}

proc vTcl:font:init_fontselect {base} {
    global vTcl widget

    $widget($base.text) delete 1.0 end
    $widget($base.text) insert 1.0 "abcdefghijklmnopqrstuvxwyz\n0123456789"

    trace variable vTcl(x,$base,weight)     w "vTcl:font:update_font"
    trace variable vTcl(x,$base,slant)      w "vTcl:font:update_font"
    trace variable vTcl(x,$base,underline)  w "vTcl:font:update_font"
    trace variable vTcl(x,$base,overstrike) w "vTcl:font:update_font"
    trace variable vTcl(x,$base,size)       w "vTcl:font:update_font"
}

proc vTcl:font:uninit_fontselect {base} {
    global vTcl

    trace vdelete vTcl(x,$base,weight)     w "vTcl:font:update_font"
    trace vdelete vTcl(x,$base,slant)      w "vTcl:font:update_font"
    trace vdelete vTcl(x,$base,underline)  w "vTcl:font:update_font"
    trace vdelete vTcl(x,$base,overstrike) w "vTcl:font:update_font"
    trace vdelete vTcl(x,$base,size)       w "vTcl:font:update_font"
}

proc vTcl:font:update_font {name1 name2 op} {
    global vTcl widget

    regexp .*,(.*),.* $name2 matchAll base

    font configure $vTcl(x,$base,font) -weight     $vTcl(x,$base,weight) \
				       -slant      $vTcl(x,$base,slant) \
				       -underline  $vTcl(x,$base,underline) \
				       -overstrike $vTcl(x,$base,overstrike) \
				       -size       $vTcl(x,$base,size)
}

proc vTcl:font:font_select_family {base win y} {
    global vTcl widget

    set index [$win nearest $y]
    if {$index != ""} {
	font configure $vTcl(x,$base,font) -family [$win get $index]
    }
}

proc vTcl:font:get_font_dlg {base font_desc} {

    if {$base == ""} {
        set base .top27
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    global widget
    global vTcl

    set vTcl(x,$base,dlgstatus)          "cancel"

    set widget($base.listbox)            "$base.fra28.cpd29.01"
    set widget($base.text)               "$base.cpd43.03"
    set widget(rev,$base.cpd43.03)       "$base.text"
    set widget(rev,$base.fra28.cpd29.01) "$base.listbox"

    eval set font_desc \"[font actual $font_desc]\"

    catch {font delete $vTcl(x,$base,font)}
    set vTcl(x,$base,font)  [eval font create $font_desc]

    set vTcl(x,$base,weight)     [font configure $vTcl(x,$base,font) -weight]
    set vTcl(x,$base,slant)      [font configure $vTcl(x,$base,font) -slant]
    set vTcl(x,$base,underline)  [font configure $vTcl(x,$base,font) -underline]
    set vTcl(x,$base,overstrike) [font configure $vTcl(x,$base,font) -overstrike]
    set vTcl(x,$base,size)       [font configure $vTcl(x,$base,font) -size]

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class vTcl
    wm withdraw $base
    wm transient $base .vTcl
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "Font selector"
    frame $base.fra28 \
        -height 75 \
        -relief flat \
        -width 125
    frame $base.fra28.cpd29 \
        -borderwidth 1 -relief sunken -width 30
    listbox $base.fra28.cpd29.01 -borderwidth 0 \
        -xscrollcommand "$base.fra28.cpd29.02 set" \
        -yscrollcommand "$base.fra28.cpd29.03 set"
    bind $base.fra28.cpd29.01 <Button-1> \
    	"vTcl:font:font_select_family $base %W %y"
    scrollbar $base.fra28.cpd29.02 \
        -command "$base.fra28.cpd29.01 xview" -cursor left_ptr \
        -orient horiz
    scrollbar $base.fra28.cpd29.03 \
        -command "$base.fra28.cpd29.01 yview" -cursor left_ptr \
        -orient vert
    label $base.fra28.lab30 \
        -borderwidth 1 \
        -padx 5 -pady 0 -text Size:
    label $base.fra28.lab31 \
        -borderwidth 1 \
        -padx 5 -text Weight:
    label $base.fra28.lab32 \
        -borderwidth 1 \
        -padx 5 -text Slant:
    checkbutton $base.fra28.che34 \
        -text Underline \
        -variable vTcl(x,$base,underline)
    checkbutton $base.fra28.che35 \
        -text Overstrike \
        -variable vTcl(x,$base,overstrike)
    vTcl:entry $base.fra28.ent36 \
        -textvariable vTcl(x,$base,size) -width 10 -bg white
    bind $base.fra28.ent36 <KeyPress> {
        if {! [regexp {[0-9]+} %A]                   &&
            "%K" != "Left"      && "%K" != "Right"   &&
            "%K" != "Up"        && "%K" != "Down"    &&
            "%K" != "BackSpace" && "%K" != "Delete"} {
            bell
            break
        }
    }
    menubutton $base.fra28.men37 \
        -menu $base.fra28.men37.m -padx 4 -pady 3 \
        -relief raised -text normal -textvariable vTcl(x,$base,weight) \
        -width 10
    menu $base.fra28.men37.m \
        -tearoff 0
    $base.fra28.men37.m add command \
        -command "set vTcl(x,$base,weight) normal" -label normal
    $base.fra28.men37.m add command \
        -command "set vTcl(x,$base,weight) bold" -label bold
    menubutton $base.fra28.men38 \
        -menu $base.fra28.men38.m -padx 4 -pady 3 \
        -relief raised -text roman -textvariable vTcl(x,$base,slant) \
        -width 10
    menu $base.fra28.men38.m \
        -tearoff 0
    $base.fra28.men38.m add command \
        -command "set vTcl(x,$base,slant) roman" -label roman
    $base.fra28.men38.m add command \
        -command "set vTcl(x,$base,slant) italic" -label italic
    label $base.fra28.lab39 \
        -borderwidth 1
    button $base.fra28.but32 \
        -command "incr vTcl(x,$base,size)" \
        -padx 2 -pady 0 -image up
    button $base.fra28.but33 \
        -command "incr vTcl(x,$base,size) -1" \
        -padx 2 -pady 0 -image down
    label $base.lab41 \
        -borderwidth 1 \
        -text Sample
    frame $base.cpd43 \
        -borderwidth 0 \
        -relief flat -width 50
    scrollbar $base.cpd43.01 \
        -command "$base.cpd43.03 xview" -cursor left_ptr \
        -orient horiz
    scrollbar $base.cpd43.02 \
        -command "$base.cpd43.03 yview" -cursor left_ptr \
        -orient vert
    text $base.cpd43.03 \
        -font $vTcl(x,$base,font) \
        -height 3 -bg white \
        -width 8 -wrap none \
        -xscrollcommand "$base.cpd43.01 set" \
        -yscrollcommand "$base.cpd43.02 set"
    # we don't want syntax coloring, which is the default for
    # text widgets in vTcl whose window path name starts with .vTcl
    bind $base.cpd43.03 <KeyRelease> "break"
    bind $base.cpd43.03 <KeyPress-Return> {
        tkTextInsert %W "\n"
        focus %W
        break
    }
    frame $base.fra27 \
        -relief flat
    button $base.fra27.but28 \
        -padx 9 -text OK -width 6 \
        -command "vTcl:font:button_ok $base"
    button $base.fra27.but29 \
        -padx 9 -text Cancel -width 6 \
        -command "vTcl:font:button_cancel $base"
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra28 \
        -in $base -anchor center -expand 1 -fill both -side top
    grid columnconf $base.fra28 0 -weight 1
    grid rowconf $base.fra28 6 -weight 1
    grid $base.fra28.cpd29 \
        -in $base.fra28 -column 0 -row 0 -columnspan 1 -rowspan 7 \
        -sticky nesw
    grid columnconf $base.fra28.cpd29 0 -weight 1
    grid rowconf $base.fra28.cpd29 0 -weight 1
    grid $base.fra28.cpd29.01 \
        -in $base.fra28.cpd29 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw
    grid $base.fra28.cpd29.02 \
        -in $base.fra28.cpd29 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew
    grid $base.fra28.cpd29.03 \
        -in $base.fra28.cpd29 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns
    grid $base.fra28.lab30 \
        -in $base.fra28 -column 1 -row 0 -columnspan 1 -rowspan 2 -pady 5 \
        -sticky e
    grid $base.fra28.lab31 \
        -in $base.fra28 -column 1 -row 2 -columnspan 1 -rowspan 1 -sticky e
    grid $base.fra28.lab32 \
        -in $base.fra28 -column 1 -row 3 -columnspan 1 -rowspan 1 -sticky e
    grid $base.fra28.che34 \
        -in $base.fra28 -column 1 -row 4 -columnspan 2 -rowspan 1 -ipadx 5 \
        -sticky w
    grid $base.fra28.che35 \
        -in $base.fra28 -column 1 -row 5 -columnspan 2 -rowspan 1 -padx 5 \
        -sticky w
    grid $base.fra28.ent36 \
        -in $base.fra28 -column 2 -row 0 -columnspan 1 -rowspan 2 -pady 5
    grid $base.fra28.men37 \
        -in $base.fra28 -column 2 -row 2 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5
    grid $base.fra28.men38 \
        -in $base.fra28 -column 2 -row 3 -columnspan 1 -rowspan 1 -padx 5 \
        -pady 5
    grid $base.fra28.lab39 \
        -in $base.fra28 -column 1 -row 6 -columnspan 2 -rowspan 1 \
        -sticky nesw
    grid $base.fra28.but32 \
        -in $base.fra28 -column 3 -row 0 -columnspan 1 -rowspan 1
    grid $base.fra28.but33 \
        -in $base.fra28 -column 3 -row 1 -columnspan 1 -rowspan 1
    pack $base.lab41 \
        -in $base -anchor center -expand 0 -fill none -side top
    pack $base.cpd43 \
        -in $base -anchor center -expand 0 -fill both -side top
    grid columnconf $base.cpd43 0 -weight 1
    grid rowconf $base.cpd43 0 -weight 1
    grid $base.cpd43.01 \
        -in $base.cpd43 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew
    grid $base.cpd43.02 \
        -in $base.cpd43 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns
    grid $base.cpd43.03 \
        -in $base.cpd43 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw
    pack $base.fra27 \
        -in $base -anchor center -side top -pady 2
    pack $base.fra27.but28 \
        -in $base.fra27 -anchor center -padx 10 -pady 5 -side left
    pack $base.fra27.but29 \
        -in $base.fra27 -anchor center -padx 10 -pady 5 -side right

    vTcl:font:fill_fonts $base
    vTcl:font:init_fontselect $base

    wm geometry $base 380x451
    vTcl:center $base 380 451
    wm deiconify $base

    tkwait window $base
    update idletasks

    # argh... don't forget this!
    vTcl:font:uninit_fontselect $base

    switch -- $vTcl(x,$base,dlgstatus) {
    	"ok" {
    		return [font configure $vTcl(x,$base,font)]
    	}
    	"cancel" -
    	default  { return }
    }
}

proc vTcl:font:button_ok {base} {
    global vTcl
    # vTcl:command:save_geom $base
    set vTcl(x,$base,dlgstatus)          "ok"
    destroy $base
}

proc vTcl:font:button_cancel {base} {
    global vTcl
    # vTcl:command:save_geom $base
    set vTcl(x,$base,dlgstatus)          "cancel"
    destroy $base
}

proc vTcl:font:init_stock {} {
    global vTcl

    set vTcl(fonts,objects) ""
    set vTcl(fonts,counter) 0

    # stock fonts
    vTcl:font:add_font "-family helvetica -size 12"              stock
    vTcl:font:add_font "-family helvetica -size 12 -underline 1" stock underline
    vTcl:font:add_font "-family courier -size 12"                stock
    vTcl:font:add_font "-family times -size 12"                  stock
    vTcl:font:add_font "-family helvetica -size 12 -weight bold" stock
    vTcl:font:add_font "-family courier -size 12 -weight bold"   stock
    vTcl:font:add_font "-family times -size 12 -weight bold"     stock
    vTcl:font:add_font "-family lucida -size 18"                 stock
    vTcl:font:add_font "-family lucida -size 18 -slant italic"   stock
}

proc vTcl:font:get_type {object} {
    global vTcl
    return $vTcl(fonts,$object,type)
}

proc vTcl:font:get_key {object} {
    global vTcl
    return $vTcl(fonts,$object,key)
}

proc vTcl:font:get_font {key} {
    global vTcl
    if {[info exists vTcl(fonts,$key,object)]} then {
        return $vTcl(fonts,$key,object)
    } else {
        return ""
    }
}

proc {vTcl:font:add_font} {font_descr font_type {newkey {}}} {
     global vTcl

     incr vTcl(fonts,counter)
     set newfont [eval font create $font_descr]

     lappend vTcl(fonts,objects) $newfont

     # each font has its unique key so that when a project is
     # reloaded, the key is used to find the font description

     if {$newkey == ""} {
          set newkey vTcl:font$vTcl(fonts,counter)

          # let's find an unused font key
          while {[vTcl:font:get_font $newkey] != ""} {
             incr vTcl(fonts,counter)
             set newkey vTcl:font$vTcl(fonts,counter)
          }
     }

     set vTcl(fonts,$newfont,type)                      $font_type
     set vTcl(fonts,$newfont,key)                       $newkey
     set vTcl(fonts,$vTcl(fonts,$newfont,key),object)   $newfont

     lappend vTcl(fonts,$font_type) $newfont

     # in case caller needs it
     return $newfont
}

proc vTcl:font:delete_font {key} {
     global vTcl

     set object $vTcl(fonts,$key,object)

     set index [lsearch -exact $vTcl(fonts,objects) $object]
     set vTcl(fonts,objects) [lreplace $vTcl(fonts,objects) $index $index]

     font delete $object

     unset vTcl(fonts,$object,type)
     unset vTcl(fonts,$object,key)
     unset vTcl(fonts,$key,object)
}

proc vTcl:font:ask_delete_font {key} {
     global vTcl

     set object $vTcl(fonts,$key,object)
     set descr [font configure $object]

     set result [
          tk_messageBox \
		-message "Do you want to remove '$descr' from the project?" \
		-title "Visual Tcl" \
		-type yesno \
		-icon question
     ]

     if {$result == "yes"} {
	  set pos [vTcl:font:get_manager_position]

          vTcl:font:delete_font $key
          vTcl:font:refresh_manager $pos
     }
}

proc vTcl:font:remove_user_fonts {} {
     global vTcl

     foreach object $vTcl(fonts,objects) {
	if {$vTcl(fonts,$object,type) == "user"} {
	    vTcl:font:delete_font $vTcl(fonts,$object,key)
	}
     }

     vTcl:font:refresh_manager
}

proc {vTcl:font:create_link} {t tag link_cmd} {
     global vTcl

     $t tag configure $tag -foreground blue  -font $vTcl(fonts,underline,object)

     $t tag bind $tag <Enter> "$t tag configure $tag -foreground red"
     $t tag bind $tag <Leave> "$t tag configure $tag -foreground blue"

     $t tag bind $tag <ButtonPress> "$link_cmd"
}

proc vTcl:font:display_fonts {base} {
     set t $base.cpd31.03

     if {![winfo exists $t]} {
     	return
     }

     vTcl:font:display_fonts_in_text $t
}

proc {vTcl:font:display_fonts_in_text} {t} {
     global vTcl

     $t configure -state normal
     $t delete 0.0 end

     foreach object $vTcl(fonts,objects) {

        # add short font description

        $t insert end "[font configure $object -family] " vTcl:fontname
        $t insert end "[font configure $object -size] " vTcl:fontname
        $t insert end "[font configure $object -weight] " vTcl:fontname
        $t insert end "[font configure $object -slant]" vTcl:fontname
        $t insert end " ($vTcl(fonts,$object,type))\n"

        $t insert end "\n"
        $t insert end "Abcdefghijklmnopqrstuvwxyz 0123456789\n"  vTcl:$object
        $t insert end "\n"

	if {$vTcl(fonts,$object,type) == "user"} {
	    $t insert end "Delete" "vTcl:hilite_delete_$object"
	    vTcl:font:create_link $t vTcl:hilite_delete_$object \
		    "vTcl:font:ask_delete_font $vTcl(fonts,$object,key)"
	    $t insert end " "

	    $t insert end "Change" "vTcl:hilite_change_$object"
	    vTcl:font:create_link $t vTcl:hilite_change_$object \
		    "vTcl:font:font_change $object"
	    $t insert end "\n"
	}

        $t insert end \
        "_________________________________________________________________\n"

        $t tag configure vTcl:$object -font $object -justify left
        $t insert end "\n"
     }

     $t tag configure vTcl:fontname \
     	-font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1

     $t configure -state disabled
}

proc {vTcl:font:font_change} {object} {
     global vTcl

     set font_desc [font configure $object]
     vTcl:log "going to change: $font_desc"

     set font_desc [vTcl:font:prompt_user_font_2 $font_desc]

     if {$font_desc != ""} {

        vTcl:log "change font: $font_desc"
        eval font configure $object $font_desc

        set pos [vTcl:font:get_manager_position]
        vTcl:font:refresh_manager $pos
     }
}

proc vTclWindow.vTcl.fontManager {args} {
    global vTcl

    set base ""
    if {$base == ""} {
        set base .vTcl.fontManager
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    set vTcl(fonts,font_mgr,win) $base

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel \
        -background #bcbcbc -highlightbackground #bcbcbc \
        -highlightcolor #000000
    wm withdraw $base
    wm focusmodel $base passive
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    update
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "Font manager"
    wm transient .vTcl.fontManager .vTcl

    frame $base.butfr

    button $base.butfr.but30 \
        -command {set font_desc "-family {Helvetica} -size 12"

set font_desc [vTcl:font:prompt_user_font_2 $font_desc]

if {$font_desc != ""} {

   vTcl:log "new font: $font_desc"
   vTcl:font:add_font $font_desc user
   vTcl:font:display_fonts $vTcl(fonts,font_mgr,win)
   $vTcl(fonts,font_mgr,win).cpd31.03 yview end
}} \
        -padx 9 -pady 3 -image [vTcl:image:get_image add.gif]

    button $base.butfr.but31 \
    	-command "wm withdraw $base" -image [vTcl:image:get_image ok.gif]

    frame $base.cpd31 \
        -borderwidth 2 -height 30 \
        -relief sunken \
        -width 30
    scrollbar $base.cpd31.01 \
        -command "$base.cpd31.03 xview" -cursor left_ptr \
        -orient horiz
    scrollbar $base.cpd31.02 \
        -command "$base.cpd31.03 yview" -cursor left_ptr \
        -orient vert
    text $base.cpd31.03 \
        -background white -cursor left_ptr \
        -foreground #000000 -height 1 -borderwidth 0 \
        -state disabled -width 8 -wrap none \
        -xscrollcommand "$base.cpd31.01 set" \
        -yscrollcommand "$base.cpd31.02 set"
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.butfr -side top -in $base -fill x
    pack $base.butfr.but30 \
        -anchor nw -expand 0 -fill none -side left
    vTcl:set_balloon $base.butfr.but30 "Add new font"
    pack $base.butfr.but31 \
        -anchor nw -expand 0 -fill none -side right
    vTcl:set_balloon $base.butfr.but31 "Close"

    pack $base.cpd31 \
        -in $base -anchor center -expand 1 -fill both -side top

    grid columnconf $base.cpd31 0 -weight 1
    grid rowconf $base.cpd31 0 -weight 1
    grid $base.cpd31.01 \
        -in $base.cpd31 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew
    grid $base.cpd31.02 \
        -in $base.cpd31 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns
    grid $base.cpd31.03 \
        -in $base.cpd31 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw

    wm geometry $base 491x544+314+132
    vTcl:center $base 491 544
    catch {wm geometry $base $vTcl(geometry,$base)}
    wm deiconify $base

    vTcl:font:display_fonts $base
    wm protocol $base WM_DELETE_WINDOW "wm withdraw $base"
    vTcl:setup_vTcl:bind $base
}

proc vTcl:font:prompt_font_manager {} {
    Window show .vTcl.fontManager
}

proc vTcl:font:dump_proc {fileID name} {
    puts $fileID "proc $name {" nonewline
    puts $fileID "[info args $name]} {" nonewline
    puts $fileID "[info body $name]}"
    puts $fileID ""
}

proc vTcl:font:generate_font_stock {fileID} {
    global vTcl

    ## We didn't use any fonts.  We don't need this code.
    if {[lempty $vTcl(dump,stockFonts)] && [lempty $vTcl(dump,userFonts)]} {
    	return
    }

    puts $fileID {############################}
    puts $fileID "\# vTcl Code to Load Stock Fonts\n"
    puts $fileID "\nif {!\[info exist vTcl(sourcing)\]} \{"
    puts $fileID "set vTcl(fonts,counter) 0"

    vTcl:font:dump_proc $fileID "vTcl:font:add_font"
    vTcl:font:dump_proc $fileID "vTcl:font:get_font"

    foreach font $vTcl(dump,stockFonts) {
	puts $fileID "vTcl:font:add_font \\"
	puts $fileID "    \"[font configure $font]\" \\"
	puts $fileID "    [vTcl:font:get_type $font] \\"
	puts $fileID "    [vTcl:font:get_key $font]"
    }

    puts $fileID "\}"
}

proc vTcl:font:generate_font_user {fileID} {
    global vTcl

    if {[lempty $vTcl(dump,userFonts)]} { return }

    puts $fileID {############################}
    puts $fileID "\# vTcl Code to Load User Fonts\n"

    foreach font $vTcl(dump,userFonts) {
	puts $fileID "vTcl:font:add_font \\"
	puts $fileID "    \"[font configure $font]\" \\"
	puts $fileID "    [vTcl:font:get_type $font] \\"
	puts $fileID "    [vTcl:font:get_key $font]"
    }
}

proc vTcl:font:create_noborder_fontlist {base} {
    if {$base == ""} {
        set base .vTcl.noborder_fontlist
    }

    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    global vTcl
    global tcl_platform

    set vTcl(font,noborder_fontlist,win) $base
    set vTcl(font,noborder_fontlist,font) "nope"

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel \
        -background #bcbcbc -highlightbackground #bcbcbc \
        -highlightcolor #000000
    wm focusmodel $base passive

    vTcl:prepare_pulldown $base 396 252

    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm resizable $base 1 1

    frame $base.cpd29 \
        -background #bcbcbc -borderwidth 1 -height 30 \
        -highlightbackground #bcbcbc -highlightcolor #000000 -relief raised \
        -width 30
    scrollbar $base.cpd29.02 \
        -command "$base.cpd29.03 yview" -cursor left_ptr \
        -orient vert
    text $base.cpd29.03 \
        -background white \
        -foreground #000000 -highlightbackground #f3f3f3 \
        -highlightcolor #000000 -selectbackground #000080 \
        -selectforeground #ffffff -state disabled \
        -yscrollcommand "$base.cpd29.02 set" -cursor left_ptr
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.cpd29 \
        -in $base -anchor center -expand 1 -fill both -side top
    grid columnconf $base.cpd29 0 -weight 1
    grid rowconf $base.cpd29 0 -weight 1
    grid $base.cpd29.02 \
        -in $base.cpd29 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns
    grid $base.cpd29.03 \
        -in $base.cpd29 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw

    vTcl:display_pulldown $base 396 252 \
        "set vTcl(font,noborder_fontlist,font) <cancel>"

    vTcl:font:fill_noborder_font_list $base.cpd29.03
}

proc vTcl:font:tag_font_list {t tagname object} {

    $t tag bind $tagname <Enter> \
        "$t tag configure $tagname -background gray -relief raised -borderwidth 2"

    $t tag bind $tagname <Leave> \
        "$t tag configure $tagname -background white -relief flat -borderwidth 0"

    $t tag bind $tagname <ButtonPress-1> \
        "set vTcl(font,noborder_fontlist,font) $object"
}

proc {vTcl:font:fill_noborder_font_list} {t} {
    global vTcl

    # set a tab on the right side

    update
    $t configure -state normal -tabs "[winfo width $t]p"
    $t delete 0.0 end

    foreach object $vTcl(fonts,objects) {

        $t insert end \
           "ABDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwyz 0123456789\n" \
            vTcl:font_list:$object

        $t tag configure vTcl:font_list:$object -font $object

        vTcl:font:tag_font_list $t \
                                vTcl:font_list:$object \
                                $object
    }

    # add additional item to create a new font
    $t insert end "\n New font...\t\n\t" vTcl:font_list:new

    vTcl:font:tag_font_list $t \
                            vTcl:font_list:new \
                            <new>

    # cancel
    $t insert end "\n Cancel\t\n\t" vTcl:font_list:cancel
    $t tag configure vTcl:font_list:cancel -foreground #ff0000

    vTcl:font:tag_font_list $t \
                            vTcl:font_list:cancel \
                            <cancel>

    $t configure -state disabled
}

proc vTcl:font:prompt_noborder_fontlist {font} {
    global vTcl

    vTcl:font:create_noborder_fontlist ""

    # do not reposition window according to root window
    vTcl:dialog_wait $vTcl(font,noborder_fontlist,win) vTcl(font,noborder_fontlist,font) 1
    destroy $vTcl(font,noborder_fontlist,win)

    # user wants a new font ?
    if {$vTcl(font,noborder_fontlist,font)=="<new>"} {
        set font_desc [vTcl:font:prompt_user_font_2 "-family helvetica -size 12"]

        if {$font_desc != ""} {
            set vTcl(font,noborder_fontlist,font) \
                [vTcl:font:add_font $font_desc user]

            # refresh font manager
            vTcl:font:refresh_manager 1.0

        } else {
            set vTcl(font,noborder_fontlist,font) ""
        }
    } elseif {$vTcl(font,noborder_fontlist,font)=="<cancel>"} {
        return $font
    }

    return $vTcl(font,noborder_fontlist,font)
}

# translation for options when saving files
set vTcl(option,translate,-font) vTcl:font:translate
set vTcl(option,noencase,-font) 1

proc vTcl:font:translate {value} {
    global vTcl

    if [info exists vTcl(fonts,$value,key)] {
	set value "\[vTcl:font:get_font \"$vTcl(fonts,$value,key)\"\]"
    }

    return $value
}

proc vTcl:font:refresh_manager {{position 0.0}} {
    global vTcl

    if [info exists vTcl(fonts,font_mgr,win)] {
	if [winfo exists $vTcl(fonts,font_mgr,win)] {
	    vTcl:font:display_fonts $vTcl(fonts,font_mgr,win)
	    $vTcl(fonts,font_mgr,win).cpd31.03 yview moveto $position
	}
    }
}

proc vTcl:font:get_manager_position {} {
    global vTcl
    return [lindex [$vTcl(fonts,font_mgr,win).cpd31.03 yview] 0]
}


