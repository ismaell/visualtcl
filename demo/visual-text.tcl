#!/bin/sh
# the next line restarts using wish\
exec wish "$0" "$@" 

if {![info exists vTcl(sourcing)]} {
    switch $tcl_platform(platform) {
	windows {
	}
	default {
	    option add *Scrollbar.width 10
	}
    }
    
}
#############################################################################
# Visual Tcl v1.51 Project
#

#################################
# VTCL LIBRARY PROCEDURES
#

if {![info exists vTcl(sourcing)]} {
proc Window {args} {
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
            if {$exists} { wm deiconify $newname; return }
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
}

if {![info exists vTcl(sourcing)]} {
proc {vTcl:DefineAlias} {target alias widgetProc top_or_alias cmdalias} {
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

proc {vTcl:Toplevel:WidgetProc} {w args} {
    if {[llength $args] == 0} {
        return -code error "wrong # args: should be \"$w option ?arg arg ...?\""
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

    switch -- $command {
        "hide" -
        "Hide" {
            Window hide $w
        }

        "show" -
        "Show" {
            Window show $w
        }

        "ShowModal" {
            Window show $w
            raise $w
            grab $w
            tkwait window $w
            grab release $w
        }

        default {
            eval $w $command $args
        }
    }
}

proc {vTcl:WidgetProc} {w args} {
    if {[llength $args] == 0} {
        return -code error "wrong # args: should be \"$w option ?arg arg ...?\""
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

    eval $w $command $args
}
}

if {[info exists vTcl(sourcing)]} {
proc vTcl:project:info {} {
    namespace eval ::widgets::.top21 {
        array set save {-menu 1}
    }
    namespace eval ::widgets::.top21.fra22 {
        array set save {-borderwidth 1 -relief 1}
    }
    namespace eval ::widgets::.top21.fra22.lab30 {
        array set save {-padx 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::.top21.fra22.lab31 {
        array set save {-padx 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::.top21.cpd23 {
        array set save {-background 1}
    }
    namespace eval ::widgets::.top21.cpd23.01 {
        array set save {}
    }
    namespace eval ::widgets::.top21.cpd23.01.cpd24 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top21.cpd23.01.cpd24.01 {
        array set save {-command 1 -highlightthickness 1 -orient 1}
    }
    namespace eval ::widgets::.top21.cpd23.01.cpd24.02 {
        array set save {-command 1 -highlightthickness 1}
    }
    namespace eval ::widgets::.top21.cpd23.01.cpd24.03 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1 -wrap 1 -xscrollcommand 1 -yscrollcommand 1}
    }
    namespace eval ::widgets::.top21.cpd23.02 {
        array set save {}
    }
    namespace eval ::widgets::.top21.cpd23.02.fra25 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top21.cpd23.02.fra25.01 {
        array set save {-command 1 -highlightthickness 1 -orient 1}
    }
    namespace eval ::widgets::.top21.cpd23.02.fra25.02 {
        array set save {-command 1 -highlightthickness 1}
    }
    namespace eval ::widgets::.top21.cpd23.02.fra25.03 {
        array set save {-background 1 -borderwidth 1 -height 1 -width 1 -xscrollcommand 1 -yscrollcommand 1}
    }
    namespace eval ::widgets::.top21.cpd23.03 {
        array set save {-background 1 -borderwidth 1 -relief 1}
    }
    namespace eval ::widgets::.top21.m26 {
        array set save {-cursor 1 -tearoff 1}
    }
    namespace eval ::widgets::.top21.m26.men27 {
        array set save {-tearoff 1}
    }
    namespace eval ::widgets::.top21.m26.men28 {
        array set save {-tearoff 1}
    }
    namespace eval ::widgets::.top21.m26.men29 {
        array set save {-tearoff 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {}
    }
}
}
#################################
# USER DEFINED PROCEDURES
#

namespace eval ::ttd {

proc {::ttd::get} {args} {
# Tcl/Tk text dump
#
# Copyright (c) 1999, Bryan Douglas Oakley
# All Rights Reserved.
#
# This code is provide as-is, with no warranty expressed or implied. Use
# at your own risk.
#
#
    set argc [llength $args]
    if {$argc == 0} {
	error "wrong \# args: must be ::ttd::get pathName ?index1? ?index2?"
    }
    set w [lindex $args 0]

    if {[winfo class $w] != "Text"} {
	error "\"$w\" is not a text widget"
    }

    if {$argc == 1} {
	set index1 "1.0"
	# one might think we want "end -1c" here, but if we do that
	# we end up losing some tagoff directives. We'll remove the
	# trailing space later.
	set index2 "end"
    } elseif {$argc == 2} {
	set index1 [lindex $args 1]
	set index2 "[$w index {$index1 + 1c}]"
    } else {
	set index1 [lindex $args 1]
	set index2 [lindex $args 2]
    }
    
    set tagData {}
    set imageData {}

    set header "# -*- tcl -*-\n#\n\n"
    set version [list ttd.version 1.0]
    set result [list ]

    # we use these arrays to keep track of actual images, tags
    # and windows (though, not really windows...)
    catch {unset tags}
    catch {unset images}
    catch {unset windows}

    foreach {key value index} [$w dump $index1 $index2] {
	switch -exact -- $key {
	    tagon {
		lappend result [list ttd.tagon $value]
		if {![info exists tags($value)]} {
		    # we need to steal all of the configuration data
		    set tagname $value
		    set tags($tagname) {}
		    foreach item [$w tag configure $tagname] {
			set value [lindex $item 4]
			if {[string length $value] > 0} {
			    set option [lindex $item 0]
			    lappend tags($tagname) $option $value
			}
		    }
		}
	    }
	    tagoff {
		lappend result [list ttd.tagoff $value]
	    }
	    text {
		lappend result [list ttd.text $value]
	    }
	    mark {
		# bah! marks aren't interesting, are they?
#		lappend result [list ttd.mark $value]
	    }
	    image {
		# $value is an internal identifier. We need the actual
		# image name so we can grab its data...
		set imagename [$w image cget $value -image]
		set image [list ttd.image]

		# this gets all of the options for this image
		# at this location (such as -align, etc)
		foreach item [$w image configure $value] {
		    set value [lindex $item 4]
		    if {[string length $value] != 0} {
			set option [lindex $item 0]
			lappend image $option $value
		    }
		}
		lappend result $image

		# if we don't yet have a definition for this
		# image, grab it
		if {[string length $imagename] > 0  && ![info exists images($imagename)]} {
		    # we need to steal all of the configuration data
		    set images($imagename) $imagename
		    foreach item [$imagename configure] {
			set value [lindex $item 4]
			if {[string length $imagename] > 0} {
			    set option [lindex $item 0]
			    lappend images($imagename) $option $value
			}
		    }
		}
	    }

	    window {
		set window [list ttd.window $value]
		foreach item [$w window configure $index] {
		    set value [lindex $item 4]
		    if {[string length $value] != 0} {
			set option [lindex $item 0]
			lappend window $option $value
		    }
		}
		lappend result $window
	    }
	}

    }
    
    # process tags in priority order; ignore tags that aren't used
    set tagData {}
    foreach tag [$w tag names] {
	if {[info exists tags($tag)]} {
	    lappend tagData [concat ttd.tagdef $tag $tags($tag)]
	}
    }
    set imageData {}
    foreach image [array names images] {
	lappend imageData [concat ttd.imgdef $images($image)]
    }

    # remove the trailing newline that the text widget added
    # for us
    set result [lreplace $result end end]

    set tmp $header
    append tmp "$version\n\n"
    append tmp "[join $tagData \n]\n\n"
    append tmp "[join $imageData \n]\n\n"
    append tmp "[join $result \n]\n"
    return $tmp
}

}

namespace eval ::ttd {

proc {::ttd::insert} {w ttd} {
variable ttdVersion {}
    variable taglist
    variable safeInterpreter
    variable ttdCode

    # create a safe interpreter, if we haven't already done so
    catch {interp delete $safeInterpreter }
    set safeInterpreter [interp create -safe]

    # we want the widget command to be available to the 
    # safe interpreter. Also, the text may include embedded
    # images, so we need the image command available as well.
    interp alias $safeInterpreter masterTextWidget {} $w
    interp alias $safeInterpreter image {} image
#    interp alias $safeInterpreter puts {} puts

    # this defines the commands we use to parse the data
    $safeInterpreter eval $ttdCode

    # this processes the data. Alert the user if there was
    # a problem.
    if {[catch {$safeInterpreter eval $ttd} error]} {
	set message "Error opening file:\n\n$error"
	tk_messageBox -icon info  -message $message  -title "Bad file"  -type ok 
    }

    # and clean up after ourselves
    interp delete $safeInterpreter
}

}

proc {command-open} {w {file {}}} {
global filename
global tk_strictMotif
    
    if {$file == ""} {
        set old $tk_strictMotif
        set tk_strictMotif 0
	set file [tk_getOpenFile  -defaultextension {.ttd}   -initialdir .  -filetypes {{{Rich Tcl Text} *.ttd TEXT} {all *.* TEXT} }  -initialfile $filename  -title "Open..."]
        set tk_strictMotif $old
    }

    if {$file == ""} {return}

    $w delete 1.0 end

    set filename $file
    wm title . "$filename - Tcl/Tk Text Dump Viewer"
    set id [open $filename]
    set ttd [read $id]
    close $id
    if {[catch {ttd::insert $w $ttd} message]} {
	tk_messageBox -icon info  -message $message  -title "The file cannot be opened"  -type ok  -parent $w
    }
    $w mark set insert 1.0
}

proc {main} {argc argv} {
wm protocol .top21 WM_DELETE_WINDOW {exit}
}

proc init {argc argv} {
global filename
set filename ""

namespace eval ::ttd {
    variable code
    variable ttdVersion {}
    variable taglist
    variable safeInterpreter
}

# this code defines the commands which are embedded in the ttd
# data. It should only executed in a safe interpreter.
set ::ttd::ttdCode {
    set taglist ""
    set command ""
    set ttdVersion ""

    proc ttd.version {version} {
	global ttdVersion
	set ttdVersion $version
    }

    proc ttd.window {args} {
	# not supported yet
	error "embedded windows aren't supported in this version"
    }

    proc ttd.image {args} {
	global taglist

	set index [masterTextWidget index insert]
	eval masterTextWidget image create $index $args

	# we want the current tags associated with the image...
	# (I wonder why I can't supply tags at the time I create
	# the image, like I can when I insert text?)
	foreach tag $taglist {
	    masterTextWidget tag add $tag $index
	}
    }

    proc ttd.imgdef {name args} {
	eval image create photo $name $args
    }

    proc ttd.tagdef {name args} {
	eval masterTextWidget tag configure $name $args
    }

    proc ttd.text {string} {
	global taglist
	masterTextWidget insert insert $string $taglist
    }

    proc ttd.tagon {tag} {
	global taglist

	# I'm confused by this, but we need to keep track of our
	# tags in reverse order.
	set taglist [concat $tag $taglist]
    }

    proc ttd.tagoff {tag} {
	global taglist

	set i [lsearch -exact $taglist $tag]
	if {$i >= 0} {
	    set taglist [lreplace $taglist $i $i]
	}
	masterTextWidget tag remove $tag insert
    }

    proc ttd.mark {name} {
	masterTextWidget mark set $name [masterTextWidget index insert]
    }
}
}

init $argc $argv

#################################
# VTCL GENERATED GUI PROCEDURES
#

proc vTclWindow. {base {container 0}} {
    if {$base == ""} {
        set base .
    }
    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    wm focusmodel $base passive
    wm geometry $base 1x1+0+0; update
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm withdraw $base
    wm title $base "/home/cgavin/vtcl/demo/visual-text.ttd - Tcl/Tk Text Dump Viewer"
    bindtags $base "$base Vtcl.tcl all"
    }
    ###################
    # SETTING GEOMETRY
    ###################
}

proc vTclWindow.top21 {base {container 0}} {
    if {$base == ""} {
        set base .top21
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }

    global widget
    vTcl:DefineAlias "$base.cpd23.01.cpd24.03" "MainText" vTcl:WidgetProc "$base" 1

    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    toplevel $base -class Toplevel \
        -menu "$base.m26" 
    wm focusmodel $base passive
    wm geometry $base 692x525+115+161; update
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Visual Text"
    }
    frame $base.fra22 \
        -borderwidth 1 -relief raised 
    label $base.fra22.lab30 \
        -padx 1 -relief sunken -text {Line 1 Col 1} 
    label $base.fra22.lab31 \
        -padx 1 -relief sunken -text INS 
    frame $base.cpd23 \
        -background #000000 
    frame $base.cpd23.01
    frame $base.cpd23.01.cpd24 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    scrollbar $base.cpd23.01.cpd24.01 \
        -command "$base.cpd23.01.cpd24.03 xview" -highlightthickness 0 \
        -orient horizontal 
    scrollbar $base.cpd23.01.cpd24.02 \
        -command "$base.cpd23.01.cpd24.03 yview" -highlightthickness 0 
    text $base.cpd23.01.cpd24.03 \
        -background white -borderwidth 0 -height 10 -width 20 -wrap word \
        -xscrollcommand "$base.cpd23.01.cpd24.01 set" \
        -yscrollcommand "$base.cpd23.01.cpd24.02 set" 
    frame $base.cpd23.02
    frame $base.cpd23.02.fra25 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    scrollbar $base.cpd23.02.fra25.01 \
        -command "$base.cpd23.02.fra25.03 xview" -highlightthickness 0 \
        -orient horizontal 
    scrollbar $base.cpd23.02.fra25.02 \
        -command "$base.cpd23.02.fra25.03 yview" -highlightthickness 0 
    text $base.cpd23.02.fra25.03 \
        -background white -borderwidth 0 -height 10 -width 20 \
        -xscrollcommand "$base.cpd23.02.fra25.01 set" \
        -yscrollcommand "$base.cpd23.02.fra25.02 set" 
    frame $base.cpd23.03 \
        -background #ff0000 -borderwidth 2 -relief raised 
    bind $base.cpd23.03 <B1-Motion> {
        set root [ split %W . ]
    set nb [ llength $root ]
    incr nb -1
    set root [ lreplace $root $nb $nb ]
    set root [ join $root . ]
    set width [ winfo width $root ].0
    
    set val [ expr (%X - [winfo rootx $root]) /$width ]

    if { $val >= 0 && $val <= 1.0 } {
    
        place $root.01 -relwidth $val
        place $root.03 -relx $val
        place $root.02 -relwidth [ expr 1.0 - $val ]
    }
    }
    menu $base.m26 \
        -cursor {} -tearoff 1 
    $base.m26 add cascade \
        -menu "$base.m26.men27" -accelerator {} -command {} -image {} \
        -label File 
    $base.m26 add cascade \
        -menu "$base.m26.men28" -accelerator {} -command {} -image {} \
        -label Edit 
    $base.m26 add cascade \
        -menu "$base.m26.men29" -accelerator {} -command {} -image {} \
        -label Help 
    menu $base.m26.men27 \
        -tearoff 0 
    $base.m26.men27 add command \
        -accelerator {Ctrl + N} -command {# TODO: Your menu handler here} \
        -image {} -label New 
    $base.m26.men27 add separator
    $base.m26.men27 add command \
        -accelerator {Ctrl + O} -command {command-open $widget(MainText)} \
        -image {} -label Open... 
    $base.m26.men27 add command \
        -accelerator {Ctrl + S} -command {# TODO: Your menu handler here} \
        -image {} -label Save 
    $base.m26.men27 add command \
        -accelerator {} -command {# TODO: Your menu handler here} -image {} \
        -label {Save As...} 
    $base.m26.men27 add separator
    $base.m26.men27 add command \
        -accelerator {Ctrl + Q} -command exit -image {} -label Quit 
    menu $base.m26.men28 \
        -tearoff 0 
    $base.m26.men28 add command \
        -accelerator {Ctrl + X} -command {# TODO: Your menu handler here} \
        -image {} -label Cut 
    $base.m26.men28 add command \
        -accelerator {Ctrl + C} -command {# TODO: Your menu handler here} \
        -image {} -label Copy 
    $base.m26.men28 add command \
        -accelerator {Ctrl + V} -command {# TODO: Your menu handler here} \
        -image {} -label Paste 
    menu $base.m26.men29 \
        -tearoff 0 
    $base.m26.men29 add command \
        -accelerator {} -command {# TODO: Your menu handler here} -image {} \
        -label About... 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra22 \
        -in $base -anchor center -expand 0 -fill x -side bottom 
    pack $base.fra22.lab30 \
        -in $base.fra22 -anchor center -expand 0 -fill none -padx 2 \
        -side left 
    pack $base.fra22.lab31 \
        -in $base.fra22 -anchor center -expand 0 -fill none -padx 2 \
        -side left 
    pack $base.cpd23 \
        -in $base -anchor center -expand 1 -fill both -side top 
    place $base.cpd23.01 \
        -x 0 -y 0 -width -1 -relwidth 0.6906 -relheight 1 -anchor nw \
        -bordermode ignore 
    pack $base.cpd23.01.cpd24 \
        -in $base.cpd23.01 -anchor center -expand 1 -fill both -side top 
    grid columnconf $base.cpd23.01.cpd24 0 -weight 1
    grid rowconf $base.cpd23.01.cpd24 0 -weight 1
    grid $base.cpd23.01.cpd24.01 \
        -in $base.cpd23.01.cpd24 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew 
    grid $base.cpd23.01.cpd24.02 \
        -in $base.cpd23.01.cpd24 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns 
    grid $base.cpd23.01.cpd24.03 \
        -in $base.cpd23.01.cpd24 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    place $base.cpd23.02 \
        -x 0 -relx 1 -y 0 -width -1 -relwidth 0.3094 -relheight 1 -anchor ne \
        -bordermode ignore 
    pack $base.cpd23.02.fra25 \
        -in $base.cpd23.02 -anchor center -expand 1 -fill both -side top 
    grid columnconf $base.cpd23.02.fra25 0 -weight 1
    grid rowconf $base.cpd23.02.fra25 0 -weight 1
    grid $base.cpd23.02.fra25.01 \
        -in $base.cpd23.02.fra25 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew 
    grid $base.cpd23.02.fra25.02 \
        -in $base.cpd23.02.fra25 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns 
    grid $base.cpd23.02.fra25.03 \
        -in $base.cpd23.02.fra25 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    place $base.cpd23.03 \
        -x 0 -relx 0.6906 -y 0 -rely 0.9 -width 10 -height 10 -anchor s \
        -bordermode ignore 
}

Window show .
Window show .top21

main $argc $argv
