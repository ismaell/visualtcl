##############################################################################
#
# prefs.tcl - procedures for editing application preferences
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

proc vTcl:prefs:uninit {base} {
    catch {destroy $base.tb}
}

proc vTcl:prefs:init {base} {
    # this is to store all variables
    namespace eval prefs {
       variable balloon          ""
       variable getname          ""
       variable shortname        ""
       variable fullcfg          ""
       variable saveglob         ""
       variable winfocus         ""
       variable autoplace        ""
       variable cmdalias         ""
       variable autoalias        ""
       variable multiplace       ""
       variable autoloadcomp     ""
       variable autoloadcompfile ""
       variable font_dlg         ""
       variable font_fixed       ""
       variable manager          ""
       variable encase           ""
       variable projecttype      ""
       variable imageeditor      ""
       variable saveimagesinline ""
    }

    # set the variables for the dialog
    vTcl:prefs:data_exchange 0

    # destroy the notebook if already existing
    vTcl:prefs:uninit $base
    set tb [vTcl:tabnotebook_create $base.tb]
    pack $tb -fill both -expand 1

    set tb_basics  [vTcl:tabnotebook_page $tb "Basics"]
    set tb_project [vTcl:tabnotebook_page $tb "Project"]
    set tb_fonts   [vTcl:tabnotebook_page $tb "Fonts"]
    set tb_images  [vTcl:tabnotebook_page $tb "Images"]

    vTcl:prefs:basics  $tb_basics
    vTcl:prefs:project $tb_project
    vTcl:prefs:fonts   $tb_fonts
    vTcl:prefs:images  $tb_images
}

proc vTclWindow.vTcl.prefs {{base ""} {container 0}} {
    global widget

    if {$base == ""} {
        set base .vTcl.prefs
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    toplevel $base -class Topleve \
    	-background #dcdcdc -highlightbackground #dcdcdc \
	-highlightcolor #000000
    wm focusmodel $base passive
    wm geometry $base 409x500+240+159
    vTcl:center $base 409 500
    wm maxsize $base 1284 1010
    wm minsize $base 100 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm withdraw $base
    wm title $base "Visual Tcl Preferences"
    wm protocol $base WM_DELETE_WINDOW "wm withdraw $base"
    }
    frame $base.fra19 \
        -background #dcdcdc -borderwidth 2 -height 75 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -width 125
    button $base.fra19.but20 \
        -activebackground #dcdcdc -activeforeground #000000 \
        -background #dcdcdc \
        -command "vTcl:prefs:data_exchange 1; wm withdraw $base" \
        -foreground #000000 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -padx 9 -text OK -width 10
    button $base.fra19.but21 \
        -activebackground #dcdcdc -activeforeground #000000 \
        -command "wm withdraw $base" \
        -background #dcdcdc -foreground #000000 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -padx 9 -text Cancel -width 10
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra19 \
        -in $base -anchor center -expand 0 -fill none -pady 5 -side bottom
    pack $base.fra19.but20 \
        -in $base.fra19 -anchor center -expand 0 -fill none -padx 10 \
        -side left
    pack $base.fra19.but21 \
        -in $base.fra19 -anchor center -expand 0 -fill none -padx 10 \
        -side right

    vTcl:prefs:init $base

    update idletasks
    wm deiconify $base
}

proc vTclWindow.vTcl.infolibs {{base ""} {container 0}} {

    if {$base == ""} {
        set base .vTcl.infolibs
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }

    global vTcl

    # let's keep widget local
    set widget(libraries_close)         "$base.but40"
    set widget(libraries_frame_listbox) "$base.cpd39"
    set widget(libraries_header)        "$base.lab38"
    set widget(libraries_listbox)       "$base.cpd39.01"

    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm geometry $base 446x322
    vTcl:center $base 446 322
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Visual Tcl Libraries"
    }
    label $base.lab38 \
        -borderwidth 1 -text {The following libraries are available:}
    frame $base.cpd39 \
        -borderwidth 1 -height 30 -relief raised -width 30
    listbox $base.cpd39.01 \
        -width 0 -xscrollcommand "$base.cpd39.02 set" \
        -yscrollcommand "$base.cpd39.03 set"
    scrollbar $base.cpd39.02 \
        -command "$base.cpd39.01 xview" -orient horiz
    scrollbar $base.cpd39.03 \
        -command "$base.cpd39.01 yview" -orient vert
    button $base.but40 \
        -padx 9 -pady 3 -text Close -command {wm withdraw .vTcl.infolibs}
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.lab38 \
        -in $base -anchor center -expand 0 -fill x -ipadx 1 -side top
    pack $base.cpd39 \
        -in $base -anchor center -expand 1 -fill both -side top
    grid columnconf $base.cpd39 0 -weight 1
    grid rowconf $base.cpd39 0 -weight 1
    grid $base.cpd39.01 \
        -in $base.cpd39 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw
    grid $base.cpd39.02 \
        -in $base.cpd39 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew
    grid $base.cpd39.03 \
        -in $base.cpd39 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns
    pack $base.but40 \
        -in $base -anchor center -expand 0 -fill x -side top

    $widget(libraries_listbox) delete 0 end

    foreach name $vTcl(libNames) {
        $widget(libraries_listbox) insert end $name
    }
}

