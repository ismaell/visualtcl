##############################################################################
#
# lib_tix.tcl - tix widget support library
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
#
# Architecture by Stewart Allen
# Implementation by Kenneth H. Cox <kcox@senteinc.com>

#
# Initializes this library
#
proc vTcl:widget:lib:lib_tix {args} {
    global vTcl
    #
    # see if we're running tixWish. if not, return
    #
    if {[info command tixNoteBookFrame] == ""} {
        return
    }
	# setup required variables
	vTcl:lib_tix:setup
    # add items to toolbar
    foreach i {
        tixNoteBook tixLabelFrame tixComboBox tixMeter
        tixFileEntry tixLabelEntry tixScrolledHList
        tixScrolledListBox
        tixSelect
        tixPanedWindow tixOptionMenu
    } {
        set img_file [file join $vTcl(VTCL_HOME) images icon_$i.gif]
        if {![file exists $img_file]} {
            set img_file [file join $vTcl(VTCL_HOME) images icon_tix_unknown.gif]
        }
        image create photo "ctl_$i" -file $img_file
        vTcl:toolbar_add $i $i ctl_$i ""
    }
    # The Widget Browser needs images for all tix classes.
    # The images need to be called, e.g. ctl_tixNoteBookFrame.
    # Don't put these in the toolbar, because they are not commands,
    # only classes.
    foreach i {
        tixNoteBookFrame
    } {
        image create photo "ctl_$i" \
            -file [file join $vTcl(VTCL_HOME) images icon_tix_unknown.gif]
    }
    vTcl:lib_tix:unscrew_option_db
}

# Tix has screwed with the option database; reset it back to Tk's
# defaults.  Otherwise, all widgets will be saved with color/font
# (-foreground, -background, etc.) options specified.  Then we won't be
# able to globally override them in the generated app!
#
# A different approach to this problem would be:
#     1. add "don't save colors" and "don't save fonts" preferences
#     2. modify vTcl:dump_widget_opt so that it pays attention to them
#
# Took some of this code from tk's palette.tcl.
proc vTcl:lib_tix:unscrew_option_db {args} {
    checkbutton .c14732
    entry .e14732
    scrollbar .s14732
    text .t14732
    # this is order dependent (e.g. font should come before Text.font
    # and Entry.font) so use a list, not an array
    set l ""
    lappend l [list activeBackground \
            [lindex [.c14732 configure -activebackground] 3]]
    lappend l [list activeForeground \
            [lindex [.c14732 configure -activeforeground] 3]]
    lappend l [list background \
            [lindex [.c14732 configure -background] 3]]
    lappend l [list disabledForeground \
            [lindex [.c14732 configure -disabledforeground] 3]]
    lappend l [list font \
            [lindex [.c14732 configure -font] 3]]
    lappend l Entry.[list font \
            [lindex [.e14732 configure -font] 3]]
    lappend l Text.[list font \
            [lindex [.t14732 configure -font] 3]]
    lappend l [list foreground \
            [lindex [.c14732 configure -foreground] 3]]
    lappend l [list highlightBackground \
            [lindex [.c14732 configure -highlightbackground] 3]]
    lappend l [list highlightColor \
            [lindex [.c14732 configure -highlightcolor] 3]]
    lappend l [list insertBackground \
            [lindex [.e14732 configure -insertbackground] 3]]
    lappend l [list selectColor \
            [lindex [.c14732 configure -selectcolor] 3]]
    lappend l [list selectBackground \
            [lindex [.e14732 configure -selectbackground] 3]]
    lappend l [list selectForeground \
            [lindex [.e14732 configure -selectforeground] 3]]
    lappend l [list troughColor \
            [lindex [.s14732 configure -troughcolor] 3]]
    destroy .c14732 .e14732 .s14732 .t14732
    # this causes tix to reset its internal notion of the defaults
    tix resetoptions TK TK
    # this reinits the options database back to the defaults we just
    # queried, using the same priority level as tix used to screw us in
    # the first place.
    global tixOption
    foreach e $l {
        set option [lindex $e 0]
        set value  [lindex $e 1]
        #puts "option add *$option $value $tixOption(prioLevel)"
        option add *$option $value $tixOption(prioLevel)
    }

    # Prevent Tix from screwing us again (Tix calls "option add" when
    # creating new classes).
    if {[info procs vTcl:lib_tix:old_option] == ""} {
        #puts "ABOUT TO RENAME COMMANDS"
        rename option vTcl:lib_tix:old_option
        rename vTcl:lib_tix:new_option option
    }
}

