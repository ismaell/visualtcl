# ------------------------------------------------------------------------------
#  buttonbox.tcl
#  This file is part of Unifix BWidget Toolkit
# ------------------------------------------------------------------------------
#  Index of commands:
#     - ButtonBox::create
#     - ButtonBox::configure
#     - ButtonBox::cget
#     - ButtonBox::add
#     - ButtonBox::itemconfigure
#     - ButtonBox::itemcget
#     - ButtonBox::setfocus
#     - ButtonBox::invoke
#     - ButtonBox::index
#     - ButtonBox::_destroy
# ------------------------------------------------------------------------------

namespace eval ButtonBox {
    Button::use

    Widget::declare ButtonBox {
        {-background  TkResource ""         0 frame}
        {-orient      Enum       horizontal 1 {horizontal vertical}}
        {-homogeneous Boolean    1          1}
        {-spacing     Int        10         0 "%d >= 0"}
        {-padx        TkResource ""         0 button}
        {-pady        TkResource ""         0 button}
        {-default     Int        -1         0 "%d >= -1"} 
        {-bg          Synonym    -background}
    }

    Widget::addmap ButtonBox "" :cmd {-background {}}

    proc ::ButtonBox { path args } { return [eval ButtonBox::create $path $args] }
    proc use {} {}
}


# ------------------------------------------------------------------------------
#  Command ButtonBox::create
# ------------------------------------------------------------------------------
proc ButtonBox::create { path args } {
    Widget::init ButtonBox $path $args

    variable $path
    upvar 0  $path data

    eval frame $path [Widget::subcget $path :cmd] -takefocus 0 -highlightthickness 0

    set data(default)  [Widget::getoption $path -default]
    set data(nbuttons) 0
    set data(max)      0

    bind $path <Destroy> "ButtonBox::_destroy $path"

    rename $path ::$path:cmd
    proc ::$path { cmd args } "return \[eval ButtonBox::\$cmd $path \$args\]"

    return $path
}


# ------------------------------------------------------------------------------
#  Command ButtonBox::configure
# ------------------------------------------------------------------------------
proc ButtonBox::configure { path args } {
    variable $path
    upvar 0  $path data

    set res [Widget::configure $path $args]

    if { [Widget::hasChanged $path -default val] } {
        if { $data(default) != -1 && $val != -1 } {
            set but $path.b$data(default)
            if { [winfo exists $but] } {
                $but configure -default normal
            }
            set but $path.b$val
            if { [winfo exists $but] } {
                $but configure -default active
            }
            set data(default) $val
        } else {
            Widget::setoption $path -default $data(default)
        }
    }

    return $res
}


# ------------------------------------------------------------------------------
#  Command ButtonBox::cget
# ------------------------------------------------------------------------------
proc ButtonBox::cget { path option } {
    return [Widget::cget $path $option]
}


# ------------------------------------------------------------------------------
#  Command ButtonBox::add
# ------------------------------------------------------------------------------
proc ButtonBox::add { path args } {
    variable $path
    upvar 0  $path data

    set but     $path.b$data(nbuttons)
    set spacing [Widget::getoption $path -spacing]

    if { $data(nbuttons) == $data(default) } {
        set style active
    } elseif { $data(default) == -1 } {
        set style disabled
    } else {
        set style normal
    }

    array set flags $args
    set tags ""
    if { [info exists flags(-tags)] } {
	set tags $flags(-tags)
	unset flags(-tags)
	set args [array get flags]
    }

    eval Button::create $but \
        -background [Widget::getoption $path -background]\
        -padx       [Widget::getoption $path -padx] \
        -pady       [Widget::getoption $path -pady] \
        $args \
        -default $style

    # ericm@scriptics.com:  set up tags, just like the menu items
    foreach tag $tags {
	lappend data(tags,$tag) $but
	if { ![info exists data(tagstate,$tag)] } {
	    set data(tagstate,$tag) 0
	}
    }
    set data(buttontags,$but) $tags
    # ericm@scriptics.com

    set idx [expr {2*$data(nbuttons)}]
    if { ![string compare [Widget::getoption $path -orient] "horizontal"] } {
        grid $but -column $idx -row 0 -sticky nsew
        if { [Widget::getoption $path -homogeneous] } {
            set req [winfo reqwidth $but]
            if { $req > $data(max) } {
                for {set i 0} {$i < $data(nbuttons)} {incr i} {
                    grid columnconfigure $path [expr {2*$i}] -minsize $req
                }
                set data(max) $req
            }
            grid columnconfigure $path $idx -minsize $data(max) -weight 1
        } else {
            grid columnconfigure $path $idx -weight 0
        }
        if { $data(nbuttons) > 0 } {
            grid columnconfigure $path [expr {$idx-1}] -minsize $spacing
        }
    } else {
        grid $but -column 0 -row $idx -sticky nsew
        grid rowconfigure $path $idx -weight 0
        if { $data(nbuttons) > 0 } {
            grid rowconfigure $path [expr {$idx-1}] -minsize $spacing
        }
    }

    incr data(nbuttons)

    return $but
}

