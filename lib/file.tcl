##############################################################################
#
# file.tcl - procedures to open, close and save applications
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
# This file has been modified by:
#   Christian Gavin
#   Damon Courtney
#
##############################################################################

proc vTcl:new {} {
    global vTcl
    if { [vTcl:close] == -1 } { return }

    ## Run through the Project Wizard to setup the new project.
    Window show .vTcl.newProjectWizard

    tkwait variable ::NewWizard::Done

    set vTcl(mode) EDIT

    vTcl:setup_bind_tree .
    vTcl:update_top_list
    vTcl:update_proc_list

    if {[lempty $::NewWizard::ProjectFile]} {
	set vTcl(project,name) "unknown.tcl"
    } else {
    	set vTcl(project,name) \
	    [file join $::NewWizard::ProjectFolder $::NewWizard::ProjectFile]
	set vTcl(project,file) $vTcl(project,name)
    }

    wm title $vTcl(gui,main) "Visual Tcl - $vTcl(project,name)"

    set w [vTcl:auto_place_widget Toplevel]
    if {$w != ""} { wm geometry $w $vTcl(pr,geom_new) }
}

proc vTcl:file_source {} {
    set file [vTcl:get_file open "Source File"]
    if {$file != ""} {
        vTcl:source $file
        vTcl:update_proc_list
    }
}

