#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

    package require Tk
    switch $tcl_platform(platform) {
	windows {
            option add *Button.padY 0
	}
	default {
            option add *Scrollbar.width 10
            option add *Scrollbar.highlightThickness 0
            option add *Scrollbar.elementBorderWidth 2
            option add *Scrollbar.borderWidth 2
	}
    }
    
}

#############################################################################
# Visual Tcl v1.60 Project
#


#################################
# VTCL LIBRARY PROCEDURES
#

if {![info exists vTcl(sourcing)]} {
#############################################################################
## Library Procedure:  Window

proc ::Window {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global vTcl
    set cmd     [lindex $args 0]
    set name    [lindex $args 1]
    set newname [lindex $args 2]
    set rest    [lrange $args 3 end]
    if {$name == "" || $cmd == ""} { return }
    if {$newname == ""} { set newname $name }
    if {$name == "."} { wm withdraw $name; return }
    set exists [winfo exists $newname]
    switch $cmd {
        show {
            if {$exists} {
                wm deiconify $newname
            } elseif {[info procs vTclWindow$name] != ""} {
                eval "vTclWindow$name $newname $rest"
            }
            if {[winfo exists $newname] && [wm state $newname] == "normal"} {
                vTcl:FireEvent $newname <<Show>>
            }
        }
        hide    {
            if {$exists} {
                wm withdraw $newname
                vTcl:FireEvent $newname <<Hide>>
                return}
        }
        iconify { if $exists {wm iconify $newname; return} }
        destroy { if $exists {destroy $newname; return} }
    }
}
#############################################################################
## Library Procedure:  vTcl:DefineAlias

proc ::vTcl:DefineAlias {target alias widgetProc top_or_alias cmdalias} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    global widget
    set widget($alias) $target
    set widget(rev,$target) $alias
    if {$cmdalias} {
        interp alias {} $alias {} $widgetProc $target
    }
    if {$top_or_alias != ""} {
        set widget($top_or_alias,$alias) $target
        if {$cmdalias} {
            interp alias {} $top_or_alias.$alias {} $widgetProc $target
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:DoCmdOption

proc ::vTcl:DoCmdOption {target cmd} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## menus are considered toplevel windows
    set parent $target
    while {[winfo class $parent] == "Menu"} {
        set parent [winfo parent $parent]
    }

    regsub -all {\%widget} $cmd $target cmd
    regsub -all {\%top} $cmd [winfo toplevel $parent] cmd

    uplevel #0 [list eval $cmd]
}
#############################################################################
## Library Procedure:  vTcl:FireEvent

proc ::vTcl:FireEvent {target event {params {}}} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    ## The window may have disappeared
    if {![winfo exists $target]} return
    ## Process each binding tag, looking for the event
    foreach bindtag [bindtags $target] {
        set tag_events [bind $bindtag]
        set stop_processing 0
        foreach tag_event $tag_events {
            if {$tag_event == $event} {
                set bind_code [bind $bindtag $tag_event]
                foreach rep "\{%W $target\} $params" {
                    regsub -all [lindex $rep 0] $bind_code [lindex $rep 1] bind_code
                }
                set result [catch {uplevel #0 $bind_code} errortext]
                if {$result == 3} {
                    ## break exception, stop processing
                    set stop_processing 1
                } elseif {$result != 0} {
                    bgerror $errortext
                }
                break
            }
        }
        if {$stop_processing} {break}
    }
}
#############################################################################
## Library Procedure:  vTcl:Toplevel:WidgetProc

proc ::vTcl:Toplevel:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }
    set command [lindex $args 0]
    set args [lrange $args 1 end]
    switch -- [string tolower $command] {
        "setvar" {
            set varname [lindex $args 0]
            set value [lindex $args 1]
            if {$value == ""} {
                return [set ::${w}::${varname}]
            } else {
                return [set ::${w}::${varname} $value]
            }
        }
        "hide" - "show" {
            Window [string tolower $command] $w
        }
        "showmodal" {
            ## modal dialog ends when window is destroyed
            Window show $w; raise $w
            grab $w; tkwait window $w; grab release $w
        }
        "startmodal" {
            ## ends when endmodal called
            Window show $w; raise $w
            set ::${w}::_modal 1
            grab $w; tkwait variable ::${w}::_modal; grab release $w
        }
        "endmodal" {
            ## ends modal dialog started with startmodal, argument is var name
            set ::${w}::_modal 0
            Window hide $w
        }
        default {
            uplevel $w $command $args
        }
    }
}
#############################################################################
## Library Procedure:  vTcl:WidgetProc

proc ::vTcl:WidgetProc {w args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    if {[llength $args] == 0} {
        ## If no arguments, returns the path the alias points to
        return $w
    }
    ## The first argument is a switch, they must be doing a configure.
    if {[string index $args 0] == "-"} {
        set command configure
        ## There's only one argument, must be a cget.
        if {[llength $args] == 1} {
            set command cget
        }
    } else {
        set command [lindex $args 0]
        set args [lrange $args 1 end]
    }
    uplevel $w $command $args
}
#############################################################################
## Library Procedure:  vTcl:toplevel

proc ::vTcl:toplevel {args} {
    ## This procedure may be used free of restrictions.
    ##    Exception added by Christian Gavin on 08/08/02.
    ## Other packages and widget toolkits have different licensing requirements.
    ##    Please read their license agreements for details.

    uplevel #0 eval toplevel $args
    set target [lindex $args 0]
    namespace eval ::$target {set _modal 0}
}
}


