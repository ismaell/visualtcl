##############################################################################
#
# lib_combobox.tcl - ComboBox support
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
#
# Architecture by Stewart Allen
# Implementation by Christian Gavin
#
# Initializes this library
#
 
catch {
    package require combobox 2.0
    namespace import ::combobox::combobox
}
   
proc vTcl:widget:lib:lib_tcombobox {args} {

    global vTcl
    
    # provoke name search
    catch {package require foobar}
    set names [package names]
                
    # check if available
    if { [lsearch -exact $names combobox] == -1} { 

        lappend vTcl(w,libsnames) {(not detected) Combobox Support Library}
	return
    }
  
    # setup required variables
    vTcl:lib_combobox:setup

    # add items to toolbar
    
    foreach i {
	combobox
    } {
        set img_file [file join $vTcl(VTCL_HOME) images icon_$i.gif]
        if {![file exists $img_file]} {
            set img_file [file join $vTcl(VTCL_HOME) images unknown.gif]
        }
        image create photo "ctl_$i" -file $img_file
        vTcl:toolbar_add $i $i ctl_$i ""

	append vTcl(proc,ignore) "|$i"
    }

    # The Widget Browser needs images for all itcl classes.
    # The images need to be called, e.g. ctl_itclNoteBookFrame.
    # Don't put these in the toolbar, because they are not commands,
    # only classes.

    lappend vTcl(w,libsnames) {Combobox Support Library}
}

proc vTcl:lib_combobox:setup {} {

	global vTcl

	#
	# additional attributes to set on insert
	#
	set vTcl(combobox,insert)    ""

	#
	# add to procedure, var, bind regular expressions
	#
	#
	# add to valid class list
	#
	lappend vTcl(classes) Combobox

	# list of megawidgets whose children are not visible by Vtcl
	
	lappend vTcl(megaWidget) Combobox

	lappend vTcl(opt,list) -commandstate \
                               -maxheight
                               
	set vTcl(opt,-commandstate)    { {Command State}    {}  choice {normal disabled} }
	set vTcl(opt,-maxheight)       { {Max Height}       {}  type   {} }

	#
	# define dump procedures for widget types
	#
	set vTcl(Combobox,dump_opt)          vTcl:lib_combobox:dump_widget_opt

	#
	# define whether or not do dump children of a class
	#
	set vTcl(Combobox,dump_children)         0

	# header for project startup
	append vTcl(head,importheader) {

		# provoke name search
	        catch {package require foobar}
	        set names [package names]
                
	        # check if combobox is available
	        if { [lsearch -exact $names combobox] != -1} { 

		   package require combobox 2.0
		   namespace import ::combobox::combobox }
        }
	
	# procedure to return the label of a widget to display in the tree view
	
	set vTcl(Combobox,get_widget_tree_label)   \
	    vTcl:lib_combobox:get_widget_tree_label

	# translation of option values for Itcl widgets so that
	# fonts are correctly saved
}

proc vTcl:lib_combobox:get_widget_tree_label {className {target ""}} {
	
	return "Combo Box"
}

#
# individual widget commands executed after insert
#

proc vTcl:widget:combobox:inscmd {target} {
	
	return "$target configure -value {}"
}

#
# per-widget-class dump procedures
#
#
# Utility proc.  Ignore color options (-background, etc.) based on
# preference.
#
# returns:
#   1 means save the option
#   0 means don't save it

proc vTcl:lib_combobox:save_option {opt} {
	
    return 1
}

# Utility proc.  Dump a itcl widget.
# Differs from vTcl:dump_widget_opt in that it tries harder to avoid
# dumping options that shouldn't really be dumped, e.g. -fg,-bg,-font.

proc vTcl:lib_combobox:dump_widget_opt {target basename} {

    global vTcl
    set result ""
    set class [vTcl:get_class $target]
    set result "$vTcl(tab)[vTcl:lower_first $class] $basename"
    set opt [$target configure]
    set keep_opt ""
    foreach e $opt {
        if [vTcl:lib_combobox:save_option $e] {
            lappend keep_opt $e
        }
    }
    set p [vTcl:get_opts_special $keep_opt $target]
    if {$p != ""} {
        append result " \\\n[vTcl:clean_pairs $p]\n"
    } else {
        append result "\n"
    }
    append result [vTcl:dump_widget_bind $target $basename]
    return $result
}
