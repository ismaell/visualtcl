##############################################################################
#
# lib_blt.tcl - blt widget support library
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
#if {[info exist blt_library] == 1} {
#    global auto_path blt_library
#    lappend auto_path $blt_library
#    catch {
#        import add blt
#    }
#}

# Load up the blt library (Linux)
catch {load libBLT24.so}

# for Windoze
catch {load BLT24.dll}

proc vTcl:widget:lib:lib_blt {args} {
    global vTcl blt_library
    #
    # see if we're running bltWish. if not, return
    #
    if {[info exist blt_library] == 0} {
        return
    } else {
        global auto_path blt_library tcl_version
        lappend auto_path $blt_library
        if {$tcl_version < 8} {
            catch {
                import add blt
            }
        } else {
            catch {
                package require BLT
                import add blt
            }
            catch {
                namespace import blt::*
            }
        }
        
    }

    # setup required variables
    vTcl:lib_blt:setup

    # add items to toolbar
    foreach i {
        graph hierbox stripchart
    } {
        set img_file [file join $vTcl(VTCL_HOME) images icon_$i.gif]
        if {![file exists $img_file]} {
            set img_file [file join $vTcl(VTCL_HOME) images icon_tix_unknown.gif]
        }
        image create photo "ctl_$i" -file $img_file
        vTcl:toolbar_add $i $i ctl_$i ""
    }
    # The Widget Browser needs images for all blt classes.
    # The images need to be called, e.g. ctl_bltNoteBookFrame.
    # Don't put these in the toolbar, because they are not commands,
    # only classes.
}

proc vTcl:lib_blt:setup {} {
	global vTcl

	#
	# additional attributes to set on insert
	#
	set vTcl(graph,insert)       "-background white -plotrelief groove -foreground black"
	set vTcl(hierbox,insert)     ""
	set vTcl(stripchart,insert)  "-background white -plotrelief groove -foreground black"
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
		Graph Hierbox Stripchart

	#
	# register additional options that might be on Blt widgets,
	# and the option information that the Attribute Editor needs.
	#
	lappend vTcl(opt,list) \
		-closecommand \
		-closerelief \
		-dashes \
		-halo \
		-invertxy \
		-leftmargin \
		-opencommand \
		-openrelief \
	        -plotbackground \
	        -plotborderwidth \
		-plotpadx \
		-plotpady \
	        -plotrelief \
		-rightmargin \
		-topmargin \
		-tile \
	        -title 

	set vTcl(opt,-closecommand) { {Closecmd} longname command {} }
	set vTcl(opt,-closerelief) { {closerelief} longname choice {raised sunken} }
	set vTcl(opt,-dashes) { {dashes} longname type {} }
	set vTcl(opt,-halo) { {halo} longname type {} }
	set vTcl(opt,-invertxy) { {invertxy} longname type {} }
	set vTcl(opt,-justify) { {justify} longname choice {left right center} }
	set vTcl(opt,-leftmargin) { {LeftMar} longname type {} }
	set vTcl(opt,-opencommand) { {Opencmd} longname command {} }
	set vTcl(opt,-openrelief) { {openrelief} longname choice {raised sunken} }
	set vTcl(opt,-plotbackground) { {Plot BgColor}    Colors   color   {} }
	set vTcl(opt,-plotborderwidth) { {Plot Width}        longname type    {} }
	set vTcl(opt,-plotpadx) { {Plot PadX}		  longname type {} }
	set vTcl(opt,-plotpady) { {Plot PadY}		  longname type {} }
	set vTcl(opt,-plotrelief) { {Plot Relief} {}       choice  {flat groove raised ridge sunken} }
	set vTcl(opt,-rightmargin) { {RightMar} longname type {} }
	set vTcl(opt,-tile) { {tile} longname type {} }
	set vTcl(opt,-title)          { Title               longname type    {} }
	set vTcl(opt,-topmargin) { {TopMar} longname type {} }
	
	#
	# define dump procedures for widget types
	#
	set vTcl(Graph,dump_opt)         vTcl:lib_blt:dump_widget_opt
	set vTcl(Hierbox,dump_opt)       vTcl:lib_blt:dump_widget_opt
	set vTcl(Stripchart,dump_opt)       vTcl:lib_blt:dump_widget_opt

	#
	# define whether or not do dump children of a class
	#
	set vTcl(Graph,dump_children)         0
	set vTcl(Hierbox,dump_children)       0
	set vTcl(Stripchart,dump_children)       0
	
	# @@change by Christian Gavin 3/9/2000
	# commands to generate in header of a file when saving
	
	set vTcl(head,importheader) "$vTcl(head,importheader)
	        \# uncomment if your project uses BLT
		\# package require BLT
		\# namespace import blt::graph
		\# namespace import blt::hierbox"
	# @@end_change
}

#
# individual widget commands executed after insert
#
proc vTcl:widget:graph:inscmd {target} {
    return ""
}

#proc vTcl:widget:graph:dblclick {target} {
#    puts "IN graph:dblclick"
#}

#proc vTcl:widget:dump_graph {target basename} {
#    set results [vTcl:lib_blt:dump_widget_opt $target $basename]
#    puts "IN graph:dump_graph"
#    return $results
#}

#
# per-widget-class dump procedures
#

# Utility proc.  Ignore color options (-background, etc.) based on
# preference.
#
# returns:
#   1 means save the option
#   0 means don't save it
proc vTcl:lib_blt:save_option {opt} {
        return 1
}

# Utility proc.  Dump a blt widget.
# Differs from vTcl:dump_widget_opt in that it tries harder to avoid
# dumping options that shouldn't really be dumped, e.g. -fg,-bg,-font.
proc vTcl:lib_blt:dump_widget_opt {target basename} {
    global vTcl
    set result ""
    set class [vTcl:get_class $target]
    set result "$vTcl(tab)[vTcl:lower_first $class] $basename"
    set opt [$target configure]
    set keep_opt ""
    foreach e $opt {
        if [vTcl:lib_blt:save_option $e] {
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