proc {vTcl:prefs:data_exchange} {save_and_validate} {

	global widget

	# if save_and_validate is set to 0, values are transferred from
	# the preferences to the dialog (this is typically done when
	# initializing the dialog)

	# if save_and_validate is set to 1, values are transferred from
	# the dialog to the preferences (this is typically done when
	# the user presses the OK button

	vTcl:data_exchange_var vTcl(pr,balloon)          \
		prefs::balloon          $save_and_validate
	vTcl:data_exchange_var vTcl(pr,getname)          \
		prefs::getname          $save_and_validate
	vTcl:data_exchange_var vTcl(pr,shortname)        \
		prefs::shortname        $save_and_validate
	vTcl:data_exchange_var vTcl(pr,fullcfg)          \
		prefs::fullcfg          $save_and_validate
	vTcl:data_exchange_var vTcl(pr,saveglob)         \
		prefs::saveglob         $save_and_validate
	vTcl:data_exchange_var vTcl(pr,winfocus)         \
		prefs::winfocus         $save_and_validate
	vTcl:data_exchange_var vTcl(pr,autoplace)        \
		prefs::autoplace        $save_and_validate
	vTcl:data_exchange_var vTcl(pr,autoloadcomp)     \
		prefs::autoloadcomp     $save_and_validate
	vTcl:data_exchange_var vTcl(pr,autoloadcompfile) \
		prefs::autoloadcompfile $save_and_validate
	vTcl:data_exchange_var vTcl(pr,font_dlg)         \
		prefs::font_dlg         $save_and_validate
	vTcl:data_exchange_var vTcl(pr,font_fixed)       \
		prefs::font_fixed       $save_and_validate
	vTcl:data_exchange_var vTcl(pr,manager)          \
		prefs::manager          $save_and_validate
	vTcl:data_exchange_var vTcl(pr,encase)           \
		prefs::encase           $save_and_validate
	vTcl:data_exchange_var vTcl(pr,projecttype)      \
		prefs::projecttype      $save_and_validate
	vTcl:data_exchange_var vTcl(pr,imageeditor)      \
		prefs::imageeditor      $save_and_validate
	vTcl:data_exchange_var vTcl(pr,saveimagesinline) \
		prefs::saveimagesinline $save_and_validate
	vTcl:data_exchange_var vTcl(pr,cmdalias)        \
		prefs::cmdalias        $save_and_validate
	vTcl:data_exchange_var vTcl(pr,autoalias)        \
		prefs::autoalias        $save_and_validate
	vTcl:data_exchange_var vTcl(pr,multiplace)        \
		prefs::multiplace        $save_and_validate
}

proc {vTcl:prefs:basics} {tab} {

	vTcl:formCompound:add $tab checkbutton \
		-text "Use balloon help" \
		-variable prefs::balloon
	vTcl:formCompound:add $tab checkbutton \
		-text "Ask for widget name on insert" \
		-variable prefs::getname
	vTcl:formCompound:add $tab checkbutton \
		-text "Short automatic widget names" \
		-variable prefs::shortname
	vTcl:formCompound:add $tab checkbutton \
		-text "Save verbose widget configuration" \
		-variable prefs::fullcfg
	vTcl:formCompound:add $tab checkbutton \
		-text "Save global variable values" \
		-variable prefs::saveglob
	vTcl:formCompound:add $tab checkbutton \
		-text "Window focus selects window" \
		-variable prefs::winfocus
	vTcl:formCompound:add $tab checkbutton \
		-text "Auto place new widgets" \
		-variable prefs::autoplace
	vTcl:formCompound:add $tab checkbutton \
		-text "Use widget command aliasing" \
		-variable prefs::cmdalias
	vTcl:formCompound:add $tab checkbutton \
		-text "Use auto-aliasing for new widgets" \
		-variable prefs::autoalias
	vTcl:formCompound:add $tab checkbutton \
		-text "Use continuous widget placement" \
		-variable prefs::multiplace
	vTcl:formCompound:add $tab checkbutton \
		-text "Auto load compounds from file:" \
		-variable prefs::autoloadcomp

	set form_entry [vTcl:formCompound:add $tab frame]
	pack configure $form_entry -fill x

	set entry [vTcl:formCompound:add $form_entry entry \
		-textvariable prefs::autoloadcompfile]
	pack configure $entry -fill x -padx 5 -side left -expand 1

	set browse_file [vTcl:formCompound:add $form_entry button \
		-text "Browse..." \
		-command "vTcl:prefs:browse_file prefs::autoloadcompfile"]
	pack configure $browse_file -side right
}

