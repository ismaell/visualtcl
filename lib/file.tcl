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

proc vTcl:new {} {
    global vTcl
    if { [vTcl:close] == -1 } { return }

    set vTcl(mode) EDIT

    set w [vTcl:auto_place_widget toplevel]
    wm geometry $w $vTcl(pr,geom_new)

    vTcl:setup_bind_tree .
    vTcl:update_top_list
    vTcl:update_var_list
    vTcl:update_proc_list
    set vTcl(project,name) "unknown.tcl"
    wm title $vTcl(gui,main) "Visual Tcl - $vTcl(project,name)"
    proc main {argc argv} "
    	wm protocol $vTcl(w,insert) WM_DELETE_WINDOW {exit}

    "
}

proc vTcl:file_source {} {
    set file [vTcl:get_file open "Source File"]
    if {$file != ""} {
        vTcl:source $file
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
	    set version $vmajor.$vminor
	}
    }

    if !$found {
	tk_messageBox -title "Error loading file" \
	              -message "This is not a vTcl project!" \
	              -icon error \
	              -type ok

	return 0
    }

    if {$vmajor != "" && $vminor != ""} {
	# if {$version > $vTcl(version)} { }
    	if {$vmajor > 1 ||
    	    ($vmajor == 1 && $vminor > 40)} {
		tk_messageBox -title "Error loading file" \
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
    set ov [uplevel #0 info vars];           vTcl:statbar 15
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
        vTcl:dialog "Error Sourcing Project\n$err"
	global errorInfo
    }
    vTcl:statbar 35

    # kc: ignore global vars like "tixSelect";
    # otherwise File->Close breaks tix widgets.
    set nv ""
    foreach varname [uplevel #0 info vars] {
        if {[vTcl:valid_varname $varname] == 1} {
            lappend nv $varname
        }
    }
    # kc: ignore global procs like "tixSelect"
    set np ""
    foreach context [vTcl:namespace_tree] {

        set cop [namespace eval $context {info procs}]

        foreach procname $cop {
            if {[vTcl:ignore_procname_when_sourcing $procname] == 0} {
               if {$context == "::"} {
                   lappend np $procname
               } else {
                   lappend np ${context}::$procname
               }
            }
       }
    }

    vTcl:list add [vTcl:diff_list $ov $nv] vTcl(vars)
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
    vTcl:status "Setting up bind tree"
    vTcl:setup_bind_tree .;              vTcl:statbar 65
    vTcl:status "Updating top list"
    vTcl:update_top_list;                vTcl:statbar 75
    vTcl:status "Updating variable list"
    vTcl:update_var_list;                vTcl:statbar 85
    vTcl:status "Updating proc list"
    vTcl:update_proc_list;               vTcl:statbar 95
    vTcl:status "Updating aliases"
    vTcl:update_aliases
    set vTcl(project,file) $file
    set vTcl(project,name) [lindex [file split $file] end]
    wm title .vTcl "Visual Tcl - $vTcl(project,name)"
    vTcl:status "Done Loading"
    vTcl:statbar 0
    set vTcl(newtops) [expr [llength $vTcl(tops)] + 1]

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
        switch [vTcl:dialog "Your application has unsaved changes.\nDo you wish to save?" "Yes No Cancel"] {
            Yes {
                if {[vTcl:save_as] == -1} {
                    return -1
                }
            }
            Cancel {
                return -1
            }
        }
    }

    # @@change by Christian Gavin 5/2/2000
    #
    # deletes all iTcl objects that are not destroyed by the
    # destroy command (they should be deleted, but seemingly
    # vTcl is modifying bindings)
    #
    # lsort is used so that higher level objects are destroyed
    # first, for example a tabnotebook has contained objects so
    # if the tabnotebook is deleted first then all its subobjects
    # will be deleted automatically; however if we delete the
    # contained objects first, deleting the container will result
    # in an error message
    #
    # this applies to objects named after widgets

    catch {
    	set obj_list [itcl::find objects .*]
    	set obj_list [lsort $obj_list]

    	while {[llength $obj_list] > 0} {

    		set obj [lindex $obj_list 0]
    		itcl::delete object $obj
	    	set obj_list [itcl::find objects .*]
	    	set obj_list [lsort $obj_list]
    	}
    }

    # @@end_change

    set tops [winfo children .]
    foreach i $tops {
        if {$i != ".vTcl" && $i != ".__tk_filedialog"} {destroy $i}
    }
    set vTcl(tops) ""
    set vTcl(newtops) 1
    catch {unset widgetNums}
    vTcl:update_top_list
    foreach i $vTcl(vars) {
        catch {global $i; unset $i}
    }
    set vTcl(vars) ""
    vTcl:update_var_list
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

    # @@change by Christian Gavin 3/5/2000
    # refresh widget tree automatically after File Close
    # delete user images (e.g. per project images)
    # delete user fonts (e.g. per project fonts)

    vTcl:image:remove_user_images
    vTcl:font:remove_user_fonts
    vTcl:prop:clear

    after idle {vTcl:init_wtree}

    # @@end_change
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

    vTcl:save2 $file

    if {[lempty $file]} { return }

    # now comes the magic
    set filelist [file rootname $file].txt

    set listID [open $filelist w]
    puts $listID [join [vTcl:image:get_files_list] \n]
    puts $listID [join [vTcl:dump:get_files_list \
                          [file dirname $file] \
                          [file rootname $file] ] \n]
    close $listID
    
    ##
    # Guess the ostag and look for an appropriate freewrap binary.
    ##
    if {[string tolower $tcl_platform(platform)] == "windows"} {
    	set ostag Windows
    } else {
	set ostag [exec $env(VTCL_HOME)/Freewrap/config.guess]
    }

    # launches freewrap
    set freewrap $env(VTCL_HOME)/Freewrap/$ostag/bin/freewrap
    
    exec $freewrap $file -f $filelist
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

    puts $output "\#!/bin/sh"
    puts $output "\# the next line restarts using wish\\"
    puts $output {exec wish "$0" "$@" }

    # header to import libraries
    # code to load images
    # code to load fonts

    puts $output "if {!\[info exist vTcl(sourcing)\]} \{"
    puts $output $vTcl(head,importheader)
    puts $output "\}"

    vTcl:image:generate_image_stock $output
    vTcl:image:generate_image_user  $output
    vTcl:font:generate_font_stock   $output
    vTcl:font:generate_font_user    $output

    # @@end_change
    puts $output "[subst $vTcl(head,proj)]\n"

    # @@change by Christian Gavin
    # moved init proc after user procs so that the init
    # proc can call any user proc

    if {$vTcl(save) == "all"} {
        set body [string trim [info body init]]
	puts $output $vTcl(head,exports)
	puts $output [vTcl:vtcl_library_procs]
	puts $output [vTcl:export_procs]
        puts $output $vTcl(head,procs)
        puts $output [vTcl:save_procs]
        puts $output "proc init \{argc argv\} \{\n$body\n\}\n"
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

    if {$tcl_platform(platform) == "unix"} {
    	    file attributes $file -permissions [expr 0755]
    }

    # @@end_change
}

proc vTcl:quit {} {
    global vTcl
    if {[vTcl:close] == -1} {return}
    if {$vTcl(quit)} {
        if {[vTcl:dialog "Are you sure\nyou want to quit?" "Yes No"] == "No"} {
            return
        }
    }
    set vTcl(quit) 0
    set vTcl(change) 0
    vTcl:save_prefs
    vTcl:exit
}

proc vTcl:save_prefs {} {
    global vTcl

    set w $vTcl(gui,main)
    set pos [vTcl:get_win_position $w]
    set output "set vTcl(geometry,$w) $vTcl(pr,geom_vTcl)$pos\n"
    set showlist ""

    foreach i $vTcl(windows) {
        if {[winfo exists $i]} {
            if {[wm state $i] == "normal"} {
                append output "set vTcl(geometry,${i}) [wm geometry $i]\n"
                lappend showlist $i
            }
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
                -initialdir [pwd] -filetypes $types]
        }
        save {
            set initname [file tail $vTcl(project,file)]
            if {$initname == ""} {
                set initname "unknown.tcl"
            }
            set file [tk_getSaveFile -defaultextension $ext \
                -initialdir [pwd] -filetypes $types \
                -initialfile $initname]
        }
    }
    set tk_strictMotif 1
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
