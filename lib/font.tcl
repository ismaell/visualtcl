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
    set r [SelectFont .vTcl.fontmgr -font $font_desc]
    if {$r != ""} {
        set r [font actual $r]
    }
    # set r [vTcl:font:get_font_dlg $base $font_desc]
    return $r
}

proc vTcl:font:init_stock {} {
    set ::vTcl(fonts,objects) ""
    set ::vTcl(fonts,counter) 0

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
    return $::vTcl(fonts,$object,type)
}

proc vTcl:font:get_key {object} {
    return $::vTcl(fonts,$object,key)
}

proc vTcl:font:get_descr {object} {
    return $::vTcl(fonts,$object,font_descr)
}

proc vTcl:font:get_font {key} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[info exists ::vTcl(fonts,$key,object)]} then {
        return $::vTcl(fonts,$key,object)
    } else {
        return ""
    }
}

proc vTcl:font:getFontFromDescr {font_descr} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[info exists ::vTcl(fonts,$font_descr,object)]} {
        return $::vTcl(fonts,$font_descr,object)
    } else {
        return ""
    }
}

proc {vTcl:font:add_font} {font_descr font_type {newkey {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[info exists ::vTcl(fonts,$font_descr,object)]} {
        ## cool, it already exists
        return $::vTcl(fonts,$font_descr,object)
    }

     incr ::vTcl(fonts,counter)
     set newfont [eval font create $font_descr]
     lappend ::vTcl(fonts,objects) $newfont

     ## each font has its unique key so that when a project is
     ## reloaded, the key is used to find the font description
     if {$newkey == ""} {
          set newkey vTcl:font$::vTcl(fonts,counter)

          ## let's find an unused font key
          while {[vTcl:font:get_font $newkey] != ""} {
             incr ::vTcl(fonts,counter)
             set newkey vTcl:font$::vTcl(fonts,counter)
          }
     }

     set ::vTcl(fonts,$newfont,type)       $font_type
     set ::vTcl(fonts,$newfont,key)        $newkey
     set ::vTcl(fonts,$newfont,font_descr) $font_descr
     set ::vTcl(fonts,$font_descr,object)  $newfont
     set ::vTcl(fonts,$newkey,object)      $newfont

     lappend ::vTcl(fonts,$font_type) $newfont

     ## in case caller needs it
     return $newfont
}

proc vTcl:font:delete_font {key} {
     global vTcl

     set object $vTcl(fonts,$key,object)
     set font_descr $vTcl(fonts,$object,font_descr)

     set index [lsearch -exact $vTcl(fonts,objects) $object]
     set vTcl(fonts,objects) [lreplace $vTcl(fonts,objects) $index $index]

     font delete $object

     unset vTcl(fonts,$object,type)
     unset vTcl(fonts,$object,key)
     unset vTcl(fonts,$object,font_descr)
     unset vTcl(fonts,$key,object)
     unset vTcl(fonts,$font_descr,object)
}

proc vTcl:font:ask_delete_font {key} {
     global vTcl

     set object $vTcl(fonts,$key,object)
     set descr [font configure $object]

     set result [
          ::vTcl::MessageBox \
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

    vTcl:toolbar_button $base.butfr.but30 \
        -command {set font_desc "-family {Helvetica} -size 12"

set font_desc [vTcl:font:prompt_user_font_2 $font_desc]

if {$font_desc != ""} {

   vTcl:log "new font: $font_desc"
   vTcl:font:add_font $font_desc user
   vTcl:font:display_fonts $vTcl(fonts,font_mgr,win)
   $vTcl(fonts,font_mgr,win).cpd31.03 yview end
}} \
        -padx 9 -pady 3 -image [vTcl:image:get_image add.gif]

    ::vTcl::OkButton $base.butfr.but31 -command "Window hide $base"

    ScrolledWindow $base.cpd31
    text $base.cpd31.03 \
        -background white -cursor left_ptr \
        -foreground #000000 -height 1 -borderwidth 0 \
        -state disabled -width 8 -wrap none
    $base.cpd31 setwidget $base.cpd31.03

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
    pack $base.cpd31.03

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

proc vTcl:font:dump_create_font {font} {
	return [list [list [vTcl:font:get_descr $font] \
	             [vTcl:font:get_type $font] \
	             [vTcl:font:get_key $font]]]
}

proc vTcl:font:generate_font_stock {fileID} {
    global vTcl

    ## We didn't use any fonts.  We don't need this code.
    if {[lempty $vTcl(dump,stockFonts)] && [lempty $vTcl(dump,userFonts)]} {
    	return
    }

    puts $fileID {#############################################################################}
    puts $fileID "\# vTcl Code to Load Stock Fonts\n"
    puts $fileID "\nif {!\[info exist vTcl(sourcing)\]} \{"
    puts $fileID "set vTcl(fonts,counter) 0"

    foreach i {vTcl:font:add_font
               vTcl:font:getFontFromDescr} {
        puts $fileID [vTcl:dump_proc $i]
    }

    foreach font $vTcl(dump,stockFonts) {
	puts $fileID "vTcl:font:add_font \\"
	puts $fileID "    \"[vTcl:font:get_descr $font]\" \\"
	puts $fileID "    [vTcl:font:get_type $font] \\"
	puts $fileID "    [vTcl:font:get_key $font]"
    }

    puts $fileID "\}"
}

proc vTcl:font:generate_font_user {fileID} {
    global vTcl

    if {[lempty $vTcl(dump,userFonts)]} { return }

    puts $fileID {#############################################################################}
    puts $fileID "\# vTcl Code to Load User Fonts\n"

    foreach font $vTcl(dump,userFonts) {
	puts $fileID "vTcl:font:add_font \\"
	puts $fileID "    \"[vTcl:font:get_descr $font]\" \\"
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

    ScrolledWindow $base.cpd29 -background #bcbcbc
    text $base.cpd29.03 \
        -background white \
        -foreground #000000 -highlightbackground #f3f3f3 \
        -highlightcolor #000000 -selectbackground #000080 \
        -selectforeground #ffffff -state disabled \
        -cursor left_ptr
    $base.cpd29 setwidget $base.cpd29.03

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.cpd29 \
        -in $base -anchor center -expand 1 -fill both -side top
    pack $base.cpd29.03

    vTcl:display_pulldown $base 396 252 \
        "set vTcl(font,noborder_fontlist,font) <cancel>"

    vTcl:font:fill_noborder_font_list $base.cpd29.03
}

proc vTcl:font:tag_font_list {t tagname object} {

    $t tag bind $tagname <Enter> \
        "$t tag configure $tagname -background gray -relief raised -borderwidth 2"

    $t tag bind $tagname <Leave> \
        "$t tag configure $tagname -background white -relief flat -borderwidth 0"

    ## Change by Nelson 2003/05/03 bug 529307. If we catch ButtonPress
    ## instead of ButtonRelease, we risk strange things happening with the mouse
    ## grabbing widgets.
    $t tag bind $tagname <ButtonRelease-1> \
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

TranslateOption    -font vTcl:font:translate
NoEncaseOption     -font 1

proc vTcl:font:translate {value} {
    if [info exists ::vTcl(fonts,$value,font_descr)] {
	set value "\[vTcl:font:getFontFromDescr \"$::vTcl(fonts,$value,font_descr)\"\]"
    }

    return $value
}