# Now I'm _really_ going out of my way to undo the screwing up of the
# option DB that Tix does.  I rename the "option" command, and interpose
# my own vTcl:lib_tix:new_option which tones down the damage that Tix
# does by turning '*TixLabelFrame*Label.font' into
# '*TixLabelFrame.Label.font'
#
proc vTcl:lib_tix:new_option {cmd args} {
    #puts "lib_tix:new_option:$cmd $args:"
    if {"$cmd" != "add"} {
        return [eval vTcl:lib_tix:old_option $cmd $args]
    }
    #puts "\tit's an add"
    set pattern  [lindex $args 0]
    set value    [lindex $args 1]
    set priority [lindex $args 2]
    # if this is a Tix option, change all '*'s (except the first) with
    # '.'s otherwise they screw up everything!
    #puts "pattern:$pattern:"
    if {[string match {\*Tix*} $pattern]} {
        #puts "\twas: $pattern"
        regsub {(.)\*} $pattern {\1.} pattern
        #puts "\tis:  $pattern"
    }
    if {"$priority" == ""} {
        vTcl:lib_tix:old_option add $pattern $value
    } else {
        vTcl:lib_tix:old_option add $pattern $value $priority
    }
}

#
# move variable setup into proc so "sourcing" doesn't
# install them.
#
proc vTcl:lib_tix:setup {} {
	global vTcl

	#
	# Preferences
	set vTcl(tixPref,dump_colors) 0 ;# if 0, don't save -background, etc.

	#
	# additional attributes to set on insert
	#
	set vTcl(tixComboBox,insert)       ""
	set vTcl(tixFileEntry,insert)      "-label {FileEntry:} -options {label.anchor e}"
	set vTcl(tixLabelEntry,insert)     "-label {LabelEntry:} -options {label.anchor e}"
	set vTcl(tixLabelFrame,insert)     "-label label-me"
	set vTcl(tixMeter,insert)          ""
	set vTcl(tixNoteBook,insert)       ""
	set vTcl(tixOptionMenu,insert)     "-label {OptionMenu: } -options {label.anchor e}"
	set vTcl(tixPanedWindow,insert)    "-orient vertical"
	set vTcl(tixPopupMenu,insert)      "-title PopupMenu"
	set vTcl(tixScrolledHList,insert)  ""
	set vTcl(tixScrolledListBox,insert) ""
	set vTcl(tixSelect,insert)         "-radio 1"

	#
	# add to procedure, var, bind regular expressions
	#
	if {"$vTcl(bind,ignore)" != ""} {
		append vTcl(bind,ignore) "|tix"
	} else {
		append vTcl(bind,ignore) "tix"
	}
	append vTcl(proc,ignore) "|tix"
	append vTcl(var,ignore)  "|tix"

	#
	# add to valid class list
	#
	lappend vTcl(classes) \
		TixAppContext \
		TixBalloon \
		TixButtonBox \
		TixCObjView \
		TixCheckList \
		TixComboBox \
		TixControl \
		TixControl \
		TixDetailList \
		TixDialogShell \
		TixDirList \
		TixDirSelectBox \
		TixDirSelectDialog \
		TixDirTree \
		TixDragDropContext \
		TixExFileSelectBox \
		TixExFileSelectDialog \
		TixFileComboBox \
		TixFileEntry \
		TixFileSelectBox \
		TixFileSelectDialog \
		TixFloatEntry \
		TixHList \
		TixHListHeader \
		TixIconView \
		TixLabelEntry \
		TixLabelFrame \
		TixLabelWidget \
		TixListNoteBook \
		TixMeter \
		TixMultiView \
		TixNoteBook \
		TixNoteBookFrame \
		TixOptionMenu \
		TixPanedWindow \
		TixPopupMenu \
		TixPrimitive \
		TixResizeHandle \
		TixScrolledGrid \
		TixScrolledHList \
		TixScrolledListBox \
		TixScrolledTList \
		TixScrolledText \
		TixScrolledWidget \
		TixScrolledWindow \
		TixSelect \
		TixShell \
		TixSimpleDialog \
		TixStackWindow \
		TixStatusBar \
		TixStdButtonBox \
		TixStdDialogShell \
		TixTree \
		TixVResize \
		TixVStack \
		TixVTree

	#
	# register additional options that might be on Tix widgets,
	# and the option information that the Attribute Editor needs.
	#
	lappend vTcl(opt,list) \
			-activatecmd \
			-after \
			-before \
			-browsecmd \
			-buttons \
			-createcmd \
			-dynamicgeometry \
			-editable \
			-expand \
			-handleactivebg \
			-handlebg \
			-label \
			-listcmd \
			-listwidth \
			-max \
			-min \
			-options \
			-panebd \
			-panerelief \
			-postcmd \
			-raisecmd \
			-scrollbar \
			-separatoractivebg \
			-separatorbg \
			-size \
			-spring \
			-validatecmd
	# make sure the options appear sorted in the attribute editor
	#set vTcl(opt,list) [lsort $vTcl(opt,list)]
	set vTcl(opt,-activatecmd)     { {Activate Cmd}      longname command {} }
	set vTcl(opt,-after)           { {After}             longname type {} }
	set vTcl(opt,-allowzero)       { {Allow Zero}        longname choice  {1 0} }
	set vTcl(opt,-before)          { {Before}            longname type {} }
	set vTcl(opt,-browsecmd)       { {Browse Cmd}        longname command {} }
	set vTcl(opt,-buttons)         { {Buttons}           longname type    {} }
	set vTcl(opt,-createcmd)       { {Create Cmd}        longname command {} }
	set vTcl(opt,-dynamicgeometry) { {Dynamic Geometry}  longname choice  {1 0} }
	set vTcl(opt,-editable)        { Editable            longname choice  {0 1} }
	set vTcl(opt,-expand)          { {Expand}            longname type    {} }
	set vTcl(opt,-fancy)           { Fancy               longname choice  {0 1} }
	set vTcl(opt,-handleactivebg)  { {Handle ActiveBg}   longname type    {} }
	set vTcl(opt,-handlebg)        { {Handle BgColor}    longname type    {} }
	set vTcl(opt,-history)         { History             longname choice  {false true} }
	set vTcl(opt,-label)           { Label               longname type    {} }
	set vTcl(opt,-listcmd)         { {List Cmd}          longname command {} }
	set vTcl(opt,-listwidth)       { {List Width}        longname type    {} }
	set vTcl(opt,-max)             { {Maxsize}           longname type    {} }
	set vTcl(opt,-min)             { {Minsize}           longname type    {} }
	set vTcl(opt,-options)         { {Options}           longname type    {} }
	set vTcl(opt,-panebd)          { {Paneborder Width}  longname type    {} }
	set vTcl(opt,-panerelief)      { {Paneborder Relief} longname choice
		{sunken raised groove ridge flat} }
	set vTcl(opt,-postcmd)         { {Post Cmd}          longname command {} }
	set vTcl(opt,-prunehistory)    { {Prune History}     longname choice  {false true} }
	set vTcl(opt,-radio)           { Radio               longname choice  {0 1} }
	set vTcl(opt,-raisecmd)        { {Raise Cmd}         longname command {} }
	set vTcl(opt,-scrollbar)       { Scrollbar           longname choice  
		{auto both none x y} }
	set vTcl(opt,-separatoractivebg) { {Separator ActiveBg} longname type {} }
	set vTcl(opt,-separatorbg)     { {Separator BgColor} longname type    {} }
	set vTcl(opt,-size)            { {Size}              longname type    {} }
	set vTcl(opt,-spring)          { {Spring}            longname choice  {1 0} }
	set vTcl(opt,-validatecmd)     { {Validate Cmd}      longname command {} }

	#
	# define dump procedures for widget types
	#
	set vTcl(TixComboBox,dump_opt)         vTcl:lib_tix:dump_widget_opt
	set vTcl(TixFileEntry,dump_opt)        vTcl:dump:TixFileEntry
	set vTcl(TixLabelEntry,dump_opt)       vTcl:dump:TixLabelEntry
	set vTcl(TixLabelFrame,dump_opt)       vTcl:dump:TixLabelFrame
	set vTcl(TixMeter,dump_opt)            vTcl:lib_tix:dump_widget_opt
	set vTcl(TixNoteBook,dump_opt)         vTcl:dump:TixNoteBook
	set vTcl(TixOptionMenu,dump_opt)       vTcl:dump:TixOptionMenu
	set vTcl(TixPanedWindow,dump_opt)      vTcl:dump:TixPanedWindow
	set vTcl(TixPopupMenu,dump_opt)        vTcl:lib_tix:dump_widget_opt
	set vTcl(TixScrolledHList,dump_opt)    vTcl:lib_tix:dump_widget_opt
	set vTcl(TixScrolledListBox,dump_opt)  vTcl:lib_tix:dump_widget_opt
	set vTcl(TixSelect,dump_opt)           vTcl:dump:TixSelect

	#
	# define whether or not do dump children of a class
	#
	set vTcl(TixComboBox,dump_children)         0
	set vTcl(TixFileEntry,dump_children)        0
	set vTcl(TixLabelEntry,dump_children)       0
	set vTcl(TixLabelFrame,dump_children)       0
	set vTcl(TixMeter,dump_children)            0
	set vTcl(TixNoteBook,dump_children)         0
	set vTcl(TixOptionMenu,dump_children)       0
	set vTcl(TixPanedWindow,dump_children)      0
	set vTcl(TixPopupMenu,dump_children)        0
	set vTcl(TixScrolledHList,dump_children)    0
	set vTcl(TixScrolledListBox,dump_children)  0
	set vTcl(TixSelect,dump_children)           0
}

