#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {

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
    switch -- $command {
        "setvar" {
            set varname [lindex $args 0]
            set value [lindex $args 1]
            if {$value == ""} {
                return [set ::${w}::${varname}]
            } else {
                return [set ::${w}::${varname} $value]
            }
        }
        "hide" - "Hide" - "show" - "Show" {
            Window [string tolower $command] $w
        }
        "ShowModal" {
            Window show $w
            raise $w
            grab $w
            tkwait window $w
            grab release $w
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
    namespace eval ::$target {}
}
}


if {[info exists vTcl(sourcing)]} {

proc vTcl:project:info {} {
    set base .top82
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
    }
    namespace eval ::widgets::$base.lab83 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$base.ent84 {
        array set save {-background 1 -textvariable 1}
    }
    namespace eval ::widgets::$base.lab84 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$base.lab85 {
        array set save {-anchor 1 -background 1 -text 1}
    }
    namespace eval ::widgets::$base.lab86 {
        array set save {-anchor 1 -justify 1 -text 1}
    }
    namespace eval ::widgets::$base.lab87 {
        array set save {-anchor 1 -background 1 -justify 1 -text 1}
    }
    namespace eval ::widgets::$base.lab88 {
        array set save {-anchor 1 -justify 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd89 {
        array set save {-anchor 1 -background 1 -justify 1 -text 1}
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
    }
}
}

#################################
# USER DEFINED PROCEDURES
#
#############################################################################
## Procedure:  main

proc ::main {argc argv} {
if {![info exists ::vTcl(running)]} {
    console show
}
}

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
    wm geometry $top 200x200+44+50; update
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

proc vTclWindow.top82 {base} {
    if {$base == ""} {
        set base .top82
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
    wm geometry $top 428x388+273+263; update
    wm maxsize $top 1284 1006
    wm minsize $top 111 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm deiconify $top
    wm title $top "Entry field"
    vTcl:DefineAlias "$top" "Toplevel1" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<DeleteWindow>>"

    label $top.lab83 \
        -text {The entry widget allows you to enter one line of text.} 
    vTcl:DefineAlias "$top.lab83" "Label1" vTcl:WidgetProc "Toplevel1" 1
    entry $top.ent84 \
        -background white -textvariable "$top\::ent84" 
    vTcl:DefineAlias "$top.ent84" "Entry1" vTcl:WidgetProc "Toplevel1" 1
    label $top.lab84 \
        -text {The text typed in the entry widget is stored into a variable.} 
    vTcl:DefineAlias "$top.lab84" "Label2" vTcl:WidgetProc "Toplevel1" 1
    label $top.lab85 \
        -anchor w -background #aa95e6f4ecec \
        -text {By default, vTcl assigns a default variable name to an entry.} 
    vTcl:DefineAlias "$top.lab85" "Label3" vTcl:WidgetProc "Toplevel1" 1
    label $top.lab86 \
        -anchor nw -justify left \
        -text {Using the toplevel alias, you can easily set or retrieve the
value of a variable assigned to an entry widget.

Try typing in the command console:} 
    vTcl:DefineAlias "$top.lab86" "Label4" vTcl:WidgetProc "Toplevel1" 1
    label $top.lab87 \
        -anchor nw -background #ffffff -justify left \
        -text {(vtcl) 1 % Toplevel1 setvar ent84 "hello world"
hello world
(vtcl) 2 % Toplevel1 setvar ent84
hello world} 
    vTcl:DefineAlias "$top.lab87" "Label5" vTcl:WidgetProc "Toplevel1" 1
    label $top.lab88 \
        -anchor nw -justify left \
        -text {Now, type some text in the entry, for example: "The quick brown fox."

Then, type in the command console:} 
    vTcl:DefineAlias "$top.lab88" "Label6" vTcl:WidgetProc "Toplevel1" 1
    label $top.cpd89 \
        -anchor nw -background #ffffff -justify left \
        -text {(vtcl) 3 % Toplevel1 setvar ent84
The quick brown fox.} 
    vTcl:DefineAlias "$top.cpd89" "Label7" vTcl:WidgetProc "Toplevel1" 1
    ###################
    # SETTING GEOMETRY
    ###################
    place $top.lab83 \
        -x 10 -y 15 -anchor nw -bordermode ignore 
    place $top.ent84 \
        -x 10 -y 40 -width 406 -height 19 -anchor nw -bordermode ignore 
    place $top.lab84 \
        -x 10 -y 70 -anchor nw -bordermode ignore 
    place $top.lab85 \
        -x 10 -y 95 -width 402 -height 19 -anchor nw -bordermode ignore 
    place $top.lab86 \
        -x 10 -y 120 -width 398 -height 64 -anchor nw -bordermode ignore 
    place $top.lab87 \
        -x 10 -y 185 -width 403 -height 69 -anchor nw -bordermode ignore 
    place $top.lab88 \
        -x 10 -y 265 -anchor nw -bordermode ignore 
    place $top.cpd89 \
        -x 10 -y 315 -width 404 -height 58 -anchor nw 

    vTcl:FireEvent $base <<Ready>>
}

#############################################################################
## Binding tag:  _TopLevel

bind "_TopLevel" <<Create>> {
    if {![info exists _topcount]} {set _topcount 0}; incr _topcount
}
bind "_TopLevel" <<DeleteWindow>> {
    destroy %W; if {$_topcount == 0} {exit}
}
bind "_TopLevel" <Destroy> {
    if {[winfo toplevel %W] == "%W"} {incr _topcount -1}
}

Window show .
Window show .top82

main $argc $argv