# ::ButtonBox::setbuttonstate --
#
#	Set the state of a given button tag.  If this makes any buttons
#       enable-able (ie, all of their tags are TRUE), enable them.
#
# Arguments:
#	path        the button box widget name
#	tag         the tag to modify
#	state       the new state of $tag (0 or 1)
#
# Results:
#	None.

proc ::ButtonBox::setbuttonstate {path tag state} {
    variable $path
    upvar 0  $path data
    # First see if this is a real tag
    if { [info exists data(tagstate,$tag)] } {
	set data(tagstate,$tag) $state
	foreach but $data(tags,$tag) {
	    set expression "1"
	    foreach buttontag $data(buttontags,$but) {
		append expression " && $data(tagstate,$buttontag)"
	    }
	    if { [expr $expression] } {
		set state normal
	    } else {
		set state disabled
	    }
	    $but configure -state $state
	}
    }
    return
}

# ::ButtonBox::getbuttonstate --
#
#	Retrieve the state of a given button tag.
#
# Arguments:
#	path        the button box widget name
#	tag         the tag to modify
#
# Results:
#	None.

proc ::ButtonBox::getbuttonstate {path tag} {
    variable $path
    upvar 0  $path data
    # First see if this is a real tag
    if { [info exists data(tagstate,$tag)] } {
	return $data(tagstate,$tag)
    } else {
	error "unknown tag $tag"
    }
}

# ------------------------------------------------------------------------------
#  Command ButtonBox::itemconfigure
# ------------------------------------------------------------------------------
proc ButtonBox::itemconfigure { path index args } {
    if { [set idx [lsearch $args -default]] != -1 } {
        set args [lreplace $args $idx [expr {$idx+1}]]
    }
    return [eval Button::configure $path.b[index $path $index] $args]
}


# ------------------------------------------------------------------------------
#  Command ButtonBox::itemcget
# ------------------------------------------------------------------------------
proc ButtonBox::itemcget { path index option } {
    return [Button::cget $path.b[index $path $index] $option]
}


# ------------------------------------------------------------------------------
#  Command ButtonBox::setfocus
# ------------------------------------------------------------------------------
proc ButtonBox::setfocus { path index } {
    set but $path.b[index $path $index]
    if { [winfo exists $but] } {
        focus $but
    }
}


# ------------------------------------------------------------------------------
#  Command ButtonBox::invoke
# ------------------------------------------------------------------------------
proc ButtonBox::invoke { path index } {
    set but $path.b[index $path $index]
    if { [winfo exists $but] } {
        Button::invoke $but
    }
}


# ------------------------------------------------------------------------------
#  Command ButtonBox::index
# ------------------------------------------------------------------------------
proc ButtonBox::index { path index } {
    if { ![string compare $index "default"] } {
        set res [Widget::getoption $path -default]
    } elseif { ![string compare $index "end"] || ![string compare $index "last"] } {
        variable $path
        upvar 0  $path data

        set res [expr {$data(nbuttons)-1}]
    } else {
        set res $index
    }
    return $res
}


# ------------------------------------------------------------------------------
#  Command ButtonBox::_destroy
# ------------------------------------------------------------------------------
proc ButtonBox::_destroy { path } {
    variable $path
    upvar 0  $path data

    Widget::destroy $path
    unset data
    rename $path {}
}

# ::ButtonBox::gettags --
#
#	Return a list of all the tags on all the buttons in a buttonbox.
#
# Arguments:
#	path      the buttonbox to query.
#
# Results:
#	taglist   a list of tags on the buttons in the buttonbox

proc ::ButtonBox::gettags {path} {
    upvar ::ButtonBox::$path data
    set taglist {}
    foreach tag [array names data "tags,*"] {
	lappend taglist [string range $tag 5 end]
    }
    return $taglist
}