#
# individual widget commands executed after insert
#
proc vTcl:widget:tixNoteBook:inscmd {target} {
    # Add two pages to start with.  Unfortunately, additional pages have
    # to be added manually by the user, and the project re-read into vtcl.
    return "
        $target add page1 -label {Page 1};
        $target add page2 -label {Page 2};
        $target subwidget page1 configure -width 30 -height 30;
        $target subwidget page2 configure -width 30 -height 30;
    "
}

proc vTcl:widget:tixPanedWindow:inscmd {target} {
    # Add two pages to start with.  Unfortunately, additional pages have
    # to be added manually by the user, and the project re-read into vtcl.
    return "
        $target add page1
        $target add page2
        $target subwidget page1 configure -width 30 -height 30;
        $target subwidget page2 configure -width 30 -height 30;
    "
}

proc vTcl:widget:tixPopupMenu:inscmd {target} {
    return "
        $target bind \[winfo toplevel $target\]
        set menu \[$target subwidget menu\]
        \$menu add command -label Entry1
        \$menu add command -label Entry2
        \$menu add separator
        \$menu add command -label Entry2
    "
}

proc vTcl:widget:tixLabelFrame:inscmd {target} {
    return "
        $target subwidget frame configure -width 30 -height 30;
    "
}

proc vTcl:widget:tixMeter:inscmd {target} {
    return "$target configure -value .3"
}

