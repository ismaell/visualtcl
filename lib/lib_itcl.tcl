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
# Architecture by Stewart Allen
# Implementation by James Kramer usinge ideas from
# Kenneth H. Cox <kcox@senteinc.com>

#
# Initializes this library
#

proc vTcl:widget:lib:lib_itcl {args} {
    global vTcl
    #
    # see if we're running itclWish. if not, return
    #
    if {[catch {class itcltest { constructor {args} {}}}]} {
        return
    }

    # setup required variables
    vTcl:lib_itcl:setup

    # add items to toolbar
    foreach i {
        entryfield spinint combobox
    } {
        set img_file [file join $vTcl(VTCL_HOME) images icon_$i.gif]
        if {![file exists $img_file]} {
            set img_file [file join $vTcl(VTCL_HOME) images icon_tix_unknown.gif]
        }
        image create photo "ctl_$i" -file $img_file
        vTcl:toolbar_add $i $i ctl_$i ""
    }
    # The Widget Browser needs images for all itcl classes.
    # The images need to be called, e.g. ctl_itclNoteBookFrame.
    # Don't put these in the toolbar, because they are not commands,
    # only classes.
}

proc vTcl:lib_itcl:setup {} {
	global vTcl

	#
	# additional attributes to set on insert
	#
	set vTcl(scrolledlistbox,insert)       "-labeltext {Label:} "
	set vTcl(combobox,insert)       "-labeltext {Label:} "
	set vTcl(entryfield,insert)       "-labeltext {Label:} "
	set vTcl(spinint,insert)       "-labeltext {Label:} -range {0 10} -step 1"

	#
	# add to procedure, var, bind regular expressions
	#
#	if {"$vTcl(bind,ignore)" != ""} {
#		append vTcl(bind,ignore) "|tix"
#	} else {
#		append vTcl(bind,ignore) "tix"
#	}
#	append vTcl(proc,ignore) "|tix"
#	append vTcl(var,ignore)  "|tix"
        append vTcl(top,ignore,post) ".*shell\\.lwchildsite\\.efchildsite\\.popup"

	lappend vTcl(NoXResizeClasses) Combobox Spinint Entryfield
	#
	# add to valid class list
	#
	lappend vTcl(classes) \
		Entryfield \
		Spinint \
		Combobox \
                Scrolledlistbox

	lappend vTcl(multclasses) \
		Entryfield \
		Spinint \
		Combobox \
                Scrolledlistbox

        lappend vTcl(Combobox,nosubwidget) \
                shell \
                shell.label \
                shell.lwchildsite \
                shell.lwchildsite.entry \
                shell.lwchildsite.efchildsite \
                shell.lwchildsite.efchildsite.arrowBtn

        lappend vTcl(Entryfield,nosubwidget) \
                shell \
                shell.label \
                shell.labelmargin \
                shell.lwchildsite \
                shell.lwchildsite.entry

        lappend vTcl(Spinint,nosubwidget) \
                shell \
                shell.label \
                shell.lwchildsite \
                shell.lwchildsite.entry \
                shell.lwchildsite.efchildsite \
                shell.lwchildsite.efchildsite.arrowFrame \
                shell.lwchildsite.efchildsite.arrowFrame.uparrow \
                shell.lwchildsite.efchildsite.arrowFrame.downarrow        
	#
	# register additional options that might be on itcl widgets,
	# and the option information that the Attribute Editor needs.
	#
	lappend vTcl(opt,list) \
	        -fixed \
	        -range \
	        -step \
	        -validate \
	        -labeltext \
	        -labelpos \
	        -labelfont \
	        -textfont \
	        -items \
	        -decrement \
	        -increment \
	        -listheight

#	set vTcl(opt,-plotbackground) { {Plot BgColor}    Colors   color   {} }
	set vTcl(opt,-labelfont) { {Label Font}        {}       type    {} }
	set vTcl(opt,-textfont) { {Text Font}        {}       type    {} }
	set vTcl(opt,-labelpos) { {Label Pos}          {}       choice  {n ne e se s sw w nw center} }
	set vTcl(opt,-fixed) { {Fixed}        longname type    {} }
	set vTcl(opt,-validate)      { {Validate Cmd}          {}       command {}}
	set vTcl(opt,-decrement)      { {Decrement Cmd}          {}       command {}}
	set vTcl(opt,-increment)      { {Increment Cmd}          {}       command {}}
	set vTcl(opt,-labeltext)      { Label               longname type    {} }
	set vTcl(opt,-range)      { Range               longname type    {} }
	set vTcl(opt,-items)      { Items               {}  command  {} }
#	set vTcl(opt,-items)      { Items               longname type    {} }
	set vTcl(opt,-step)      { Step               longname type    {} }
	set vTcl(opt,-listheight)    { "List Height"         longname type    {} }
	
	#
	# define dump procedures for widget types
	#
	set vTcl(Entryfield,dump_opt)         vTcl:lib_itcl:dump_widget_opt
	set vTcl(Spinint,dump_opt)         vTcl:lib_itcl:dump_widget_opt
	set vTcl(Combobox,dump_opt)         vTcl:lib_itcl:dump_combobox
	set vTcl(Scrolledlistbox,dump_opt)             vTcl:lib_itcl:dump_widget_opt

	#
	# define whether or not do dump children of a class
	#
	set vTcl(Entryfield,dump_children)         0
	set vTcl(Spinint,dump_children)         0
	set vTcl(Combobox,dump_children)         0
	set vTcl(Scrolledlistbox,dump_children)         0
}

#
# individual widget commands executed after insert
#
proc vTcl:widget:graph:inscmd {target} {
    return ""
}

#
# per-widget-class dump procedures
#

# Utility proc.  Ignore color options (-background, etc.) based on
# preference.
#
# returns:
#   1 means save the option
#   0 means don't save it
proc vTcl:lib_itcl:save_option {opt} {
    if [string match *::iwidgets* $opt] {
        return 0
    }
#    puts "save_option '$opt'"
    return 1
}

# Utility proc.  Dump a itcl widget.
# Differs from vTcl:dump_widget_opt in that it tries harder to avoid
# dumping options that shouldn't really be dumped, e.g. -fg,-bg,-font.
proc vTcl:lib_itcl:dump_widget_opt {target basename} {
    global vTcl
    set result ""
    set class [vTcl:get_class $target]
    set result "$vTcl(tab)[vTcl:lower_first $class] $basename"
    set opt [$target configure]
    set keep_opt ""
    foreach e $opt {
        if [vTcl:lib_itcl:save_option $e] {
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

# Utility proc.  Dump a itcl widget.
# Differs from vTcl:dump_widget_opt in that it tries harder to avoid
# dumping options that shouldn't really be dumped, e.g. -fg,-bg,-font.
proc vTcl:lib_itcl:dump_combobox {target basename} {
    global vTcl
    $target configure -editable 1
    set result [vTcl:lib_itcl:dump_widget_opt $target $basename]
    $target configure -editable 0
    return $result
}




