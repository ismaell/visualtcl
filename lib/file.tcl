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
    vTcl:new_widget toplevel
    vTcl:setup_bind_tree .
    vTcl:update_top_list
    vTcl:update_var_list
    vTcl:update_proc_list
    set vTcl(project,name) "unknown.tcl"
    wm title $vTcl(gui,main) "Visual Tcl - $vTcl(project,name)"
}

proc vTcl:file_source {} {
    set file [vTcl:get_file open "Source File"]
    if {$file != ""} {
        vTcl:source $file
    }
}

proc vTcl:source {file} {
    global vTcl
    set vTcl(sourcing) 1
    set ov [uplevel #0 info vars];           vTcl:statbar 15
    set op [uplevel #0 info procs];          vTcl:statbar 20
    if {[catch {uplevel #0 [list source $file]} err]} {
        vTcl:dialog "Error Sourcing Project\n$err"
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
    foreach procname [uplevel #0 info procs] {
        if {[vTcl:ignore_procname_when_sourcing $procname] == 0} {
            lappend np $procname
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
        if {![file exists $file]} {return}
    }
    if {$file != ""} {
        set vTcl(file,mode) ""
        proc exit {args} {}
        proc init {argc argv} {}
        proc main {argc argv} {}
        vTcl:load_lib vtclib.tcl;            vTcl:statbar 10
        set vTcl(tops) ""
        set vTcl(vars) ""
        set vTcl(procs) ""
        vTcl:source $file;                   vTcl:statbar 55
        vTcl:list add "init main" vTcl(procs)
        vTcl:setup_bind_tree .;              vTcl:statbar 65
        vTcl:update_top_list;                vTcl:statbar 75
        vTcl:update_var_list;                vTcl:statbar 85
        vTcl:update_proc_list;               vTcl:statbar 95
        set vTcl(project,file) $file
        set vTcl(project,name) [lindex [file split $file] end]
        wm title .vTcl "Visual Tcl - $vTcl(project,name)"
        vTcl:status "Done Loading"
        vTcl:statbar 0
        set vTcl(newtops) [expr {[llength $vTcl(tops)]} + 1]
		set vTcl(newtops) [expr [llength $vTcl(tops)] + 1]
    }
}

proc vTcl:close {} {
    global vTcl
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
    set tops [winfo children .]
    foreach i $tops {
        if {$i != ".vTcl" && $i != ".__tk_filedialog"} {destroy $i}
    }
    set vTcl(tops) ""
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

proc vTcl:save2 {file} {
    global vTcl env
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
    if {[array get env PATH_TO_WISH] != ""} {
        puts $output "#!$env(PATH_TO_WISH)"
    }
    puts $output "[subst $vTcl(head,proj)]\n"
    if {$vTcl(save) == "all"} {
        puts $output $vTcl(head,vars)
        puts $output [vTcl:save_vars]
        set body [string trim [info body init]]
        puts $output $vTcl(head,procs)
        puts $output "proc init \{argc argv\} \{\n$body\n\}\n"
        puts $output "init \$argc \$argv\n"
        puts $output [vTcl:save_procs]
        puts $output $vTcl(head,gui)
        puts $output [vTcl:save_tree .]
        puts $output "main \$argc \$argv"
    } else {
        puts $output [vTcl:save_tree $vTcl(w,widget)]
    }
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
    set output ""
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


