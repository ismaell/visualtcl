#############################################################################
# Visual Tcl v1.11 Project
#

#################################
# GLOBAL VARIABLES
#
global x_accel; 
global x_label; 
global widget; 

#################################
# USER DEFINED PROCEDURES
#
proc init {argc argv} {

}

init $argc $argv


proc main {argc argv} {

}

proc Window {args} {
global vTcl
    set cmd [lindex $args 0]
    set name [lindex $args 1]
    set newname [lindex $args 2]
    set rest [lrange $args 3 end]
    if {$name == "" || $cmd == ""} {return}
    if {$newname == ""} {
        set newname $name
    }
    set exists [winfo exists $newname]
    switch $cmd {
        show {
            if {$exists == "1" && $name != "."} {wm deiconify $name; return}
            if {[info procs vTclWindow(pre)$name] != ""} {
                eval "vTclWindow(pre)$name $newname $rest"
            }
            if {[info procs vTclWindow$name] != ""} {
                eval "vTclWindow$name $newname $rest"
            }
            if {[info procs vTclWindow(post)$name] != ""} {
                eval "vTclWindow(post)$name $newname $rest"
            }
        }
        hide    { if $exists {wm withdraw $newname; return} }
        iconify { if $exists {wm iconify $newname; return} }
        destroy { if $exists {destroy $newname; return} }
    }
}

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    wm focusmodel $base passive
    wm geometry $base 1x1+0+0
    wm maxsize $base 1137 870
    wm minsize $base 96 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm withdraw $base
    wm title $base "Combo Demo Project"
    ###################
    # SETTING GEOMETRY
    ###################
}

proc vTclWindow.top22 {base} {
    if {$base == ""} {
        set base .top22
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm geometry $base 237x202+183+155
    wm maxsize $base 1137 870
    wm minsize $base 96 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Geometry Combo"
    frame $base.fra23 \
        -background #a0d9d9 -borderwidth 1 -height 108 -relief sunken \
        -width 93 
    button $base.fra23.01 \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* \
        -highlightthickness 0 -padx 9 -pady 3 -text We 
    button $base.fra23.02 \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* \
        -highlightthickness 0 -padx 9 -pady 3 -text are 
    button $base.fra23.03 \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* \
        -highlightthickness 0 -padx 9 -pady 3 -text placed 
    frame $base.fra24 \
        -background #d9a0d9 -borderwidth 1 -height 30 -relief sunken \
        -width 30 
    button $base.fra24.01 \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* \
        -highlightthickness 0 -padx 9 -pady 3 -text We're 
    button $base.fra24.02 \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* \
        -highlightthickness 0 -padx 9 -pady 3 -text packed 
    frame $base.fra25 \
        -background #d9d9a0 -borderwidth 1 -relief sunken -width 30 
    button $base.fra25.01 \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* \
        -highlightthickness 0 -padx 9 -pady 3 -text And -width 5 
    button $base.fra25.02 \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* \
        -highlightthickness 0 -padx 9 -pady 3 -text a -width 5 
    button $base.fra25.03 \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* \
        -highlightthickness 0 -padx 9 -pady 3 -text grid -width 5 
    button $base.fra25.04 \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* \
        -highlightthickness 0 -padx 9 -pady 3 -text this -width 5 
    button $base.fra25.05 \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* \
        -highlightthickness 0 -padx 9 -pady 3 -text is -width 5 
    button $base.fra25.06 \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* \
        -highlightthickness 0 -padx 9 -pady 3 -text layout -width 5 
    ###################
    # SETTING GEOMETRY
    ###################
    grid columnconf $base 0 -weight 1
    grid columnconf $base 1 -weight 1
    grid rowconf $base 1 -weight 1
    grid $base.fra23 \
        -in .top22 -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 5 -pady 5 \
        -sticky nesw 
    place $base.fra23.01 \
        -x 10 -y 10 -anchor nw -bordermode ignore 
    place $base.fra23.02 \
        -x 50 -y 40 -width 55 -height 24 -anchor nw -bordermode ignore 
    place $base.fra23.03 \
        -x 20 -y 70 -anchor nw -bordermode ignore 
    grid $base.fra24 \
        -in .top22 -column 1 -row 0 -columnspan 1 -rowspan 1 -padx 5 -pady 5 \
        -sticky nesw 
    pack $base.fra24.01 \
        -in .top22.fra24 -anchor center -expand 1 -fill both -padx 2 -pady 2 \
        -side top 
    pack $base.fra24.02 \
        -in .top22.fra24 -anchor center -expand 0 -fill x -padx 2 -pady 2 \
        -side top 
    grid $base.fra25 \
        -in .top22 -column 0 -row 1 -columnspan 2 -rowspan 1 -padx 5 -pady 5 \
        -sticky nesw 
    grid $base.fra25.01 \
        -in .top22.fra25 -column 0 -row 0 -columnspan 1 -rowspan 1 -padx 2 \
        -pady 2 
    grid $base.fra25.02 \
        -in .top22.fra25 -column 0 -row 1 -columnspan 1 -rowspan 1 -padx 2 \
        -pady 2 
    grid $base.fra25.03 \
        -in .top22.fra25 -column 1 -row 1 -columnspan 1 -rowspan 1 -padx 2 \
        -pady 2 
    grid $base.fra25.04 \
        -in .top22.fra25 -column 1 -row 0 -columnspan 1 -rowspan 1 -padx 2 \
        -pady 2 
    grid $base.fra25.05 \
        -in .top22.fra25 -column 2 -row 0 -columnspan 1 -rowspan 1 -padx 2 \
        -pady 2 
    grid $base.fra25.06 \
        -in .top22.fra25 -column 2 -row 1 -columnspan 1 -rowspan 1 -padx 2 \
        -pady 2 
}

Window show .
Window show .top22

main $argc $argv
