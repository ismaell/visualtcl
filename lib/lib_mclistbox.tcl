##############################################################################
#
# lib_mclistbox.tcl - multi column listbox support
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
    package require mclistbox 1.0
    namespace import ::mclistbox::mclistbox
}
   
proc vTcl:widget:lib:lib_mclistbox {args} {

    global vTcl
    
    # provoke name search
    catch {package require foobar}
    set names [package names]
                
    # check if available
    if { [lsearch -exact $names mclistbox] == -1} { 

        lappend vTcl(w,libsnames) {(not detected) Mclistbox Support Library}
	return
    }
  
    # setup required variables
    vTcl:lib_mclistbox:setup

    # add items to toolbar
    
    foreach i {
	mclistbox
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

    lappend vTcl(w,libsnames) {Mclistbox Support Library}
}

proc vTcl:lib_mclistbox:setup {} {

	global vTcl

	#
	# additional attributes to set on insert
	#
	set vTcl(mclistbox,insert)    ""

	#
	# add to procedure, var, bind regular expressions
	#
	#
	# add to valid class list
	#
	lappend vTcl(classes) Mclistbox

	# list of megawidgets whose children are not visible by Vtcl
	
	lappend vTcl(megaWidget) Mclistbox

	lappend vTcl(opt,list) -columnborderwidth \
                               -columnrelief \
                               -fillcolumn \
                               -labelanchor \
                               -labelbackground \
                               -labelborderwidth \
                               -labelforeground \
                               -labelheight \
                               -labelrelief \
                               -labels \
                               -resizablecolumns
                               
	set vTcl(opt,-columnborderwidth) { {Col Brdr Width}   {}  type     {} }
	set vTcl(opt,-columnrelief)      { {Col Relief}       {}  choice {sunken flat ridge 
	                                                                  solid groove} }
	set vTcl(opt,-fillcolumn)        { {Fill Col}         {}  type     {} }
	set vTcl(opt,-labelanchor)       { {Label Anchor}     {}  choice  {n ne e se s sw
	                                                                   w nw center} }
	set vTcl(opt,-labelbackground)   { {Label Bkgnd}      Colors color {} }
	set vTcl(opt,-labelborderwidth)  { {Label Brdr Width} {}  type     {} }
	set vTcl(opt,-labelforeground)   { {Label Foregnd}    Colors color {} }
	set vTcl(opt,-labelheight)       { {Label Height}     {}  type     {} }
	set vTcl(opt,-labelrelief)       { {Label Relief}     {}  choice {raised sunken flat
	                                                                  ridge solid groove} }
	set vTcl(opt,-labels)            { {Show Labels}      {}  boolean  {0 1} }
	set vTcl(opt,-resizablecolumns)  { {Resizable Cols}   {}  boolean  {0 1} }

	#
	# define dump procedures for widget types
	#
	set vTcl(Mclistbox,dump_opt)          vTcl:lib_mclistbox:dump_widget_opt

	#
	# define whether or not do dump children of a class
	#
	set vTcl(Mclistbox,dump_children)         0

	# header for project startup
	append vTcl(head,importheader) {

		# provoke name search
	        catch {package require foobar}
	        set names [package names]
                
	        # check if mclistbox is available
	        if { [lsearch -exact $names mclistbox] != -1} { 

		   package require mclistbox 1.0
		   namespace import ::mclistbox::mclistbox }
        }
	
	# procedure to return the label of a widget to display in the tree view
	
	set vTcl(Mclistbox,get_widget_tree_label)   \
	    vTcl:lib_mclistbox:get_widget_tree_label

	# translation of option values for Itcl widgets so that
	# fonts are correctly saved
}

proc vTcl:lib_mclistbox:get_widget_tree_label {className {target ""}} {
	
	return "Multicolumn List Box"
}

#
# individual widget commands executed after insert
#


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

proc vTcl:lib_mclistbox:save_option {opt} {
	
    return 1
}

# Utility proc.  Dump a itcl widget.
# Differs from vTcl:dump_widget_opt in that it tries harder to avoid
# dumping options that shouldn't really be dumped, e.g. -fg,-bg,-font.

proc vTcl:lib_mclistbox:dump_widget_opt {target basename} {

    global vTcl
    set result ""
    set class [vTcl:get_class $target]
    set result "$vTcl(tab)[vTcl:lower_first $class] $basename"
    set opt [$target configure]
    set keep_opt ""
    foreach e $opt {
        if [vTcl:lib_mclistbox:save_option $e] {
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
