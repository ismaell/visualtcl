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

    catch {package require Tix}

    ## See if we have Tix. If not, return
    if {[info command tixNoteBookFrame] == ""} {
        lappend vTcl(w,libsnames) {(not detected) Tix Widget Support Library}
        return
    }

    # Setup required variables
    vTcl:lib_tix:setup

    set order {
    	tixNoteBook
	tixLabelFrame
	tixComboBox
	tixMeter
	tixFileEntry
	tixLabelEntry
	tixScrolledHList
	tixScrolledListBox
	tixSelect
	tixPanedWindow
	tixOptionMenu
    }

    vTcl:lib:add_widgets_to_toolbar $order

    vTcl:lib_tix:unscrew_option_db

    lappend vTcl(libNames) {Tix Widget Support Library}
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

    ## Preferences
    set vTcl(tixPref,dump_colors) 0 ;# if 0, don't save -background, etc.

    ## Add to procedure, var, bind regular expressions
    if {[lempty $vTcl(bind,ignore)]} {
	append vTcl(bind,ignore) "tix"
    } else {
	append vTcl(bind,ignore) "|tix"
    }

    append vTcl(proc,ignore) "|tix"
    append vTcl(var,ignore)  "|tix"
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
