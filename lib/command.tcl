##############################################################################
#
# command.tcl - procedures to update widget commands
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

proc vTcl:set_command {target {option -command} {variable vTcl(w,opt,-command)}} {
    global vTcl
    if {$target == ""} {return}
    set base ".vTcl.com_[vTcl:rename ${target}${option}]"

    if {[catch {set cmd [$target cget $option]}] == 1} { return }

    ## if the command is in the form "vTcl:DoCmdOption target cmd",
    ## then extracts the command, otherwise use the command as is
    if {[regexp {vTcl:DoCmdOption [^ ]+ (.*)} $cmd matchAll realCmd]} {
        lassign $cmd dummy1 dummy2 cmd
    }
    set r [vTcl:get_command "$option for $target" $cmd $base]
    if {$r == -1} { return }
    set cmd [string trim $r]

    ## if the command is non null, replace it by DoCmdOption
    if {$cmd != "" && [string match *%* $cmd]} {
        set cmd [list vTcl:DoCmdOption $target $cmd]
    }

    $target configure $option $cmd

    global $variable
    set $variable $cmd
    vTcl:prop:save_opt $target $option $variable
}

proc vTcl:get_command {title initial base} {
    global vTcl
    if {[winfo exists $base]} {wm deiconify $base; raise $base; return -1}
    set vTcl(x,$base) -1
    toplevel $base -class vTcl
    wm transient $base .vTcl
    # wm geometry $base $vTcl(pr,geom_comm)
    vTcl:check_mouse_coords
    wm geometry $base 350x200+[expr $vTcl(mouse,X)-120]+[expr $vTcl(mouse,Y)-20]
    wm resizable $base 1 1
    wm title $base $title
    set vTcl(comm,$base,chg) 0

    frame $base.f \
        -borderwidth 1 -relief sunken
    scrollbar $base.f.01 \
        -command "$base.f.text xview" -highlightthickness 0 \
        -orient horizontal
    scrollbar $base.f.02 \
        -command "$base.f.text yview" -highlightthickness 0
    text $base.f.text \
        -background white -borderwidth 0 -height 3 -wrap none \
        -relief flat -width 20 -xscrollcommand "$base.f.01 set" \
        -yscrollcommand "$base.f.02 set"
    pack $base.f \
        -in "$base" -anchor center -expand 1 -fill both -side bottom
    grid columnconf $base.f 0 -weight 1
    grid rowconf $base.f 0 -weight 1
    grid $base.f.01 \
        -in "$base.f" -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew
    grid $base.f.02 \
        -in "$base.f" -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns
    grid $base.f.text \
        -in "$base.f" -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw

    frame $base.f21 \
        -height 30 -relief flat -width 30
    pack $base.f21 \
        -in $base -anchor center -expand 0 -fill x -ipadx 0 -ipady 0 \
        -padx 3 -side top
    button $base.f21.button23 \
        -command "
            vTcl:command:edit_cancel $base
        " \
         -padx 9 \
        -pady 3 -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) edit remove.gif] ]
    pack $base.f21.button23 \
        -in $base.f21 -anchor center -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side right
    vTcl:set_balloon $base.f21.button23 "Discard changes"
    button $base.f21.button22 \
        -command "vTcl:command:edit_save $base" \
        -padx 9 \
        -pady 3 -image [vTcl:image:get_image [file join $vTcl(VTCL_HOME) edit ok.gif] ]
    pack $base.f21.button22 \
        -in $base.f21 -anchor center -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side right
    vTcl:set_balloon $base.f21.button22 "Save changes"
    update idletasks
    bind $base <KeyPress> "
        set vTcl(comm,$base,chg) 1
    "
    bind $base <Key-Escape> "
        vTcl:command:edit_save $base
        break
    "
    $base.f.text delete 0.0 end
    $base.f.text insert end $initial
    focus $base.f.text

    ## syntax colouring
    vTcl:syntax_color $base.f.text

    tkwait window $base
    update idletasks
    switch -- $vTcl(x,$base) {
        "-1"      {return -1}
        default "return $vTcl(x,$base)"
    }
}

proc vTcl:command:save_geom {base} {
    global vTcl
    set vTcl(pr,geom_comm) [winfo geometry $base]
    # set vTcl(pr,geom_comm) [lindex [split [wm geom $base] +-] 0]
}

proc vTcl:command:edit_save {base} {
    global vTcl
    vTcl:command:save_geom $base
    set vTcl(x,$base) [$base.f.text get 0.0 end]
    destroy $base
}

proc vTcl:command:edit_cancel {base} {
    global vTcl
    vTcl:command:save_geom $base
    if {$vTcl(comm,$base,chg) == 0} {
        grab release $base
        destroy $base
    } else {
        set result [tk_messageBox -icon question -parent $base -default yes \
        -message "Buffer has changed. Do you wish to save the changes?" \
        -title "Changed buffer!" -type yesnocancel]

        switch $result {
            no {
                grab release $base
                destroy $base
            }
            yes {vTcl:command:edit_save $base}
            cancel {}
        }
    }
}