proc vTcl:widget:tixFileEntry:inscmd {target} {
    return "
        $target subwidget frame configure -highlightthickness 2
    "
}

proc vTcl:widget:tixOptionMenu:inscmd {target} {
    # Add two options to start with.  Unfortunately, additional options have
    # to be added manually by the user, and the project re-read into vtcl.
    return "
        $target add command opt1 -label {Option 1}
        $target add separator sep
        $target add command opt2 -label {Option 2}
    "
}

proc vTcl:widget:tixSelect:inscmd {target} {
    # Add two buttons to start with.  Unfortunately, additional options have
    # to be added manually by the user, and the project re-read into vtcl.
    return "
        $target add but1 -bitmap warning
        $target add but2 -bitmap error
        $target add but3 -bitmap info
    "
}

#
# per-widget action to take upon edit-mode double-click
#
proc vTcl:widget:tixNoteBook:dblclick {target} {
    #puts "called edit-mode double-click on $target"
}

proc vTcl:widget:tixLabelFrame:dblclick {target} {
    #puts "called edit-mode double-click on $target"
}

proc vTcl:widget:tixComboBox:dblclick {target} {
    #puts "called edit-mode double-click on $target"
}

#
# per-widget-class dump procedures
#
proc vTcl:dump:TixNoteBook {target basename} {
    global vTcl
    set result [vTcl:lib_tix:dump_widget_opt $target $basename]
    set entries [$target pages]
    foreach page $entries {
        set conf [$target pageconfigure $page]
        set pairs [vTcl:conf_to_pairs $conf ""]
        append result "$vTcl(tab)$basename add $page \\\n"
        append result "[vTcl:clean_pairs $pairs]\n"
    }
    foreach page $entries {
        set subwidget [$target subwidget $page]
        append result [vTcl:lib_tix:dump_subwidgets $subwidget]
    }
    return $result
}