if {[info exists vTcl(sourcing)]} {

proc vTcl:project:info {} {
    set base .top79
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 0
        set runvisible 1
    }
    namespace eval ::widgets::$base.lab80 {
        array set save {-anchor 1 -background 1 -text 1}
    }
    namespace eval ::widgets::$base.lab81 {
        array set save {-background 1 -relief 1 -text 1}
    }
    set site_3_0 $base.lab81
    namespace eval ::widgets::$site_3_0.che82 {
        array set save {-anchor 1 -background 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che83 {
        array set save {-anchor 1 -background 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che84 {
        array set save {-anchor 1 -background 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che85 {
        array set save {-anchor 1 -background 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_3_0.che86 {
        array set save {-anchor 1 -background 1 -text 1 -variable 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist _TopLevel
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
        }
        set compounds {
        }
        set projectType single
    }
}
}

#################################
# USER DEFINED PROCEDURES
#
#############################################################################
## Procedure:  main

proc ::main {argc argv} {}

#############################################################################
## Initialization Procedure:  init

proc ::init {argc argv} {}

init $argc $argv

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
    wm focusmodel $top passive
    wm geometry $top 200x200+22+25; update
    wm maxsize $top 1284 1006
    wm minsize $top 111 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm withdraw $top
    wm title $top "vtcl"
    bindtags $top "$top Vtcl all"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    ###################
    # SETTING GEOMETRY
    ###################

    vTcl:FireEvent $base <<Ready>>
}

proc vTclWindow.top79 {base} {
    if {$base == ""} {
        set base .top79
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel
    wm focusmodel $top passive
    wm geometry $top +221+213; update
    wm maxsize $top 1284 1006
    wm minsize $top 111 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm deiconify $top
    wm title $top "Label Frame Widget"
    vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    label $top.lab80 \
        -anchor w -background #ececd799db70 \
        -text {The Labelframe widget works like a frame but adds a label to it.} 
    vTcl:DefineAlias "$top.lab80" "Label1" vTcl:WidgetProc "Toplevel1" 1
    labelframe $top.lab81 \
        -relief ridge -text {Select Toppings} -background #dfdffcfca1a1 
    vTcl:DefineAlias "$top.lab81" "Labelframe1" vTcl:WidgetProc "Toplevel1" 1
    set site_3_0 $top.lab81
    checkbutton $site_3_0.che82 \
        -anchor w -background #dfdffcfca1a1 -text Pepperoni \
        -variable "$top\::che82" 
    vTcl:DefineAlias "$site_3_0.che82" "Checkbutton1" vTcl:WidgetProc "Toplevel1" 1
    checkbutton $site_3_0.che83 \
        -anchor w -background #dfdffcfca1a1 -text Onions \
        -variable "$top\::che83" 
    vTcl:DefineAlias "$site_3_0.che83" "Checkbutton2" vTcl:WidgetProc "Toplevel1" 1
    checkbutton $site_3_0.che84 \
        -anchor w -background #dfdffcfca1a1 -text Tomatoes \
        -variable "$top\::che84" 
    vTcl:DefineAlias "$site_3_0.che84" "Checkbutton3" vTcl:WidgetProc "Toplevel1" 1
    checkbutton $site_3_0.che85 \
        -anchor w -background #dfdffcfca1a1 -text Pineapple \
        -variable "$top\::che85" 
    vTcl:DefineAlias "$site_3_0.che85" "Checkbutton4" vTcl:WidgetProc "Toplevel1" 1
    checkbutton $site_3_0.che86 \
        -anchor w -background #dfdffcfca1a1 -text Anchovies \
        -variable "$top\::che86" 
    vTcl:DefineAlias "$site_3_0.che86" "Checkbutton5" vTcl:WidgetProc "Toplevel1" 1
    pack $site_3_0.che82 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.che83 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.che84 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.che85 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.che86 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.lab80 \
        -in $top -anchor center -expand 0 -fill x -padx 5 -pady 5 -side top 
    pack $top.lab81 \
        -in $top -anchor center -expand 1 -fill both -padx 5 -pady 5 \
        -side top 

    vTcl:FireEvent $base <<Ready>>
}

#############################################################################
## Binding tag:  _TopLevel

bind "_TopLevel" <<Create>> {
    if {![info exists _topcount]} {set _topcount 0}; incr _topcount
}
bind "_TopLevel" <<DeleteWindow>> {
    if {[set ::%W::_modal]} {
                vTcl:Toplevel:WidgetProc %W endmodal
            } else {
                destroy %W; if {$_topcount == 0} {exit}
            }
}
bind "_TopLevel" <Destroy> {
    if {[winfo toplevel %W] == "%W"} {incr _topcount -1}
}

Window show .
Window show .top79

main $argc $argv

