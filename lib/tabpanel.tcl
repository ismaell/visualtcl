##############################################################################
#
# tabpanel.tcl - procedures to implement a tabpanel widget
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

proc vTcl:tabpanel {args} {
    global vTcl
    set widget [lindex $args 0]
    set cmd [lindex $args 1]
    set name [lindex $args 2]

    if {[llength $args] == 1} {
        frame $widget
        frame $widget.l
        canvas $widget.c \
            -xscrollcommand "$widget.sh set" -yscrollcommand "$widget.sv set"
        scrollbar $widget.sh -orient horiz -command "$widget.c xview"
        scrollbar $widget.sv -orient vert -command "$widget.c yview"
        grid $widget.l -sticky news -columnspan 2
        grid $widget.c $widget.sv -sticky news
        grid $widget.sh -sticky news
        grid columnconf $widget 0 -weight 1
        grid rowconf $widget 1 -weight 1
        update idletasks
        bind $widget <Configure> "vTcl:tabpanel_update $widget"
        set vTcl(tab,$widget,current) ""
        return $widget
    }

    switch $cmd {
        addtab {
            set name [vTcl:rename $name]
            label $widget.l.$name -text $name -bd 1 -relief raised
            bind $widget.l.$name <ButtonPress> "
                vTcl:tabpanel_raise $widget $name
            "
            pack $widget.l.$name -side left -expand 1 -fill both
            frame $widget.c.$name
            bind $widget.c.$name <Configure> "
                vTcl:tabpanel_update $widget
            "
            $widget.c create window 0 0 -window $widget.c.$name -tag $name -anchor nw
            vTcl:tabpanel_raise $widget $name
            return $widget.c.$name
        }
    }
}

proc vTcl:tabpanel_raise {widget name} {
    global vTcl
    set c $vTcl(tab,$widget,current)
    if {$c != ""} {
        $widget.c coords $vTcl(tab,$widget,current) -1000 -1000
        $widget.l.$vTcl(tab,$widget,current) conf -relief raised
    }
    $widget.c coords $name 0 0
    $widget.l.$name conf -relief sunken
    set vTcl(tab,$widget,current) $name
}

proc vTcl:tabpanel_update {widget} {
    global vTcl
    update idletasks
    set name $vTcl(tab,$widget,current)
    set cw [winfo width $widget.c]
    set ch [winfo height $widget.c]
    set fw [winfo width $widget.c.$name]
    set fh [winfo height $widget.c.$name]
    if {$cw < $fw} {
        grid $widget.sh -sticky news -column 0 -row 2
    } else {
        grid forget $widget.sh
    }
    if {$ch < $fh} {
        grid $widget.sv -sticky news -column 1 -row 1
    } else {
        grid forget $widget.sv
    }
    $widget.c conf -scrollregion "0 0 $fw $fh"
}

proc vTcl:tabtest {} {
    source misc.tcl
    vTcl:tabpanel .x
    set a [vTcl:tabpanel .x addtab "test"]
    text $a.t
    pack $a.t
    set b [vTcl:tabpanel .x addtab "fred"]
    label $b.l -text "this is a label"
    button $b.b -text "this is a button" -command "
        text $b.t
        pack $b.t
    "
    pack $b.l $b.b

    pack .x -expand 1 -fill both
}

vTcl:tabtest

