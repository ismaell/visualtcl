##############################################################################
#
# lib_itcl.tcl - itcl widget support library
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
##############################################################################

# Architecture by Stewart Allen
# Implementation by James Kramer using ideas from
#   Kenneth H. Cox <kcox@senteinc.com>
#
# Maintained by Christian Gavin:
#   added support for more widgets
#   added support for new image/font managers
#   made sure children are not dumped and not viewed in the widget tree
#
#
# Initializes this library
#

proc vTcl:lib_itcl:init {} {
    global vTcl

    if {[catch {
        package require Itcl 3.0
        namespace import itcl::*
        package require Itk 3.0
        package require Iwidgets 3.0
        namespace import iwidgets::entryfield
        namespace import iwidgets::spinint
        namespace import iwidgets::combobox
        namespace import iwidgets::scrolledlistbox
        namespace import iwidgets::calendar
        namespace import iwidgets::dateentry
        namespace import iwidgets::scrolledhtml
        namespace import iwidgets::toolbar
        namespace import iwidgets::feedback
        namespace import iwidgets::optionmenu
        namespace import iwidgets::hierarchy
        namespace import iwidgets::buttonbox
        namespace import iwidgets::checkbox
        namespace import iwidgets::radiobox
        namespace import iwidgets::tabnotebook
        namespace import iwidgets::panedwindow
        namespace import iwidgets::scrolledtext
    } errorText]} {
        vTcl:log $errorText
        lappend vTcl(libNames) \
            {(not detected) Incr Tcl/Tk MegaWidgets Support Library}
        return 0
    }
    lappend vTcl(libNames) {Incr Tcl/Tk MegaWidgets Support Library}
    return 1
}

proc vTcl:widget:lib:lib_itcl {args} {
    global vTcl

    # Setup required variables
    vTcl:lib_itcl:setup

    append vTcl(head,importheader) {
        # Provoke name search
        catch {package require foobar}
        set names [package names]

        # Check if Itcl is available
        if {[lsearch -exact $names Itcl] != -1} {
            package require Itcl 3.0
            namespace import itcl::*
        }

        # Check if Itk is available
        if {[lsearch -exact $names Itk] != -1} {
            package require Itk 3.0
        }

        # Check if Iwidgets is available
        if {[lsearch -exact $names Iwidgets] != -1} {
            package require Iwidgets 3.0
            namespace import iwidgets::entryfield
            namespace import iwidgets::spinint
            namespace import iwidgets::combobox
            namespace import iwidgets::scrolledlistbox
            namespace import iwidgets::calendar
            namespace import iwidgets::dateentry
            namespace import iwidgets::scrolledhtml
            namespace import iwidgets::toolbar
            namespace import iwidgets::feedback
            namespace import iwidgets::optionmenu
            namespace import iwidgets::hierarchy
            namespace import iwidgets::buttonbox
            namespace import iwidgets::checkbox
            namespace import iwidgets::radiobox
            namespace import iwidgets::tabnotebook
            namespace import iwidgets::panedwindow
            namespace import iwidgets::scrolledtext

            switch {$tcl_platform(platform)} {
                windows {
                    option add *Scrolledhtml.sbWidth    16
                    option add *Scrolledtext.sbWidth    16
                    option add *Scrolledlistbox.sbWidth 16
                }
                default {
                    option add *Scrolledhtml.sbWidth    10
                    option add *Scrolledtext.sbWidth    10
                    option add *Scrolledlistbox.sbWidth 10
                }
            }
        }
    }

    set order {Entryfield Spinint Combobox Scrolledlistbox Calendar
               Dateentry Scrolledhtml Toolbar Feedback Optionmenu
               Hierarchy Buttonbox Checkbox Radiobox Tabnotebook
               Panedwindow Scrolledtext}

    vTcl:lib:add_widgets_to_toolbar $order

    append vTcl(proc,ignore) "|::iwidgets::.*"

    foreach cmd [string tolower $order] {
        append vTcl(proc,ignore) "|$cmd"
    }
}