proc vTcl:dump:TixPanedWindow {target basename} {
    global vTcl
    set result [vTcl:lib_tix:dump_widget_opt $target $basename]
    set entries [$target panes]
    foreach page $entries {
        set conf [$target paneconfigure $page]
        foreach c $conf { # Filter the valid options out
            if [regexp -- {^-(after|allow|at|before|expand|max|min|size)} $c] {
                lappend validcfg $c
            }
        }
        set pairs [vTcl:conf_to_pairs $validcfg ""]
        append result "$vTcl(tab)$basename add $page \\\n"
        append result "[vTcl:clean_pairs $pairs]\n"
    }
    foreach page $entries {
        set subwidget [$target subwidget $page]
        append result [vTcl:lib_tix:dump_subwidgets $subwidget]
    }
    return $result
}

proc vTcl:dump:TixOptionMenu {target basename} {
    global vTcl
    set result [vTcl:lib_tix:dump_widget_opt $target $basename]
    set entries [$target entries]
    foreach entry $entries {
        set conf [$target entryconfigure $entry]
        set pairs [vTcl:conf_to_pairs $conf ""]
        append result "$vTcl(tab)$basename add "
        if {[llength $pairs] == 0} {
            append result "separator $entry\n"
        } else {
            set index [lsearch -glob $pairs -command*]
            if {$index > -1} {
                set pairs [lreplace $pairs $index [expr $index+1]]
            }
            append result "command $entry \\\n"
            append result "[vTcl:clean_pairs $pairs]\n"
        }
    }
    return $result
}

proc vTcl:dump:TixLabelFrame {target basename} {
    set output [vTcl:lib_tix:dump_widget_opt $target $basename]
    append output [vTcl:lib_tix:dump_subwidgets [$target subwidget frame]]
    return $output
}

proc vTcl:dump:TixLabelEntry {target basename} {
    global vTcl
    set output [vTcl:lib_tix:dump_widget_opt $target $basename]
    return $output
}

