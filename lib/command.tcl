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

# @@ change by Christian Gavin
# procedure not used
# @@ end_change

# proc vTcl:edit_wincmd {which} {
#    global vTcl
#    set target $vTcl(w,widget)
#    set base ".vTcl.com_${which}_[vTcl:rename $target]"
#    if {[catch {set cmd [info body vTclWindow($which)$target]}]} {
#        set cmd ""
#   }
#    set cmd [string trim $cmd]
#    set r [vTcl:get_command "Window ${which}Command for $target" $cmd $base]
#    if {$r == -1} {
#        return
#    } else {
#        set procname vTclWindow($which)$target
#        vTcl:list add "{$procname}" vTcl(procs)
#        proc $procname {args} $r
#    }
# }

proc vTcl:set_command {target {option -command} {variable vTcl(w,opt,-command)}} {
    global vTcl
    if {$target == ""} {return}
    set base ".vTcl.com_[vTcl:rename ${target}${option}]"

    if {[catch {set cmd [$target cget $option]}] == 1} { return }

    set r [vTcl:get_command "$option for $target" $cmd $base]
    if {$r == -1} { return }

    $target configure $option [string trim $r]

    global $variable
    set $variable [string trim $r]
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
        -borderwidth 2 -height 30 -relief groove -width 30
    pack $base.f \
        -in $base -anchor center -expand 1 -fill both -ipadx 0 -ipady 0 \
        -padx 3 -pady 3 -side bottom
    text $base.f.text \
        -height 2 -width 2 -wrap none \
        -yscrollcommand "$base.f.scrollbar16 set" -background white
    pack $base.f.text \
        -in $base.f -anchor center -expand 1 -fill both -ipadx 0 \
        -ipady 0 -padx 0 -pady 0 -side left 
    scrollbar $base.f.scrollbar16 \
        -command "$base.f.text yview"
    pack $base.f.scrollbar16 \
        -in $base.f -anchor center -expand 0 -fill y -ipadx 0 -ipady 0 \
        -padx 0 -pady 0 -side left 
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
    
    # @@change by Christian Gavin 3/20/2000
    # syntax colouring
    
    vTcl:syntax_color $base.f.text
    
    # @@end_change
    
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
        vTcl:dialog "Buffer has changed. Do you\nwish to save the changes?" {Yes No Cancel}
        switch $vTcl(x_mesg) {
            No {
                grab release $base
                destroy $base
            }
            Yes {vTcl:command:edit_save $base}
            Cancel {}
        }
    }
}


