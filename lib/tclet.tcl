##############################################################################
#
# tclet.tcl - procedures for creating tclets from compounds
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

proc vTcl:create_tclet {target} {
    global vTcl
    if {$target == "" ||
        [vTcl:get_class $target] != "Toplevel"} {
        vTcl:error "You must select a Toplevel\nWindow as the Tclet base"
        return
    }
    set vTcl(cmp,alias) ""
    set vTcl(cmp,index) 0
    set cmpd [vTcl:gen_compound $target]
    set cmd [vTcl:tclet_from_cmpd "" "" $cmpd]
    set file [vTcl:get_file save "Export Tclet"]
    if {$file != ""} {
        if [catch {set out [open $file w]}] {
            vTcl:error "Error saving to file: $error"
            return
        }
        set body [string trim [info body init]]              ;vTcl:statbar 20

        ## Let's give some clue about who might well have generated
        ## this tclet
        set header "#############################################################################
# Visual Tcl v$vTcl(version) Tclet
#
"
        puts $out $header

        ## Gather information about fonts and images.
        vTcl:dump:gather_widget_info

        ## Save only fonts and images we need
        ## All images are saved inline in a tclet
        set old $vTcl(pr,saveimagesinline)
        set vTcl(pr,saveimagesinline) 1

        vTcl:image:generate_image_stock $out
        vTcl:image:generate_image_user  $out
        vTcl:font:generate_font_stock   $out
        vTcl:font:generate_font_user    $out

        set vTcl(pr,saveimagesinline) $old

        puts $out $vTcl(head,procs)                          ;vTcl:statbar 25
        puts $out "proc init \{argc argv\} \{\n$body\n\}\n"  ;vTcl:statbar 30
        puts $out "init \$argc \$argv\n"                     ;vTcl:statbar 35
        puts $out [vTcl:save_procs]                          ;vTcl:statbar 55
        puts $out $vTcl(head,gui)                            ;vTcl:statbar 65
        puts $out $cmd                                       ;vTcl:statbar 75
        puts $out "main \$argc \$argv"                       ;vTcl:statbar 95
        close $out                                           ;vTcl:statbar 0
    }
}

proc vTcl:tclet:translate_options {opts} {
    global vTcl

    set ret {}
    set index 0
    foreach i $opts {
        if {$index % 2 == 0} then {
            set opt $i
            incr index
            continue
        }
        # this option is unknown to the tcl plugin
        if {$opt == "-activebackground" ||
            $opt == "-activeforeground"} then {
            incr index
            continue
        }
        set val $i
        if {[vTcl:streq $opt "-class"]} then {
            incr index
            continue
        }
        if {[info exists vTcl(option,translate,$opt)]} then {
            set val [$vTcl(option,translate,$opt) $val]
        }

        lappend ret $opt $val
        incr index
    }
    return $ret
}

proc vTcl:tclet_from_cmpd {base name compound {level 0}} {
    global vTcl widget classes
    set todo ""
    foreach i $compound {
        set class [string trim [lindex $i 0]]
        set opts [string trim [lindex $i 1]]
        set mgr  [string trim [lindex $i 2]]
        set mgrt [string trim [lindex $mgr 0]]
        set mgri [string trim [lindex $mgr 1]]
        set bind [string trim [lindex $i 3]]
        set menu [string trim [lindex $i 4]]
        set chld [string trim [lindex $i 5]]
        set wdgt [string trim [lindex $i 6]]
        set alis [string trim [lindex $i 7]]
        set grid [string trim [lindex $i 8]]
        set proc [string trim [lindex $i 9]]
        if {$mgrt == "wm" || $base == "."} {
            set base $name
        } elseif {$level == 0} {
            set mgrt pack
            set mgri "-side top -expand 1 -fill both"
        }
        if {$level > 0} {
            set name "$base$wdgt"
        }
        #puts $opts
        if {$class != "Toplevel"} {
            set opts [vTcl:tclet:translate_options $opts]
            append todo "$classes($class,createCmd) $name \\\n"
            append todo "[vTcl:clean_pairs [vTcl:name_replace $base $opts] 4]\n"
        }
        if {$mgrt != "" && $mgrt != "wm" && $name != " "} {
            if {$mgrt == "place" && $mgri == ""} {
                set mgri "-x 5 -y 5"
            }
            append todo "$mgrt $name \\\n[vTcl:clean_pairs $mgri 4]\n"
        }
        set index 0
        incr level
        foreach j $bind {
            set e [lindex $j 0]
            set c [vTcl:name_replace $base [lindex $j 1]]
            append todo "bind $name $e \"$c\"\n"
        }
        foreach j $menu {
            set t [lindex $j 0]
            set o [lindex $j 1]
            if {$t != "tearoff"} {
                append todo "$name add $t $o\n"
            }
        }
        foreach j $chld {
            append todo "[vTcl:tclet_from_cmpd $base $name \{$j\} $level]\n"
            incr index
        }
        if {$alis != ""} {
            set widget($alis) $name
            set widget(rev,$name) "$alis"
        }
        foreach j $grid {
            set cmd [lindex $j 0]
            set num [lindex $j 1]
            set prop [lindex $j 2]
            set val [lindex $j 3]
            if {$name == ""} {
                append todo "grid $cmd . $num $prop $val\n"
            } else {
                append todo "grid $cmd $name $num $prop $val\n"
            }
        }
        foreach j $proc {
            set nme [lindex $j 0]
            set arg [lindex $j 1]
            set bdy [lindex $j 2]
            append todo "proc $nme \{$arg\} \{\n$bdy\n\}\n"
        }
    }
    return $todo
}
