##############################################################################
#
# lib_core.tcl - core tcl/tk widget support library
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
# initializes this library
#

proc vTcl:lib_bwidget:init {} {
    global vTcl

    if {[catch {package require BWidget}]} {
	lappend vTcl(libNames) "(not detected) BWidget Widget Support Library"
	return 0
    }
    lappend vTcl(libNames) "BWidget Widget Library"
    return 1
}

proc vTcl:widget:lib:lib_bwidget {args} {
    global vTcl

    ## These three widgets are commented out until we find a way
    ## to distinguish their creation command from Tk's. Otherwise,
    ## this breaks existing projects by saving widgets with create
    ## cmds such as "Entry" instead of "entry".
    #
    # Button
    # Entry
    # Label

    set order {
	ArrowButton
	LabelEntry
	LabelFrame
        ComboBox
	MainFrame
	NoteBook
	PagesManager
	ProgressBar
	ScrollView
	Separator
	TitleFrame
	Tree
    }

    vTcl:lib:add_widgets_to_toolbar $order

    append vTcl(head,bwidget,importheader) {
    if {[lsearch -exact $packageNames BWidget] > -1} {
	package require BWidget
    }
    }
}

namespace eval vTcl::widgets::bwidgets {

    proc update_pages {target var} {
        ## there is a trace on var to update the combobox
        ## first item in the list is the current index
        set sites [$target pages]
        set current [$target index [$target raise]]
        set num_pages [llength $sites]
        set values $current
        for {set i 0} {$i < $num_pages} {incr i} {
            set label_opt [$target itemconfigure [lindex $sites $i] -text]
            lappend values [lindex $label_opt 4]
        }

        ## this will trigger the trace
        set ::$var $values
    }

    proc config_pages {target var} {
    }

    proc get_pages {target} {
    }

    proc select_page {target index} {
        $target raise [$target pages $index]
    }

    ## Utility proc.  Dump a megawidget's children, but not those that are
    ## part of the megawidget itself.  Differs from vTcl:dump:widgets in that
    ## it dumps the geometry of $subwidget, but it doesn't dump $subwidget
    ## itself (`vTcl:dump:widgets $subwidget' doesn't do the right thing if
    ## the grid geometry manager is used to manage children of $subwidget.
    proc dump_subwidgets {subwidget {sitebasename {}}} {
        global vTcl basenames classes
        set output ""
        set geometry ""
        set widget_tree [vTcl:widget_tree $subwidget]
        set length      [string length $subwidget]
        set basenames($subwidget) $sitebasename

        foreach i $widget_tree {

            set basename [vTcl:base_name $i]

            # don't try to dump subwidget itself
            if {"$i" != "$subwidget"} {
                set basenames($i) $basename
                set class [vTcl:get_class $i]
                append output [$classes($class,dumpCmd) $i $basename]
                append geometry [vTcl:dump_widget_geom $i $basename]
                unset basenames($i)
            }
        }
        append output $geometry

        unset basenames($subwidget)
        return $output
    }
}