proc {vTcl:prefs:browse_file} {varname} {

	global widget tk_strictMotif

	eval set value $$varname
	set types {
	    {{Tcl Files} *.tcl}
	    {{All Files} * }
	}

	set tk_strictMotif 0
	set newfile [tk_getOpenFile -filetypes $types -defaultextension .tcl]
	set tk_strictMotif 1

	if {$newfile != ""} {
	   set $varname $newfile
	}
}

proc {vTcl:prefs:browse_font} {varname feedback_window} {

	global widget

	eval set value $$varname
	set newfont [vTcl:font:prompt_user_font_2 $value]

	if {$newfont != ""} {

	    set $varname $newfont
	    $feedback_window configure -font $newfont
	}
}

proc {vTcl:prefs:fonts} {tab} {

	global widget

	set last  [vTcl:formCompound:add $tab  label \
		-text "Dialog font" -background gray -relief raised]
	pack configure $last -fill x

	set font_frame [vTcl:formCompound:add $tab frame]
	pack configure $font_frame -fill x
	set last [vTcl:formCompound:add $font_frame label \
		-text "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n0123456789" \
		-justify left -font $prefs::font_dlg]
	pack configure $last -side left
	set last [vTcl:formCompound:add $font_frame button \
		-text "Change..." \
		-command "vTcl:prefs:browse_font prefs::font_dlg $last"]
	pack configure $last -side right

	vTcl:formCompound:add $tab  label -text ""

	set last  [vTcl:formCompound:add $tab  label \
		-text "Fixed width font" -background gray -relief raised]
	pack configure $last -fill x

	set font_frame [vTcl:formCompound:add $tab frame]
	pack configure $font_frame -fill x
	set last [vTcl:formCompound:add $font_frame label \
		-text "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n0123456789" \
		-justify left -font $prefs::font_fixed]
	pack configure $last -side left
	set last [vTcl:formCompound:add $font_frame button \
		-text "Change..." \
		-command "vTcl:prefs:browse_font prefs::font_fixed $last"]
	pack configure $last -side right
}

proc {vTcl:prefs:images} {tab} {

	global widget

	vTcl:formCompound:add $tab label \
		-text "Editor for images"

	set form_entry [vTcl:formCompound:add $tab frame]
	pack configure $form_entry -fill x

	set last [vTcl:formCompound:add $form_entry entry  \
		-textvariable prefs::imageeditor]
	pack configure $last -fill x -expand 1 -padx 5 -side left

	set last [vTcl:formCompound:add $form_entry button \
		-text "Browse..." -command "vTcl:prefs:browse_file prefs::imageeditor"]
	pack configure $last -side right

	vTcl:formCompound:add $tab checkbutton \
		-text "Save images as inline" -variable prefs::saveimagesinline
}

proc {vTcl:prefs:project} {tab} {

	global widget

	set last  [vTcl:formCompound:add $tab  label \
		-text "Option encaps" -background gray -relief raised]
	pack configure $last -fill x
   
	vTcl:formCompound:add $tab radiobutton  \
		-text "List"   -variable prefs::encase -value list
	vTcl:formCompound:add $tab radiobutton  \
		-text "Braces" -variable prefs::encase -value brace
 	vTcl:formCompound:add $tab radiobutton  \
 		-text "Quotes" -variable prefs::encase -value quote

	#======================================================================

	set last  [vTcl:formCompound:add $tab  label \
		-text "Project type" -background gray -relief raised]
	pack configure $last -fill x

	vTcl:formCompound:add $tab radiobutton  \
		-text "Single file project" -variable prefs::projecttype -value single
	vTcl:formCompound:add $tab radiobutton  \
		-text "Multiple file project" -variable prefs::projecttype -value multiple

	#======================================================================

	set last  [vTcl:formCompound:add $tab  label \
		-text "Default manager" -background gray -relief raised]
	pack configure $last -fill x

	vTcl:formCompound:add $tab radiobutton  \
		-text "Grid" -variable prefs::manager -value grid
	vTcl:formCompound:add $tab radiobutton  \
		-text "Pack" -variable prefs::manager -value pack
	vTcl:formCompound:add $tab radiobutton  \
		-text "Place" -variable prefs::manager -value place
}