proc vTcl:is_vtcl_prj {file} {
    global vTcl

    set fileID [open $file r]
    set contents [read $fileID]
    close $fileID

    set found 0
    set vmajor ""
    set vminor ""

    foreach line [split $contents \n] {
	if [regexp {# Visual Tcl v(.?)\.(.?.?) Project} $line \
	    matchAll vmajor vminor] {
	    set found 1
	}
    }

    if !$found {
	::vTcl::MessageBox -title "Error loading file" \
	              -message "This is not a vTcl project!" \
	              -icon error \
	              -type ok

	return 0
    }

    set versions [split $vTcl(version) .]
    set actual_major [lindex $versions 0]
    set actual_minor [lindex $versions 1]

    if {$vmajor != "" && $vminor != ""} {

    	if {$vmajor > $actual_major ||
    	    ($vmajor == $actual_major && $vminor > $actual_minor)} {
		::vTcl::MessageBox -title "Error loading file" \
		              -message "You are trying to load a project created using Visual Tcl v$vmajor.$vminor\n\nPlease update to vTcl $vmajor.$vminor and try again." \
	              -icon error \
	              -type ok

	        return 0
    	}
    }

    # all right, it's a vtcl project
    return 1
}

proc vTcl:source {file} {
    global vTcl
    set vTcl(sourcing) 1
    vTcl:statbar 15
    set op ""

    foreach context [vTcl:namespace_tree] {

        set cop [namespace eval $context {info procs}]

        foreach procname $cop {
            if {$context == "::"} {
               lappend op $procname
            } else {
               lappend op ${context}::$procname
            }
        }
    }

    vTcl:statbar 20
    if [catch {uplevel #0 [list source $file]} err] {
        ::vTcl::MessageBox -icon error -message "Error Sourcing Project\n$err" \
            -title "File Error!"
	global errorInfo
    }
    vTcl:statbar 35

    # kc: ignore global procs like "tixSelect"
    set np ""
    foreach context [vTcl:namespace_tree] {

        set cop [namespace eval $context {info procs}]

        foreach procname $cop {
            if {[vTcl:ignore_procname_when_sourcing $procname] == 0 &&
                [vTcl:ignore_procname_when_sourcing ${context}::$procname] == 0} {
               if {$context == "::"} {
                   lappend np $procname
               } else {
                   lappend np ${context}::$procname
               }
            }
       }
    }

    vTcl:list add [vTcl:diff_list $op $np] vTcl(procs)
    vTcl:statbar 45
    set vTcl(tops) [vTcl:find_new_tops];     vTcl:statbar 0
    set vTcl(sourcing) 0
}

proc vTcl:open {{file ""}} {
    global vTcl argc argv
    if { [vTcl:close] == -1 } { return }
    if {$file == ""} {
        set file [vTcl:get_file open "Open Project"]
    } else {
        if ![file exists $file] {return}
    }

    if {![info exists vTcl(rcFiles)]} { set vTcl(rcFiles) {} }

    if {[lempty $file]} { return }

    set vTcl(sourcing) 1

    # only open a Visual Tcl project and nothing else
    if ![vTcl:is_vtcl_prj $file] {return}
    
    vTcl:addRcFile $file

    set vTcl(file,mode) ""
    proc exit {args} {}
    proc init {argc argv} {}
    proc main {argc argv} {}
    vTcl:load_lib vtclib.tcl;            vTcl:statbar 10
    set vTcl(tops) ""
    set vTcl(vars) ""
    set vTcl(procs) ""
    vTcl:status "Loading Project"
    vTcl:source $file;                   vTcl:statbar 55

    # make sure the 'Window' procedure is the latest
    vTcl:load_lib vtclib.tcl;            vTcl:statbar 60

    vTcl:list add "init main" vTcl(procs)
    vTcl:status "Updating top list"
    vTcl:update_top_list;                vTcl:statbar 68
    vTcl:status "Updating proc list"
    vTcl:update_proc_list;               vTcl:statbar 75
    vTcl:status "Updating aliases"
    vTcl:update_aliases;                 vTcl:statbar 80

    vTcl:status "Loading Project Info";  vTcl:statbar 85

    set vTcl(project,file) $file
    set vTcl(project,name) [file tail $file]

    ## Determine if there is a multifile project file and source it.
    set basedir [file dir $file]
    set multidir [vTcl:dump:get_multifile_project_dir $vTcl(project,name)]
    set file [file root $vTcl(project,name)].vtp

    if {[file exists [file join $basedir $file]]} {
    	source [file join $basedir $file]
    } elseif {[file exists [file join $basedir $multidir $file]]} {
    	source [file join $basedir $multidir $file]
    }

    ## If there are project settings, load them
    if {![lempty [info proc vTcl:project:info]]} { vTcl:project:info }

    ## Setup the bind tree after we have loaded project info, so
    ## that registration of children in childsites works OK
    vTcl:status "Setting up bind tree"
    vTcl:setup_bind_tree .;              vTcl:statbar 90

    vTcl:status "Registering widgets"
    vTcl:widget:register_all_widgets;	 vTcl:statbar 97

    wm title .vTcl "Visual Tcl - $vTcl(project,name)"
    vTcl:status "Done Loading"
    vTcl:statbar 0
    set vTcl(newtops) [expr [llength $vTcl(tops)] + 1]

    ## convert older projects
    vTcl:convert_tops

    unset vTcl(sourcing)

    # @@change by Christian Gavin 3/5/2000
    # refresh widget tree automatically after File Open...
    # refresh image manager and font manager too

    after idle {
	    vTcl:init_wtree
	    vTcl:image:refresh_manager
	    vTcl:font:refresh_manager
    }

    # @@end_change
}

proc vTcl:close {} {
    global vTcl widgetNums
    if {$vTcl(change) > 0} {
        set result [::vTcl::MessageBox -default yes -icon question -message \
            "Your application has unsaved changes. Do you wish to save?" \
            -title "Save Changes?" -type yesnocancel]
        switch $result {
            yes {
                if {[vTcl:save_as] == -1} { return -1 }
            }
            cancel {
                return -1
            }
        }
    }

    set tops $vTcl(tops)
    foreach i $tops {
        if {$i != ".vTcl" && $i != ".__tk_filedialog"} {
            # list widget tree without including $i (it's why the "0" parameter)
            foreach child [vTcl:widget_tree $i 0] {
                vTcl:unset_alias $child
                vTcl:setup_unbind $child
            }
            vTcl:unset_alias $i
            destroy $i

            # this is clean up for leftover widget commands
            set _cmds [info commands $i.*]
            foreach _cmd $_cmds {catch {rename $_cmd ""}}
        }

        ## Destroy the widget namespace, as well as the namespaces of
        ## all it's subwidgets
        set namespaces [vTcl:namespace_tree ::widgets]
        foreach namespace $namespaces {
            if {[string match ::widgets::$i* $namespace]} {
                catch {namespace delete $namespace} error
            }
        }
    }

    set vTcl(tops) ""
    set vTcl(newtops) 1
    catch {unset widgetNums}
    vTcl:update_top_list
    foreach i $vTcl(vars) {
        # don't erase aliases, they should be erased when
        # closing the toplevels
        if {$i == "widget"} continue
        catch {global $i; unset $i}
    }
    set vTcl(vars) ""
    foreach i $vTcl(procs) {
        catch {rename $i {}}
    }
    proc exit {args} {}
    proc init {argc argv} {}
    proc main {argc argv} {}
    set vTcl(procs) "init main"
    vTcl:update_proc_list
    set vTcl(project,file) ""
    set vTcl(project,name) ""
    set vTcl(w,widget) ""
    set vTcl(w,save) ""
    wm title $vTcl(gui,main) "Visual Tcl"
    set vTcl(change) 0
    set vTcl(quit) 0

    # refresh widget tree automatically after File Close
    # delete user images (e.g. per project images)
    # delete user fonts (e.g. per project fonts)

    vTcl:image:remove_user_images
    vTcl:font:remove_user_fonts
    vTcl:prop:clear
    ::widgets_bindings::init
    ::menu_edit::close_all_editors

    after idle {vTcl:init_wtree}
}

proc vTcl:save {} {
    global vTcl
    set vTcl(save) all
    set vTcl(w,save) $vTcl(w,widget)
    if {$vTcl(project,file) == ""} {
        set file [vTcl:get_file save "Save Project"]
        vTcl:save2 $file
    } else {
        vTcl:save2 $vTcl(project,file)
    }
}

proc vTcl:save_as {} {
    global vTcl
    set vTcl(save) all
    set vTcl(w,save) $vTcl(w,widget)
    set file [vTcl:get_file save "Save Project"]
    vTcl:save2 $file
}

# @@change by Christian Gavin 3/27/00
# added support for freewrap to generate executables
# under Linux and Windows

proc vTcl:save_as_binary {} {
    global vTcl env tcl_platform

    set vTcl(save) all
    set vTcl(w,save) $vTcl(w,widget)
    set file [vTcl:get_file save "Save Project With Binary"]

    update

    vTcl:save2 $file

    if {[lempty $file]} { return }

    update

    vTcl:status "Creating binary..."

    # Now comes the magic.
    set filelist [file rootname $file].fwp

    set listID [open $filelist w]
    puts $listID [join [vTcl:image:get_files_list] \n]
    puts $listID [join [vTcl:dump:get_files_list \
                          [file dirname $file] \
                          [file rootname $file] ] \n]
    close $listID
    
    ##
    ## Guess the ostag and look for an appropriate freewrap binary.
    ##
    if {[string tolower $tcl_platform(platform)] == "windows"} {
	set freewrap [file join $env(VTCL_HOME) Freewrap Windows bin freewrap.exe]
    } else {
	set ostag [exec $env(VTCL_HOME)/Freewrap/config.guess]
	set freewrap [file join $env(VTCL_HOME) Freewrap $ostag bin freewrap]
    }

    exec $freewrap $file -f $filelist

    file delete -force $filelist

    vTcl:status "Binary Done"
}

# @@end_change

proc vTcl:save2 {file} {
    global vTcl env
    global tcl_platform

    if {$file == ""} {
        return -1
    }
    vTcl:destroy_handles
    vTcl:setup_bind_tree .

    set vTcl(project,name) [lindex [file split $file] end]
    set vTcl(project,file) $file
    wm title $vTcl(gui,main) "Visual Tcl - $vTcl(project,name)"
    if {[file exists $file] == 1} {
        file rename -force ${file} ${file}.bak
    }
    set output [open $file w]

    if {$vTcl(pr,saveasexecutable)} {
        puts $output "\#!/bin/sh"
        puts $output "\# the next line restarts using wish\\"
        puts $output {exec wish "$0" "$@" }
    }

    ## Gather information about the widgets.
    vTcl:dump:gather_widget_info

    ## Header to import libraries
    ## If any of the widgets use an external library, we need to dump the
    ## importheader for each library.  If all the widgets are core or don't
    ## use an external library, don't dump anything.
    if {![lempty $vTcl(dump,libraries)]} {
	## If we have any library other than the core libraries, invoke
	## a package name search in the headers.
	set namesearch 0
	foreach lib $vTcl(dump,libraries) {
	    if {[vTcl:streq $lib "core"] \
	    	|| [vTcl:streq $lib "vtcl"] \
		|| [vTcl:streq $lib "user"]} { continue }
	    set namesearch 1
	}

	vTcl:dump:not_sourcing_header out
	if {$namesearch} {
	    append out "\n$vTcl(tab)# Provoke name search\n"
	    append out "$vTcl(tab)catch {package require bogus-package-name}\n"
	    append out "$vTcl(tab)set packageNames \[package names\]\n"
	}
	foreach lib $vTcl(dump,libraries) {
	    if {![info exists vTcl(head,$lib,importheader)]} { continue }
	    append out $vTcl(head,$lib,importheader)
	}
	vTcl:dump:sourcing_footer out
	puts $output $out
    }

    ## Project header
    puts $output "[subst $vTcl(head,proj)]\n"

    ## Code to load images
    vTcl:image:generate_image_stock $output
    vTcl:image:generate_image_user  $output

    ## Code to load fonts
    vTcl:font:generate_font_stock   $output
    vTcl:font:generate_font_user    $output

    # moved init proc after user procs so that the init
    # proc can call any user proc

    if {$vTcl(save) == "all"} {
	puts $output $vTcl(head,exports)
	puts $output [vTcl:export_procs]
	puts $output [vTcl:dump:project_info \
	    [file dirname $file] $vTcl(project,name)]
        puts $output $vTcl(head,procs)
        puts $output [vTcl:save_procs]
        puts $output [vTcl:dump_proc init "Initialization "]
        puts $output "init \$argc \$argv\n"
        puts $output $vTcl(head,gui)
        puts $output [vTcl:save_tree . [file dirname $file] $vTcl(project,name)]
        puts $output "main \$argc \$argv"
    } else {
        puts $output [vTcl:save_tree $vTcl(w,widget)]
    }

    # @@end_change

    vTcl:addRcFile $file

    close $output
    vTcl:status "Done Saving"
    set vTcl(file,mode) ""
    if {$vTcl(w,save) != ""} {
        if {$vTcl(w,widget) != $vTcl(w,save)} {
            vTcl:active_widget $vTcl(w,save)
        }
        vTcl:create_handles $vTcl(w,save)
    }
    set vTcl(change) 0

    # @@change by Christian Gavin 3/5/2000
    #
    # it really annoyed me when I had to set the file as
    # executable under Linux to be able to run it, so here
    # we go

    if {$vTcl(pr,saveasexecutable) &&
        $tcl_platform(platform) == "unix"} {
    	    file attributes $file -permissions [expr 0755]
    }

    # @@end_change
}

proc vTcl:quit {} {
    global vTcl
    set vTcl(quit) 1

    ## If the project has changed, close it before exiting.
    if {$vTcl(change)} {
	if {[vTcl:close] == -1} { return }
    }

    if {[winfo exists .vTcl.tip]} {
       eval [wm protocol .vTcl.tip WM_DELETE_WINDOW]
    }
    vTcl:save_prefs
    vTcl:exit
}

proc vTcl:save_prefs {} {
    global vTcl

    set w $vTcl(gui,main)
    set pos [vTcl:get_win_position $w]
    set output "set vTcl(geometry,$w) $vTcl(pr,geom_vTcl)$pos\n"
    set showlist ""

    ## If the window exists but is not visible, we still want to save its
    ## geometry, just not add it to the showlist.
    foreach i $vTcl(windows) {
        if {[winfo exists $i]} {
	    append output "set vTcl(geometry,${i}) [wm geometry $i]\n"
	    if {[vTcl:streq [wm state $i] "normal"]} { lappend showlist $i }
        } else {
            catch {
                append output "set vTcl(geometry,${i}) $vTcl(geometry,${i})\n"
            }
        }
    }
    append output "set vTcl(gui,showlist) \"$showlist\"\n"
    foreach i [array names vTcl pr,*] {
        append output "set vTcl($i) [list $vTcl($i)]\n"
    }

    if {![info exists vTcl(rcFiles)]} { set vTcl(rcFiles) {} }
    append output "set vTcl(rcFiles) \[list $vTcl(rcFiles)\]\n"
    catch {
        set file [open $vTcl(CONF_FILE) w]
        puts $file $output
        close $file
    }
}

proc vTcl:find_files {base pattern} {
    global vTcl
    set dirs ""
    set match ""
    set files [lsort [glob -nocomplain [file join $base *]]]
    if {$pattern == ""} {set pattern "*"}
    foreach i $files {
        if {[file isdir $i]} {
            lappend dirs $i
        } elseif {[string match $pattern $i]} {
            lappend match $i
        }
    }
    return "$dirs $match"
}

proc vTcl:get_file {mode {title File} {ext .tcl}} {
    global vTcl tk_version tcl_platform tcl_version tk_strictMotif
    if {![info exists vTcl(pr,initialdir)]} {
        set vTcl(pr,initialdir) [pwd]
    }
    if {[string tolower $mode] == "open"} {
        set vTcl(file,mode) "Open"
    } else {
        set vTcl(file,mode) "Save"
    }
    set types { {{Tcl Files} {*.tcl}}
                {{All}       {*}} }
    set tk_strictMotif 0
    switch $mode {
        open {
            set file [tk_getOpenFile -defaultextension $ext \
                -initialdir $vTcl(pr,initialdir) -filetypes $types]
        }
        save {
            set initname [file tail $vTcl(project,file)]
            if {$initname == ""} {
                set initname "unknown.tcl"
            }
            if {$tcl_platform(platform) == "macintosh"} then {
                set file [tk_getSaveFile -defaultextension $ext \
                    -initialdir $vTcl(pr,initialdir) -initialfile $initname]
            } else {
                set file [tk_getSaveFile -defaultextension $ext \
                    -initialdir $vTcl(pr,initialdir) -filetypes $types \
                    -initialfile $initname]
            }
        }
    }
    set tk_strictMotif 1
    if {$file != ""} {
        set vTcl(pr,initialdir) [file dirname $file]
    }
    catch {cd [file dirname $file]}
    return $file
}

proc vTcl:restore {} {
    global vTcl

    set file $vTcl(project,file)

    if {[lempty $file]} { return }

    set bakFile $file.bak
    if {![file exists $bakFile]} { return }

    vTcl:close
    file copy -force -- $bakFile $file
    vTcl:open $file
}