proc vTcl:dump:TixFileEntry {target basename} {
    global vTcl
    set output [vTcl:lib_tix:dump_widget_opt $target $basename]
    append output "$target subwidget frame configure -highlightthickness 2\n"
    return $output
}

proc vTcl:dump:TixSelect {target basename} {
    global vTcl
    set result [vTcl:lib_tix:dump_widget_opt $target $basename]
    foreach button [$target subwidgets -class Button] {
        set conf [list \
                [$button configure -bitmap] \
                [$button configure -image]]
        set pairs [vTcl:conf_to_pairs $conf ""]
        set button_name [string range $button \
                [expr 1 + [string last . $button]] end]
        append result "$vTcl(tab)$basename add $button_name \\\n"
        append result "[vTcl:clean_pairs $pairs]\n"
    }
    # Destroy unused label subwidget, but not while running in vTcl.
    if {"[$target cget -label]" == ""} {
        append result "$vTcl(tab)# destroy unused label subwidget\n"
        append result "$vTcl(tab)global vTcl\n"
        append result "$vTcl(tab)if \{!\[info exists vTcl\]\} \{destroy \[$basename subwidget label\]\}\n"
    }
    return $result
}

# Utility proc.  Dump a megawidget's children, but not those that are
# part of the megawidget itself.  Differs from vTcl:dump:widgets in that
# it dumps the geometry of $subwidget, but it doesn't dump $subwidget
# itself (`vTcl:dump:widgets $subwidget' doesn't do the right thing if
# the grid geometry manager is used to manage children of $subwidget.
proc vTcl:lib_tix:dump_subwidgets {subwidget} {
    global vTcl
    set output ""
    set widget_tree [vTcl:widget_tree $subwidget]
    foreach i $widget_tree {
        set basename [vTcl:base_name $i]
        # don't try to dump subwidget itself
        if {"$i" != "$subwidget"} {
            set class [vTcl:get_class $i]
            #puts "kc:dump_subwidgets1:[$vTcl($class,dump_opt) $i $basename]:"
            append output [$vTcl($class,dump_opt) $i $basename]
        }
        #puts "kc:dump_subwidgets2:[vTcl:dump_widget_geom $i $basename]:"
        append output [vTcl:dump_widget_geom $i $basename]
    }
    return $output
}

# Utility proc.  Ignore color options (-background, etc.) based on
# preference.
#
# returns:
#   1 means save the option
#   0 means don't save it
proc vTcl:lib_tix:save_option {opt} {
    global vTcl tix_library
    # never save -bitmap options on tix widgets; they are always
    # hard-coded to the tix library directory
    if [string match *${tix_library}* $opt] {
        #puts "kc:save_option:ignoring $opt"
        return 0
    } elseif {$vTcl(tixPref,dump_colors) == 0 \
            && [regexp -- {^-(.*background|.*foreground|.*color|font) } $opt]} {
        #puts "kc:save_option:ignoring $opt"
        return 0
    } else {
        return 1
    }
}

# Utility proc.  Dump a tix widget.
# Differs from vTcl:dump_widget_opt in that it tries harder to avoid
# dumping options that shouldn't really be dumped, e.g. -fg,-bg,-font.
proc vTcl:lib_tix:dump_widget_opt {target basename} {
    global vTcl
    set result ""
    set class [vTcl:get_class $target]
    set result "$vTcl(tab)[vTcl:lower_first $class] $basename"
    set opt [$target conf]
    set keep_opt ""
    foreach e $opt {
        if [vTcl:lib_tix:save_option $e] {
            lappend keep_opt $e
        }
    }
    set p [vTcl:get_opts $keep_opt]
    if {$p != ""} {
        append result " \\\n[vTcl:clean_pairs $p]\n"
    } else {
        append result "\n"
    }
    append result [vTcl:dump_widget_bind $target $basename]
    return $result
}

