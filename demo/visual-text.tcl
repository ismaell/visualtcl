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


############################
# vTcl Code to Load Stock Images


if {![info exist vTcl(sourcing)]} {
proc vTcl:rename {name} {
    regsub -all "\\." $name "_" ret
    regsub -all "\\-" $ret "_" ret
    regsub -all " " $ret "_" ret
    regsub -all "/" $ret "__" ret
    regsub -all "::" $ret "__" ret

    return [string tolower $ret]
}

proc vTcl:image:create_new_image {filename description type data} {
    global vTcl env

    # Does the image already exist?
    if {[info exists vTcl(images,files)]} {
        if {[lsearch -exact $vTcl(images,files) $filename] > -1} { return }
    }

    if {![info exists vTcl(sourcing)] && [string length $data] > 0} {
        set object [image create  [vTcl:image:get_creation_type $filename]  -data $data]
    } else {
        # Wait a minute... Does the file actually exist?
        if {! [file exists $filename] } {
            # Try current directory
            set script [file dirname [info script]]
            set filename [file join $script [file tail $filename] ]
        }

        if {![file exists $filename]} {
            set description "file not found!"
            set object [image create photo -data [vTcl:image:broken_image] ]
        } else {
            set object [image create  [vTcl:image:get_creation_type $filename]  -file $filename]
        }
    }

    set reference [vTcl:rename $filename]

    set vTcl(images,$reference,image)       $object
    set vTcl(images,$reference,description) $description
    set vTcl(images,$reference,type)        $type
    set vTcl(images,filename,$object)       $filename

    lappend vTcl(images,files) $filename
    lappend vTcl(images,$type) $object

    # return image name in case caller might want it
    return $object
}

proc vTcl:image:get_image {filename} {
    global vTcl
    set reference [vTcl:rename $filename]

    # Let's do some checking first
    if {![info exists vTcl(images,$reference,image)]} {
        # Well, the path may be wrong; in that case check
        # only the filename instead, without the path.

        set imageTail [file tail $filename]

        foreach oneFile $vTcl(images,files) {
            if {[file tail $oneFile] == $imageTail} {
                set reference [vTcl:rename $oneFile]
                break
            }
        }
    }
    return $vTcl(images,$reference,image)
}

proc vTcl:image:get_creation_type {filename} {
    set ext [file extension $filename]
    set ext [string tolower $ext]

    switch $ext {
        .ppm -
        .gif    {return photo}
        .xbm    {return bitmap}
        default {return photo}
    }
}

proc vTcl:image:broken_image {} {
    return {
        R0lGODdhFAAUAPcAAAAAAIAAAACAAICAAAAAgIAAgACAgMDAwICAgP8AAAD/
        AP//AAAA//8A/wD//////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAACwAAAAAFAAUAAAIhAAPCBxIsKDBgwgPAljIUOBC
        BAkBPJg4UeBEBBAVPkCI4EHGghIHChAwsKNHgyEPCFBA0mFDkBtVjiz4AADK
        mAds0tRJMCVBBkAl8hwYMsFPBwyE3jzQwKhAoASUwmTagCjDmksbVDWIderC
        g1174gQ71CHFigfOhrXKUGfbrwnjyp0bEAA7
    }
}

foreach img {

        {{[file join / home cgavin vtcl images edit add.gif]} {} stock {}}
        {{[file join / home cgavin vtcl images edit remove.gif]} {} stock {}}

            } {
    eval set _file [lindex $img 0]
    vTcl:image:create_new_image\
        $_file [lindex $img 1] [lindex $img 2] [lindex $img 3]
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
        array set save {-borderwidth 1}
    }
    namespace eval ::widgets::.top21.fra22.lab30 {
        array set save {-borderwidth 1 -padx 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::.top21.fra22.lab31 {
        array set save {-borderwidth 1 -padx 1 -relief 1 -text 1}
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
        array set save {-background 1 -borderwidth 1 -wrap 1 -xscrollcommand 1 -yscrollcommand 1}
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
    namespace eval ::widgets::.top21.cpd23.02.fra22 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    namespace eval ::widgets::.top21.cpd23.02.fra22.but23 {
        array set save {-image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::.top21.cpd23.02.fra22.but24 {
        array set save {-image 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::.top21.cpd23.02.cpd22 {
        array set save {-borderwidth 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top21.cpd23.02.cpd22.01 {
        array set save {-background 1 -borderwidth 1 -relief 1 -selectmode 1 -xscrollcommand 1 -yscrollcommand 1}
    }
    namespace eval ::widgets::.top21.cpd23.02.cpd22.02 {
        array set save {-command 1 -highlightthickness 1 -orient 1}
    }
    namespace eval ::widgets::.top21.cpd23.02.cpd22.03 {
        array set save {-command 1 -highlightthickness 1}
    }
    namespace eval ::widgets::.top21.cpd23.02.fra23 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top21.cpd23.03 {
        array set save {-background 1 -borderwidth 1 -relief 1}
    }
    namespace eval ::widgets::.top21.m26 {
        array set save {-borderwidth 1 -cursor 1 -relief 1 -tearoff 1}
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
    namespace eval ::widgets::.top22 {
        array set save {}
    }
    namespace eval ::widgets::.top22.lab23 {
        array set save {-anchor 1 -text 1}
    }
    namespace eval ::widgets::.top22.ent24 {
        array set save {-background 1 -textvariable 1}
    }
    namespace eval ::widgets::.top22.fra25 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top22.fra27 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    namespace eval ::widgets::.top22.fra27.cpd28 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top22.fra27.cpd28.01 {
        array set save {-background 1 -height 1 -relief 1 -width 1 -xscrollcommand 1 -yscrollcommand 1}
    }
    namespace eval ::widgets::.top22.fra27.cpd28.02 {
        array set save {-command 1 -highlightthickness 1 -orient 1}
    }
    namespace eval ::widgets::.top22.fra27.cpd28.03 {
        array set save {-command 1 -highlightthickness 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.fra30 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.fra30.lab34 {
        array set save {-text 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.fra30.but31 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.fra30.ent32 {
        array set save {-background 1 -justify 1 -state 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.fra30.but33 {
        array set save {-command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.che35 {
        array set save {-anchor 1 -command 1 -pady 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.che37 {
        array set save {-anchor 1 -command 1 -pady 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.che38 {
        array set save {-anchor 1 -command 1 -pady 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.che39 {
        array set save {-anchor 1 -command 1 -pady 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.lab40 {
        array set save {-anchor 1 -text 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.rad41 {
        array set save {-anchor 1 -command 1 -pady 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.rad42 {
        array set save {-anchor 1 -command 1 -padx 1 -pady 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.rad43 {
        array set save {-anchor 1 -command 1 -pady 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.lab22 {
        array set save {-background 1 -padx 1 -text 1}
    }
    namespace eval ::widgets::.top22.fra27.fra29.lab23 {
        array set save {-background 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::.top22.fra26 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top22.cpd44 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top22.cpd44.01 {
        array set save {-command 1 -highlightthickness 1 -orient 1}
    }
    namespace eval ::widgets::.top22.cpd44.02 {
        array set save {-command 1 -highlightthickness 1}
    }
    namespace eval ::widgets::.top22.cpd44.03 {
        array set save {-background 1 -height 1 -relief 1 -width 1 -xscrollcommand 1 -yscrollcommand 1}
    }
    namespace eval ::widgets::.top22.fra45 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    namespace eval ::widgets::.top22.fra46 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    namespace eval ::widgets::.top22.fra46.but47 {
        array set save {-padx 1 -pady 1 -text 1 -width 1}
    }
    namespace eval ::widgets::.top22.fra46.but48 {
        array set save {-padx 1 -pady 1 -text 1 -width 1}
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

proc {apply_tag} {x y} {
set index [TagsListbox index @$x,$y]
set tag   [TagsListbox get $index]

## apply or unapply the tag?
if {[TagsListbox itemcget $index -background] == "white"} {
    eval MainText tag add $tag [MainText tag ranges sel]
} else {
    eval MainText tag remove $tag [MainText tag ranges sel]
}

show_tags_at_insert
}

proc {command-new} {} {
set tags [MainText tag names]
foreach tag $tags {
    MainText tag delete $tag
}

MainText delete 1.0 end
fill_tags
}

proc {command-open} {w {file {}}} {
global filename widget tk_strictMotif
    
    if {$file == ""} {
        set old $tk_strictMotif
        set tk_strictMotif 0
	set file [tk_getOpenFile  -defaultextension {.ttd}   -initialdir .  -filetypes {{{Rich Tcl Text} *.ttd TEXT} {all *.* TEXT} }  -initialfile $filename  -title "Open..."]
        set tk_strictMotif $old
    }

    if {$file == ""} {return}

    $w delete 1.0 end

    set filename $file
    wm title $widget(VisualText) "$filename - Visual Text"
    set id [open $filename]
    set ttd [read $id]
    close $id
    if {[catch {ttd::insert $w $ttd} message]} {
	tk_messageBox -icon info  -message $message  -title "The file cannot be opened"  -type ok  -parent $w
    }
    $w mark set insert 1.0
    fill_tags
}

proc {command-save} {w} {
global filename tk_strictMotif widget

    set old $tk_strictMotif
    set tk_strictMotif 0
    set file [tk_getSaveFile  -defaultextension {.ttd}   -initialdir .  -filetypes {{{Rich Tcl Text} *.ttd TEXT} {all *.* TEXT}}  -initialfile $filename  -title "Save..."]
    set tk_strictMotif $old

    if {$file != ""} {
	set filename $file
	set id [open $filename w]
	set data [::ttd::get $w]
	puts -nonewline $id $data
	close $id
	wm title $widget(VisualText) "$file - Visual Text"
    }
}

proc {compare_range} {range1 range2} {
set range1 [split $range1 .]
set range2 [split $range2 .]

set line1 [lindex $range1 0]
set line2 [lindex $range2 0]
set col1  [lindex $range1 1]
set col2  [lindex $range2 1]

if {$line1 < $line2} {
    return -1
}

if {$line1 == $line2} {
    if {$col1 < $col2} {
        return -1
    } elseif {$col1 == $col2} {
        return 0
    } else {
        return 1
    } 
} else {
    return 1
}
}

proc {fill_tags} {} {
global widget

TagsText configure -state normal
TagsText delete 1.0 end
TagsListbox delete 0 end

set tags [MainText tag names]

foreach tag $tags {

    if {$tag == "sel"} continue
    
    set opts [MainText tag configure $tag]
    set optvals ""

    foreach opt $opts {
        set name [lindex $opt 0]
        set val  [lindex $opt 4]
        lappend optvals $name $val
    }
    
    TagsListbox insert end $tag
    TagsText insert end $tag\n $tag
    TagsText insert end \n default
    eval TagsText tag configure $tag $optvals
}

TagsText tag configure default -background white
TagsText configure -state disabled
}

proc {init_create_new_tag} {} {
global justify_radio font_size_entry

FontsListbox delete 0 end
foreach family [lsort [font families]] {
    FontsListbox insert end $family
}
FontsListbox selection set 0

set justify_radio left
set font_size_entry 10

TagSampleText delete 1.0 end
TagSampleText insert end "The Quick Brown Fox jumped over a lazy dog's back" sample

update_sample
}

proc {show_insert_position} {} {
set position [MainText index insert]
regexp {([0-9]+)\.([0-9]+)} $position matchAll line col
LineCol configure -text "Line $line Col $col"
}

proc {show_tags_at_insert} {} {
## if anything is selected, we show tags related to the selection
if {[MainText tag ranges sel] != ""} {
    show_tags_at_selection
    return
}

global widget
set tags [MainText tag names insert]

TagsListbox selection clear 0 end
set listtags [TagsListbox get 0 end]

for {set i 0} {$i < [llength $listtags]} {incr i} {
    set tag [lindex $listtags $i]
    if {[lsearch -exact $tags $tag] != -1} {
        TagsListbox itemconfigure $i -background #8080FF
    } else {
        TagsListbox itemconfigure $i -background white
    }
}

show_insert_position
}

proc {show_tags_at_selection} {} {
global widget

TagsListbox selection clear 0 end
set listtags [TagsListbox get 0 end]

set selranges [MainText tag ranges sel]
set selstart  [lindex $selranges 0]
set selend    [lindex $selranges 1]

foreach tag $listtags {
    set ranges($tag) [MainText tag ranges $tag]
}

for {set i 0} {$i < [llength $listtags]} {incr i} {
    set tag [lindex $listtags $i]
    
    ## check if a text is inside the selection or not
    set range $ranges($tag)
    set found 0
                
    while {[llength $range] > 0} {
        set start [lindex $range 0]
        set end   [lindex $range 1]
        set range [lreplace $range 0 1]
        
        set comp1 [compare_range $start $selstart]
        set comp2 [compare_range $selend     $end] 
        if {$comp1 <= 0 && $comp2 <= 0} {
            ## the tag is applied to the whole selection
            TagsListbox itemconfigure $i -background #8080FF
            set found 1
            break
        } elseif {$comp1 >= 0 && $comp2 >= 0} {
            ## the tag is applied somewhere inside the selection
            TagsListbox itemconfigure $i -background gray
            set found 1
            break
        } elseif {$comp1 == -1 && $comp2 == 1 &&
                  [compare_range $end $selstart] == 1} {
            ## the tag starts before the selection, ends in the middle
            TagsListbox itemconfigure $i -background gray
            set found 1
            break
        } elseif {$comp1 == 1 && $comp2 == -1 &&
                  [compare_range $selend $start] == 1} {
            ## the tag starts inside the selection, ends outside
            TagsListbox itemconfigure $i -background gray
            set found 1
            break
        } 
    }

    if {!$found} {
        TagsListbox itemconfigure $i -background white
    }
}

show_insert_position
}

proc {main} {argc argv} {
wm protocol .top21 WM_DELETE_WINDOW {exit}

init_create_new_tag
}

proc {update_sample} {} {
global bold_check italic_check justify_radio font_size_entry
global underline_check overstrike_check

set index [lindex [FontsListbox curselection] 0]
if {$index == ""} {
    FontsListbox selection set 0
    set index 0
}
set family [FontsListbox get $index]
set weight normal
if {$bold_check} {set weight bold}
set slant roman
if {$italic_check} {set slant italic}

TagSampleText tag configure sample -font "-family [list $family] -weight $weight -slant $slant -size $font_size_entry -underline $underline_check -overstrike $overstrike_check"
TagSampleText tag configure sample -justify $justify_radio
TagSampleText tag configure sample -background [TagBackground cget -background]
TagSampleText tag configure sample -foreground [TagForeground cget -background]
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
    wm title $base "vtcl.tcl"
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
    vTcl:DefineAlias "$base" "VisualText" vTcl:Toplevel:WidgetProc "" 1
    vTcl:DefineAlias "$base.cpd23.01.cpd24.03" "MainText" vTcl:WidgetProc "VisualText" 1
    vTcl:DefineAlias "$base.cpd23.02.cpd22.01" "TagsListbox" vTcl:WidgetProc "VisualText" 1
    vTcl:DefineAlias "$base.cpd23.02.fra25.03" "TagsText" vTcl:WidgetProc "VisualText" 1
    vTcl:DefineAlias "$base.fra22.lab30" "LineCol" vTcl:WidgetProc "VisualText" 1

    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    toplevel $base -class Toplevel \
        -menu "$base.m26" 
    wm focusmodel $base passive
    wm geometry $base 678x613+157+97; update
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "/home/cgavin/vtcl/demo/visual-text.ttd - Visual Text"
    }
    frame $base.fra22 \
        -borderwidth 1 
    label $base.fra22.lab30 \
        -borderwidth 1 -padx 1 -relief sunken -text {Line 88 Col 27} 
    label $base.fra22.lab31 \
        -borderwidth 1 -padx 1 -relief sunken -text INS 
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
        -background white -borderwidth 0 -wrap word \
        -xscrollcommand "$base.cpd23.01.cpd24.01 set" \
        -yscrollcommand "$base.cpd23.01.cpd24.02 set" 
    bindtags $base.cpd23.01.cpd24.03 "Text $base all $base.cpd23.01.cpd24.03"
    bind $base.cpd23.01.cpd24.03 <Button-1> {
        show_tags_at_insert
    }
    bind $base.cpd23.01.cpd24.03 <Key-Down> {
        show_tags_at_insert
    }
    bind $base.cpd23.01.cpd24.03 <Key-Left> {
        show_tags_at_insert
    }
    bind $base.cpd23.01.cpd24.03 <Key-Next> {
        show_tags_at_insert
    }
    bind $base.cpd23.01.cpd24.03 <Key-Prior> {
        show_tags_at_insert
    }
    bind $base.cpd23.01.cpd24.03 <Key-Right> {
        show_tags_at_insert
    }
    bind $base.cpd23.01.cpd24.03 <Key-Up> {
        show_tags_at_insert
    }
    frame $base.cpd23.02
    frame $base.cpd23.02.fra25 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    scrollbar $base.cpd23.02.fra25.01 \
        -command "$base.cpd23.02.fra25.03 xview" -highlightthickness 0 \
        -orient horizontal 
    scrollbar $base.cpd23.02.fra25.02 \
        -command "$base.cpd23.02.fra25.03 yview" -highlightthickness 0 
    text $base.cpd23.02.fra25.03 \
        -background white -borderwidth 0 -height 20 -width 20 \
        -xscrollcommand "$base.cpd23.02.fra25.01 set" \
        -yscrollcommand "$base.cpd23.02.fra25.02 set" 
    frame $base.cpd23.02.fra22 \
        -borderwidth 2 -height 75 -width 125 
    button $base.cpd23.02.fra22.but23 \
        \
        -image [vTcl:image:get_image [file join / home cgavin vtcl images edit add.gif]] \
        -relief flat -text button 
    bindtags $base.cpd23.02.fra22.but23 "$base.cpd23.02.fra22.but23 Button $base all FlatToolbarButton"
    button $base.cpd23.02.fra22.but24 \
        \
        -image [vTcl:image:get_image [file join / home cgavin vtcl images edit remove.gif]] \
        -relief flat -text button 
    bindtags $base.cpd23.02.fra22.but24 "$base.cpd23.02.fra22.but24 Button $base all FlatToolbarButton"
    frame $base.cpd23.02.cpd22 \
        -borderwidth 1 -relief sunken -width 30 
    listbox $base.cpd23.02.cpd22.01 \
        -background white -borderwidth 0 -relief flat -selectmode multiple \
        -xscrollcommand "$base.cpd23.02.cpd22.02 set" \
        -yscrollcommand "$base.cpd23.02.cpd22.03 set" 
    bind $base.cpd23.02.cpd22.01 <Button-1> {
        if {[MainText tag ranges sel] != ""} {
    apply_tag %x %y
}
break
    }
    scrollbar $base.cpd23.02.cpd22.02 \
        -command "$base.cpd23.02.cpd22.01 xview" -highlightthickness 0 \
        -orient horizontal 
    scrollbar $base.cpd23.02.cpd22.03 \
        -command "$base.cpd23.02.cpd22.01 yview" -highlightthickness 0 
    frame $base.cpd23.02.fra23 \
        -borderwidth 2 -height 2 -relief raised -width 125 
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
        -borderwidth 0 -cursor {} -relief flat -tearoff 0 
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
        -accelerator {Ctrl + N} -command command-new -image {} -label New 
    $base.m26.men27 add separator
    $base.m26.men27 add command \
        -accelerator {Ctrl + O} -command {command-open $widget(MainText)} \
        -image {} -label Open... 
    $base.m26.men27 add command \
        -accelerator {Ctrl + S} -command {# TODO: Your menu handler here} \
        -image {} -label Save 
    $base.m26.men27 add command \
        -accelerator {} -command {command-save $widget(MainText)} -image {} \
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
        -in $base.cpd23.01 -anchor center -expand 1 -fill both -padx 5 \
        -side top 
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
        -in $base.cpd23.02 -anchor center -expand 1 -fill both -padx 5 \
        -side bottom 
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
    pack $base.cpd23.02.fra22 \
        -in $base.cpd23.02 -anchor center -expand 0 -fill x -side top 
    pack $base.cpd23.02.fra22.but23 \
        -in $base.cpd23.02.fra22 -anchor center -expand 0 -fill none \
        -side left 
    pack $base.cpd23.02.fra22.but24 \
        -in $base.cpd23.02.fra22 -anchor center -expand 0 -fill none \
        -side left 
    pack $base.cpd23.02.cpd22 \
        -in $base.cpd23.02 -anchor center -expand 1 -fill both -padx 5 \
        -side top 
    grid columnconf $base.cpd23.02.cpd22 0 -weight 1
    grid rowconf $base.cpd23.02.cpd22 0 -weight 1
    grid $base.cpd23.02.cpd22.01 \
        -in $base.cpd23.02.cpd22 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.cpd23.02.cpd22.02 \
        -in $base.cpd23.02.cpd22 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew 
    grid $base.cpd23.02.cpd22.03 \
        -in $base.cpd23.02.cpd22 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns 
    pack $base.cpd23.02.fra23 \
        -in $base.cpd23.02 -anchor center -expand 0 -fill x -padx 5 -pady 10 \
        -side top 
    place $base.cpd23.03 \
        -x 0 -relx 0.6906 -y 0 -rely 0.9 -width 10 -height 10 -anchor s \
        -bordermode ignore 
}

proc vTclWindow.top22 {base {container 0}} {
    if {$base == ""} {
        set base .top22
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }

    global widget
    vTcl:DefineAlias "$base" "CreateNewTag" vTcl:Toplevel:WidgetProc "" 1
    vTcl:DefineAlias "$base.cpd44.03" "TagSampleText" vTcl:WidgetProc "CreateNewTag" 1
    vTcl:DefineAlias "$base.fra27.cpd28.01" "FontsListbox" vTcl:WidgetProc "CreateNewTag" 1
    vTcl:DefineAlias "$base.fra27.fra29.lab22" "TagBackground" vTcl:WidgetProc "CreateNewTag" 1
    vTcl:DefineAlias "$base.fra27.fra29.lab23" "TagForeground" vTcl:WidgetProc "CreateNewTag" 1

    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm geometry $base 439x457+223+143; update
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Create New Tag"
    }
    label $base.lab23 \
        -anchor w -text {Enter new tag name:} 
    entry $base.ent24 \
        -background white -textvariable new_tag_name 
    frame $base.fra25 \
        -borderwidth 2 -height 2 -relief groove -width 125 
    frame $base.fra27 \
        -borderwidth 2 -height 75 -width 125 
    frame $base.fra27.cpd28 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    listbox $base.fra27.cpd28.01 \
        -background white -height 5 -relief flat -width 40 \
        -xscrollcommand "$base.fra27.cpd28.02 set" \
        -yscrollcommand "$base.fra27.cpd28.03 set" 
    bind $base.fra27.cpd28.01 <<ListboxSelect>> {
        update_sample
    }
    scrollbar $base.fra27.cpd28.02 \
        -command "$base.fra27.cpd28.01 xview" -highlightthickness 0 \
        -orient horizontal 
    scrollbar $base.fra27.cpd28.03 \
        -command "$base.fra27.cpd28.01 yview" -highlightthickness 0 
    frame $base.fra27.fra29 \
        -borderwidth 2 -height 75 -width 125 
    frame $base.fra27.fra29.fra30 \
        -borderwidth 2 -height 75 -width 125 
    label $base.fra27.fra29.fra30.lab34 \
        -text Size: 
    button $base.fra27.fra29.fra30.but31 \
        -command {incr font_size_entry -1
update_sample} -padx 0 -pady 0 \
        -text < 
    entry $base.fra27.fra29.fra30.ent32 \
        -background white -justify center -state disabled \
        -textvariable font_size_entry -width 3 
    button $base.fra27.fra29.fra30.but33 \
        -command {incr font_size_entry
update_sample} -padx 0 -pady 0 -text > 
    checkbutton $base.fra27.fra29.che35 \
        -anchor w -command update_sample -pady 0 -text Bold \
        -variable bold_check 
    checkbutton $base.fra27.fra29.che37 \
        -anchor w -command update_sample -pady 0 -text Italic \
        -variable italic_check 
    checkbutton $base.fra27.fra29.che38 \
        -anchor w -command update_sample -pady 0 -text Underline \
        -variable underline_check 
    checkbutton $base.fra27.fra29.che39 \
        -anchor w -command update_sample -pady 0 -text Overstrike \
        -variable overstrike_check 
    label $base.fra27.fra29.lab40 \
        -anchor w -text Justify 
    radiobutton $base.fra27.fra29.rad41 \
        -anchor w -command update_sample -pady 0 -text left -value left \
        -variable justify_radio 
    radiobutton $base.fra27.fra29.rad42 \
        -anchor w -command update_sample -padx 1 -pady 0 -text center \
        -value center -variable justify_radio 
    radiobutton $base.fra27.fra29.rad43 \
        -anchor w -command update_sample -pady 0 -text right -value right \
        -variable justify_radio 
    label $base.fra27.fra29.lab22 \
        -background #ffe8ff -padx 1 -text Bkgnd 
    bind $base.fra27.fra29.lab22 <Button-1> {
        %W configure -background [tk_chooseColor -initialcolor [%W cget -background]]
update_sample
    }
    label $base.fra27.fra29.lab23 \
        -background #c03e1c -padx 1 -pady 1 -text Foregnd 
    bind $base.fra27.fra29.lab23 <Button-1> {
        %W configure -background [tk_chooseColor -initialcolor [%W cget -background]]
update_sample
    }
    frame $base.fra26 \
        -borderwidth 2 -height 2 -relief groove -width 125 
    frame $base.cpd44 \
        -borderwidth 1 -height 30 -relief sunken -width 30 
    scrollbar $base.cpd44.01 \
        -command "$base.cpd44.03 xview" -highlightthickness 0 \
        -orient horizontal 
    scrollbar $base.cpd44.02 \
        -command "$base.cpd44.03 yview" -highlightthickness 0 
    text $base.cpd44.03 \
        -background white -height 4 -relief flat -width 20 \
        -xscrollcommand "$base.cpd44.01 set" \
        -yscrollcommand "$base.cpd44.02 set" 
    frame $base.fra45 \
        -borderwidth 2 -height 2 -relief groove -width 125 
    frame $base.fra46 \
        -borderwidth 2 -height 75 -width 125 
    button $base.fra46.but47 \
        -padx 3m -pady 1m -text Add -width 8 
    button $base.fra46.but48 \
        -padx 3m -pady 1m -text Cancel -width 8 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.lab23 \
        -in $base -anchor center -expand 0 -fill x -side top 
    pack $base.ent24 \
        -in $base -anchor center -expand 0 -fill x -side top 
    pack $base.fra25 \
        -in $base -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $base.fra27 \
        -in $base -anchor center -expand 0 -fill both -side top 
    pack $base.fra27.cpd28 \
        -in $base.fra27 -anchor center -expand 1 -fill both -side left 
    grid columnconf $base.fra27.cpd28 0 -weight 1
    grid rowconf $base.fra27.cpd28 0 -weight 1
    grid $base.fra27.cpd28.01 \
        -in $base.fra27.cpd28 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    grid $base.fra27.cpd28.02 \
        -in $base.fra27.cpd28 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew 
    grid $base.fra27.cpd28.03 \
        -in $base.fra27.cpd28 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns 
    pack $base.fra27.fra29 \
        -in $base.fra27 -anchor center -expand 0 -fill y -side right 
    pack $base.fra27.fra29.fra30 \
        -in $base.fra27.fra29 -anchor center -expand 0 -fill none -ipadx 2 \
        -ipady 2 -side top 
    pack $base.fra27.fra29.fra30.lab34 \
        -in $base.fra27.fra29.fra30 -anchor center -expand 0 -fill none \
        -side left 
    pack $base.fra27.fra29.fra30.but31 \
        -in $base.fra27.fra29.fra30 -anchor center -expand 0 -fill none \
        -side left 
    pack $base.fra27.fra29.fra30.ent32 \
        -in $base.fra27.fra29.fra30 -anchor center -expand 0 -fill none \
        -side left 
    pack $base.fra27.fra29.fra30.but33 \
        -in $base.fra27.fra29.fra30 -anchor center -expand 0 -fill none \
        -side left 
    pack $base.fra27.fra29.che35 \
        -in $base.fra27.fra29 -anchor center -expand 0 -fill x -side top 
    pack $base.fra27.fra29.che37 \
        -in $base.fra27.fra29 -anchor center -expand 0 -fill x -side top 
    pack $base.fra27.fra29.che38 \
        -in $base.fra27.fra29 -anchor center -expand 0 -fill x -side top 
    pack $base.fra27.fra29.che39 \
        -in $base.fra27.fra29 -anchor center -expand 0 -fill x -side top 
    pack $base.fra27.fra29.lab40 \
        -in $base.fra27.fra29 -anchor center -expand 0 -fill x -side top 
    pack $base.fra27.fra29.rad41 \
        -in $base.fra27.fra29 -anchor center -expand 0 -fill x -side top 
    pack $base.fra27.fra29.rad42 \
        -in $base.fra27.fra29 -anchor center -expand 0 -fill x -side top 
    pack $base.fra27.fra29.rad43 \
        -in $base.fra27.fra29 -anchor center -expand 0 -fill x -side top 
    pack $base.fra27.fra29.lab22 \
        -in $base.fra27.fra29 -anchor center -expand 0 -fill x -padx 2 \
        -pady 1 -side top 
    pack $base.fra27.fra29.lab23 \
        -in $base.fra27.fra29 -anchor center -expand 0 -fill x -padx 2 \
        -pady 1 -side top 
    pack $base.fra26 \
        -in $base -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $base.cpd44 \
        -in $base -anchor center -expand 1 -fill both -padx 2 -side top 
    grid columnconf $base.cpd44 0 -weight 1
    grid rowconf $base.cpd44 0 -weight 1
    grid $base.cpd44.01 \
        -in $base.cpd44 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew 
    grid $base.cpd44.02 \
        -in $base.cpd44 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns 
    grid $base.cpd44.03 \
        -in $base.cpd44 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    pack $base.fra45 \
        -in $base -anchor center -expand 0 -fill x -pady 5 -side top 
    pack $base.fra46 \
        -in $base -anchor center -expand 0 -fill none -pady 2 -side top 
    pack $base.fra46.but47 \
        -in $base.fra46 -anchor center -expand 0 -fill none -padx 5 -pady 2 \
        -side left 
    pack $base.fra46.but48 \
        -in $base.fra46 -anchor center -expand 0 -fill none -padx 5 -pady 2 \
        -side left 
}

Window show .
Window show .top21
Window show .top22

main $argc $argv