proc vTcl:lib_itcl:setup {} {
    global vTcl

    #
    # additional attributes to set on insert
    #
    set vTcl(scrolledlistbox,insert)    "-labeltext {Label:} "
    set vTcl(combobox,insert)           "-labeltext {Label:} "
    set vTcl(entryfield,insert)         "-labeltext {Label:} "
    set vTcl(spinint,insert)            "-labeltext {Label:} -range {0 10} -step 1"
    set vTcl(calendar,insert)           ""
    set vTcl(dateentry,insert)	        "-labeltext {Selected date:}"
    set vTcl(scrolledhtml,insert)       ""
    set vTcl(toolbar,insert)            ""
    set vTcl(feedback,insert)           "-labeltext {Percent complete:}"
    set vTcl(optionmenu,insert)         "-labeltext {Select option:}"
    set vTcl(hierarchy,insert)          ""
    set vTcl(buttonbox,insert)          ""
    set vTcl(checkbox,insert)           ""
    set vTcl(radiobox,insert)           ""
    set vTcl(tabnotebook,insert)        ""
    set vTcl(panedwindow,insert)        ""
    set vTcl(scrolledtext,insert)       ""

    set vTcl(option,translate,-textfont) vTcl:font:translate
    set vTcl(option,noencase,-textfont) 1
    set vTcl(option,translate,-balloonfont) vTcl:font:translate
    set vTcl(option,noencase,-balloonfont) 1

    switch {$tcl_platform(platform)} {
        windows {
            option add *Scrolledhtml.sbWidth    16
            option add *Scrolledtext.sbWidth    16
            option add *Scrolledlistbox.sbWidth 16
        }
        default {
            option add *Scrolledhtml.sbWidth    10
            option add *Scrolledtext.sbWidth    10
            option add *Scrolledlistbox.sbWidth 10
        }
    }

    # hum... this is not too clean, but the hierarchy widget creates
    # icons on the fly
    #
    # in brief, the hierarchy widget does not know about the following images:
    #    openFolder
    #    closedFolder
    #    nodeFolder
    #
    # unless their respective options -openFolder,-closedFolder,-nodeFolder
    # haven't been specified while creating a hierarchy widget in which case
    # Iwidgets creates them
    #
    # this creates problems while sourcing a Iwidgets project in vTcl
    #
    # see save_option proc below for resolution
}

#
# individual widget commands executed after insert
#

proc vTcl:widget:toolbar:inscmd {target} {

    global env

    return "$target add button open \
        -balloonstr \"Open\" \
        -image [vTcl:image:get_image $env(VTCL_HOME)/images/edit/open.gif] \
        -command {tk_messageBox -message {TODO: Command handler here!}}"
}

proc vTcl:widget:optionmenu:inscmd {target} {

    return "$target insert 0 {Choice 1} {Choice 2} {Choice 3}"
}

proc vTcl:widget:buttonbox:inscmd {target} {

    return "$target add ok     -text OK ;\
            $target add cancel -text Cancel ;\
            $target add help   -text Help"
}

proc vTcl:widget:checkbox:inscmd {target} {

    return "$target add check1   -text {Check 1} ;\
            $target add check2   -text {Check 2} ;\
            $target add check3   -text {Check 3}"
}

proc vTcl:widget:radiobox:inscmd {target} {

    return "$target add radio1   -text {Radio 1} ;\
            $target add radio2   -text {Radio 2} ;\
            $target add radio3   -text {Radio 3}"
}

proc vTcl:widget:tabnotebook:inscmd {target} {

    return "$target add -label {Page 1} ;\
            $target add -label {Page 2} ;\
            $target add -label {Page 3} ;\
            $target select 0"
}

proc vTcl:widget:panedwindow:inscmd {target} {

    return "$target add pane1; $target add pane2"
}

proc vTcl:widget:combobox:inscmd {target} {

    return "$target insert list end {Item 1}; \
            $target insert list end {Item 2}; \
            $target insert list end {Item 3}"
}

# Utility proc.  Dump a megawidget's children, but not those that are
# part of the megawidget itself.  Differs from vTcl:dump:widgets in that
# it dumps the geometry of $subwidget, but it doesn't dump $subwidget
# itself (`vTcl:dump:widgets $subwidget' doesn't do the right thing if
# the grid geometry manager is used to manage children of $subwidget.
proc vTcl:lib_itcl:dump_subwidgets {subwidget} {
    global vTcl classes
    set output ""
    set widget_tree [vTcl:widget_tree $subwidget]

    foreach i $widget_tree {
        set basename [vTcl:base_name $i]

        # don't try to dump subwidget itself
        if {"$i" != "$subwidget"} {
            set class [vTcl:get_class $i]
            append output [$classes($class,dumpCmd) $i $basename]
            append output [vTcl:dump_widget_geom $i $basename]
        }
    }
    return $output
}
