##############################################################################
#
# misc.tcl - leftover uncategorized procedures
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

proc vTcl:at {varname} {
    upvar $varname localvar
    return $localvar
}

proc vTcl:util:greatest_of {numlist} {
    set max 0
    foreach i $numlist {
        if {$i > $max} {
            set max $i
        }
    }
    return $max
}

proc vTcl:upper_first {string} {
    return [string toupper [string index $string 0]][string range $string 1 end]
}

proc vTcl:lower_first {string} {
    return [string tolower [string index $string 0]][string range $string 1 end]
}

proc vTcl:load_images {} {
    global vTcl

    foreach i {fg bg mgr_grid mgr_pack mgr_place
                rel_groove rel_ridge rel_raised rel_sunken justify
                relief border ellipses anchor fontbase fontsize fontstyle
                tconsole} {
        image create photo "$i" \
            -file [file join $vTcl(VTCL_HOME) images $i.gif]
    }
    foreach i {n s e w nw ne sw se c} {
        image create photo "anchor_$i" \
            -file [file join $vTcl(VTCL_HOME) images anchor_$i.ppm]
    }
    image create bitmap "file_down" \
        -file [file join $vTcl(VTCL_HOME) images down.xbm]
}

proc vTcl:list {cmd elements list} {
    upvar $list nlist
    switch $cmd {
        add {
            foreach i $elements {
                if {[lsearch -exact $nlist $i] < 0} {
                    lappend nlist $i
                }
            }
        }
        delete {
            foreach i $elements {
                set n [lsearch -exact $nlist $i]
                if {$n > -1} {
                    set nlist [lreplace $nlist $n $n]
                }
            }
        }
    }
    return $nlist
}

proc vTcl:diff_list {oldlist newlist} {
    set output ""
    foreach oldent $oldlist {
        set oldar($oldent) 1
    }
    foreach newent $newlist {
        if {[info exists oldar($newent)] == 0} {
            lappend output $newent
        }
    }
    return [lsort $output]
}

proc vTcl:clean_pairs {list {indent 8}} {
    global vTcl
    set tab [string range "                " 0 [expr $indent - 1]]
    set index $indent
    set output $tab
    set last ""
    foreach i $list {
        if {$last == ""} {
            set last $i
        } else {
            # @@change by Christian Gavin 3/18/2000
            # special case to handle image filenames
            # 3/26/2000
            # special case to handle font keys

	    set noencase 0

	    if {[info exists vTcl(option,noencase,$last)]} {

	        if [string match *font* $last] {

	       		if [string match {\[*\]} $i] {
	       			set noencase 1
	       		}

		} else {
			if [info exists vTcl(option,noencasewhen,$last)] {

				set noencase [$vTcl(option,noencasewhen,$last) $i]
				# vTcl:puts "noencase :$noencase, $i"
			} else {

				set noencase 1
			}
		}
	    }

            if {$noencase} {

            	    set i "$last $i "

            } else {
	            switch $vTcl(pr,encase) {
 	               list {
  	                  set i "$last [list $i] "
   	               }
    	               brace {
     	                  set i "$last \{$i\} "
      	               }
       	  	       quote {
        	           set i "$last \"$i\" "
         	       }
         	   }
            }

            # @@end_change
            set last ""
            set len [string length $i]
            if { [expr $index + $len] > 78 } {
                append output "\\\n${tab}${i}"
                set index [expr $indent + $len]
            } else {
                append output "$i"
                incr index $len
            }
        }
    }
    return $output
}

#############################
# Setting Widget Properties #
#############################
proc vTcl:bounded_incr {var delta} {
    upvar $var newvar
    set newval [expr $newvar + $delta]
    if {$newval < 0} {
        set newvar 0
    } else {
        set newvar $newval
    }
}

proc vTcl:pos_neg {num} {
    if {$num > 0} {return 1}
    if {$num < 0} {return -1}
    return 0
}

proc vTcl:widget_delta {widget x y w h} {
    global vTcl
    switch $vTcl(w,manager) {
        grid {
            vTcl:bounded_incr vTcl(w,grid,-column) [vTcl:pos_neg $x]
            vTcl:bounded_incr vTcl(w,grid,-row) [vTcl:pos_neg $y]
            vTcl:bounded_incr vTcl(w,grid,-columnspan) [vTcl:pos_neg $w]
            vTcl:bounded_incr vTcl(w,grid,-rowspan) [vTcl:pos_neg $h]
            vTcl:manager_update grid
        }
        pack {
            if {$x < 0 || $y < 0} {vTcl:pack_before $vTcl(w,widget)}
            if {$x > 0 || $y > 0} {vTcl:pack_after $vTcl(w,widget)}
        }
        place {
            set newX [expr [winfo x $widget] + $x]
            set newY [expr [winfo y $widget] + $y]
            set newW [expr [winfo width $widget] + $w]
            set newH [expr [winfo height $widget] + $h]
            set do "place $vTcl(w,widget) -x $newX -y $newY \
                -width $newW -height $newH -bordermode ignore"
            set undo [vTcl:dump_widget_quick $widget]
            vTcl:push_action $do $undo
        }
    }
    vTcl:place_handles $widget
}

##############################################################################
# OTHER PROCEDURES
##############################################################################
proc vTcl:hex {num} {
    if {$num == ""} {set num 0}
    set textnum [format "%x" $num]
    if { $num < 16 } { set textnum "0${textnum}" }
    return $textnum
}

proc vTcl:grid_snap {xy pos} {
    global vTcl
    if { $vTcl(w,manager) != "place" } { return $pos }
    set off [expr $pos % $vTcl(grid,$xy)]
    if { $off > 0 } {
        return [expr $pos - $off]
    } else {
        return $pos
    }
}

proc vTcl:status {message} {
    global vTcl
    set vTcl(status) $message
    update idletasks
}

proc vTcl:right_click {widget X Y x y} {
    global vTcl

    vTcl:set_mouse_coords $X $Y $x $y

    vTcl:active_widget $widget
    $vTcl(gui,rc_menu) post $X $Y
    grab $vTcl(gui,rc_menu)
    bind $vTcl(gui,rc_menu) <ButtonRelease> {
        grab release $vTcl(gui,rc_menu)
	vTcl:set_mouse_coords %X %Y %x %y
        $vTcl(gui,rc_menu) unpost
    }
}

proc vTcl:statbar {value} {
    global vTcl
    set w [expr [winfo width [winfo parent $vTcl(gui,statbar)]] - 4]
    set h [expr [winfo height [winfo parent $vTcl(gui,statbar)]] - 4]
    set mult [expr ${w}.0 / 100.0]
    if {$value == 0} {
        place forget $vTcl(gui,statbar)
    } else {
        place $vTcl(gui,statbar) -x 1 -y 1 -width [expr $value * $mult] -height $h
    }
    update idletasks
}

proc vTcl:show_bindings {} {
    global vTcl
    if {$vTcl(w,widget) != ""} {
        Window show .vTcl.bind
        vTcl:get_bind $vTcl(w,widget)
    } else {
        vTcl:dialog "No widget selected!"
    }
}

# @@change by Christian Gavin 3/15/2000
# modif to generate widget names starting
# from long Windows 9x filenames with spaces

proc vTcl:rename {name} {

    regsub -all "\\." $name "_" ret
    regsub -all "\\-" $ret "_" ret
    regsub -all " " $ret "_" ret
    regsub -all "/" $ret "__" ret

    return [string tolower $ret]
}

# @@end_change

proc vTcl:cmp_user_menu {} {
    global vTcl
    #set m $vTcl(gui,main).menu.c.m.m.u
    set m $vTcl(menu,user,m)
    catch {destroy $m}
    menu $m -tearoff 0
    foreach i [lsort $vTcl(cmpd,list)] {
        $m add comm -label $i -comm "
            vTcl:put_compound [list $i] \$vTcl(cmpd:$i)
        "
    }
}

proc vTcl:cmp_sys_menu {} {
    global vTcl
#    set m $vTcl(gui,main).menu.c.m.m.s
    set m $vTcl(menu,system,m)
    catch {destroy $m}
    menu $m -tearoff 0
    foreach i [lsort $vTcl(syscmpd,list)] {
        $m add comm -label $i -comm "
            vTcl:put_compound [list $i] \$vTcl(syscmpd:$i)
        "
    }
}

proc vTcl:get_children {target} {
    global vTcl

    # @@change by Christian Gavin 3/7/2000
    # mega-widgets children should not be copied

    foreach megawidget $vTcl(megaWidget) {

	    if [string match $megawidget [vTcl:get_class $target]] {
  	  	return ""
	    }
    }

    # @@end_change

    set r ""
    set all [winfo children $target]
    set n [pack slaves $target]
    if {$n != ""} {
        foreach i $all {
            if {[lsearch -exact $n $i] < 0} {
                lappend n $i
            }
        }
    } else {
        set n $all
    }
    foreach i $n {
        if ![string match ".__tk*" $i] {
            lappend r $i
        }
    }
    return $r
}

proc vTcl:find_new_tops {} {
    global vTcl
    set new ""
    foreach i $vTcl(procs) {
        if [string match $vTcl(winname).* $i] {
            set n [string range $i 10 end]
            if {$n != "."} {
                lappend new [string range $i 10 end]
            }
        }
    }
    foreach i [vTcl:list_widget_tree .] {
        if {[winfo class $i] == "Toplevel"} {
            if {[lsearch $new $i] < 0} {
                lappend new $i
            }
        }
    }
    return $new
}

proc vTcl:error {mesg} {
    vTcl:dialog $mesg
}

proc vTcl:dialog {mesg {options Ok} {root 0}} {
    global vTcl tcl_platform
    set vTcl(x_mesg) ""
    if {$root == 0} {
        set base .vTcl.message
    } else {
        set base .vTcl:message
    }
    set sw [winfo screenwidth .]
    set sh [winfo screenheight .]
    if {![winfo exists $base]} {
        toplevel $base -class vTcl
        wm title $base "Visual Tcl Message"
        wm transient $base .vTcl
        frame $base.f -bd 2 -relief groove
        label $base.f.t -bd 0 -relief flat -text $mesg -justify left \
            -font $vTcl(pr,font_dlg)
        frame $base.o -bd 1 -relief sunken
        foreach i $options {
            set n [string tolower $i]
            button $base.o.$n -text $i -width 5 \
            -command "
                set vTcl(x_mesg) $i
                destroy $base
            "
            pack $base.o.$n -side left -expand 1 -fill x
        }
        pack $base.f.t -side top -expand 1 -fill both -ipadx 5 -ipady 5
        pack $base.f -side top -expand 1 -fill both -padx 2 -pady 2
        pack $base.o -side top -fill x -padx 2 -pady 2
    }
    wm withdraw $base
    update idletasks
    set w [winfo reqwidth $base]
    set h [winfo reqheight $base]
    set x [expr ($sw - $w)/2]
    set y [expr ($sh - $h)/2]
    if {$tcl_platform(platform) != "unix"} {
        wm deiconify $base
    }
    wm geometry $base +$x+$y
    if {$tcl_platform(platform) == "unix"} {
        wm deiconify $base
    }
    grab $base
    tkwait window $base
    grab release $base
    return $vTcl(x_mesg)
}

# @@change by Christian Gavin 3/18/2000
# procedures to manage modal dialog boxes
# from "Effective Tcl/Tk Programming, by Mark Harrison, Michael McLennan"
# @@end_change

##############################################################################
# MODAL DIALOG BOXES
##############################################################################

proc vTcl:dialog_wait {win varName {nopos 0}} {

	vTcl:dialog_safeguard $win

	if {$nopos==0} {

		set x [expr [winfo rootx .] + 50]
		set y [expr [winfo rooty .] + 50]

		wm geometry $win "+$x+$y"
		wm deiconify $win
	}

	grab set $win
	vwait $varName
	grab release $win

	wm withdraw $win
}

bind vTcl:modalDialog <ButtonPress> {

	wm deiconify %W
	raise %W
}

proc vTcl:dialog_safeguard {win} {

	if {[lsearch [bindtags $win] vTcl:modalDialog] < 0} {

		bindtags $win [linsert [bindtags $win] 0 modalDialog]
	}
}

# @@change by Christian Gavin 3/19/2000
# procedure to find patterns in a text control
# based on the procedures by John K. Ousterhout in
# "Tcl and the Tk Toolkit"
# @@end_change

proc vTcl:forAllMatches {w tags callback {from 1} {to -1}} {

	global vTcl

	if {$to == -1} {
		scan [$w index end] %d to
	}

	for {set i $from} {$i <= $to} {incr i} {

		# get the line only once
		set currentLine [$w get $i.0 $i.end]

		# special case?
		if {[string range [string trim $currentLine] 0 0] == "\#"} {

                        $w mark set first $i.0
                        $w mark set last "$i.end"

		        $callback $w vTcl:comment
		        continue
		}

                foreach tag $tags {

			set lastMark 0
			$w mark set last $i.0

			while {[regexp -indices $vTcl(syntax,$tag) \
			       [string range $currentLine $lastMark end] indices]} {

		 	     $w mark set first "last + [lindex $indices 0] chars"

		   	     $w mark set last "last + 1 chars + [lindex $indices 1] chars"

		             set lastMark [expr $lastMark + 1 + [lindex $indices 1]]

		             if [info exists vTcl(syntax,$tag,validate)] {

		             	 if {! [$vTcl(syntax,$tag,validate) [$w get first last] ] } {

		             	      	continue
		             	 }
		             }

		     	     $callback $w $tag
			}
		}
	}
}

# @@change by Christian Gavin 3/19/2000
# syntax colouring for text widget
# @@end_change

proc vTcl:syntax_item {w tag} {

	# already a tag there ?
	if { [$w tag names first] != ""} return

	$w tag add $tag first last
}

# from, to indicate the line numbers of the area to colorize
# if not specified, the full text widget is colorized

proc vTcl:syntax_color {w {from 1} {to -1}} {

	global vTcl

	set patterns ""

	if {$to == -1} {
		scan [$w index end] %d to
	}

	foreach tag $vTcl(syntax,tags) {

		$w tag remove $tag $from.0 $to.end
	}

	vTcl:forAllMatches $w $vTcl(syntax,tags) vTcl:syntax_item \
		$from $to

	foreach tag $vTcl(syntax,tags) {

		eval $w tag configure $tag $vTcl(syntax,$tag,configure)
	}
}

# @@change by Christian Gavin 4/22/2000
#
# procedure to prepare a pull-down modal window
#
# on Windows systems, Tk8.2 does not set the geometry of a window if it
# is withdraw
#
# to avoid seeing the window change in size and move around, we move it
# out of the way of the current display, then it is created and finally
# repositioned using display_pulldown
#
# @@end_change

proc vTcl:prepare_pulldown {base xl yl} {

    global tcl_platform

    set size $xl
    set size [append size x]
    set size [append size $yl]

    if {$tcl_platform(platform)=="windows"} {

        wm geometry $base $size+1600+1200
    } else {

	wm geometry $base $size+0+0
    }
}

# @@change by Christian Gavin 4/22/2000
#
# procedure to position a pull-down modal window near the mouse pointer
# arrange the window so that it fits inside the current display
#
# xl is the requested width
# yl is the requested height
#
# @@end_change

proc vTcl:display_pulldown {base xl yl} {

    global tcl_platform

    wm withdraw $base

    wm overrideredirect $base 1
    update

    # move it near mouse pointer
    set xm [winfo pointerx $base]
    set ym [winfo pointery $base]

    vTcl:log "mouse=$xm,$ym"

    set x0 [expr $xm - $xl ]
    set y0 $ym

    set x1 $xm
    set y1 [expr $ym + $yl ]

    set xmax [winfo screenwidth $base]
    set ymax [winfo screenheight $base]

    if {$x1 > $xmax } {
    	set x0 [expr $xmax - $xl ]
    }

    if {$y1 > $ymax } {
	set y0 [expr $ymax - $yl ]
    }

    if {$x0 < 0} "set x0 0"
    if {$y0 < 0} "set y0 0"

    wm geometry $base "+$x0+$y0"
    wm deiconify $base

    # add this line for $%@^! Windows
    # apparently the 8.2 implementation of Tk does not change the
    # geometry of the window if it is "withdrawn"

    if {$tcl_platform(platform)=="windows"} {
        wm geometry $base "+$x0+$y0"
    }
}

proc vTcl:split_geom {geom} {
    set vars {height width x y}
    foreach var $vars { set $var {} }
    regexp {([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)} $geom \
    	trash width height x y
    return [list $width $height $x $y]
}

proc vTcl:get_win_position {w} {
    lassign [vTcl:split_geom [wm geometry $w]] width height x y
    return "+$x+$y"
}

proc lremove {varName args} {
    upvar 1 $varName list

    set found 0
    foreach pattern $args {
	set s [lsearch $list $pattern]
	while {$s > -1} {
	    set list [lreplace $list $s $s]
	    set s [lsearch $list $pattern]
	    incr found
	}
    }
    return $found
}

proc lempty {list} {
    return [expr [llength $list] == 0]
}

proc lassign {list args} {
    foreach elem $list varName $args {
    	upvar 1 $varName var
	set var $elem
    }
}

proc vTcl:namespace_tree {{root "::"}} {

    set children [namespace children $root]
    set result "$root"

    foreach child $children {

        foreach subchild [vTcl:namespace_tree $child] {

            lappend result $subchild
        }
    }

    return $result
}

proc vTcl:copy_widgetname {} {
    global fakeClipboard vTcl
    set fakeClipboard $vTcl(w,widget)
    .vTcl.widgetname selection range 0 end
}

proc error {string} {
    tk_messageBox -title Error -icon error -type ok -message $string
}

proc echo {args} {
    puts stdout [join $args ""]
    flush stdout
}

proc incr0 {varName {num 1}} {
    upvar 1 $varName var
    if {![info exists var]} { set var 0 }
    incr var $num
}

proc vTcl:WrongNumArgs {string} {
    return "wrong # args: should be \"$string\""
}

proc vTcl:set_mouse_coords {X Y x y} {
    global vTcl
    foreach var [list X Y x y] {
    	set vTcl(mouse,$var) [set $var]
    }
}

proc vTcl:rebind_button_1 {} {
    global vTcl
    bind vTcl(b) <Button-1> {vTcl:bind_button_1 %W %X %Y %x %y}
}

proc vTcl:lib:add_widgets_to_toolbar {list} {
    global widgets

    foreach i $list {
	if {![info exists widgets($i,class)]} { continue }
	vTcl:toolbar_add $i $widgets($i,balloon) \
	    $widgets($i,image) $widgets($i,addOptions)
    }
}

proc vTcl:lrmdups {list} {
    if {[lempty $list]} { return }
    if {[info tclversion] > 8.2} { return [lsort -unique $list] }
    set list [lsort $list]
    set last [lindex $list 0]
    set list [lrange $list 1 end]
    lappend result $last
    foreach elem $list {
    	if {[string compare $last $elem] != 0} {
	    lappend result $elem
	    set last $elem
	}
    }
    return $result
}

proc vTcl:center {target {w 0} {h 0}} {
    if {[vTcl:get_class $target] != "Toplevel"} { return }
    update
    if {$w == 0} { set w [winfo reqwidth $target] }
    if {$h == 0} { set h [winfo reqheight $target] }
    set sw [winfo screenwidth $target]
    set sh [winfo screenheight $target]
    set x0 [expr ([winfo screenwidth $target] - $w)/2 - [winfo vrootx $target]]
    set y0 [expr ([winfo screenheight $target] - $h)/2 - [winfo vrooty $target]]
    set x "+$x0"
    set y "+$y0"
    if { $x0+$w > $sw } {set x "-0"; set x0 [expr {$sw-$w}]}
    if { $x0 < 0 }      {set x "+0"}
    if { $y0+$h > $sh } {set y "-0"; set y0 [expr {$sh-$h}]}
    if { $y0 < 0 }      {set y "+0"}

    wm geometry $target $x$y
    update
}

proc vTcl:raise_last_button {newButton} {
    global vTcl

    if {![info exists vTcl(x,lastButton)]} { return }

    if {$vTcl(x,lastButton) == $newButton} { return }

    $vTcl(x,lastButton) configure -relief raised

    set vTcl(x,lastButton) $newButton
}

#####################################################################
#                                                                   #
# The following routines are used for in-line images support        #
#                                                                   #
# In-line images are stored in the main project file instead of     #
# beeing contained in separate files. They are encoded using base64 #
#                                                                   #
#####################################################################

# -------------------------------------------------------------------
# Routines for encoding and decoding base64
# encoding from Time Janes,
# decoding from Pascual Alonso,
# namespace'ing and bugs from Parand Tony Darugar
# (tdarugar@binevolve.com)
#
# $Id: misc.tcl,v 1.16 2000/10/21 22:01:45 cgavin Exp $
# -------------------------------------------------------------------

namespace eval base64 {
  set charset "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

  # this proc by Christian Gavin
  proc encode_file {filename} {

     set inID [open $filename r]
     fconfigure $inID -translation binary
     set contents [read $inID]
     close $inID

     set encoded [::base64::encode $contents]
     set length  [string length $encoded]
     set chunk   60
     set result  ""

     for {set index 0} {$index < $length} {set index [expr $index + $chunk] } {

         set index_end [expr $index + $chunk - 1]

         if {$index_end >= $length} {

             set index_end [expr $length - 1]
             append result [string range $encoded $index $index_end]

         } else {

             append result [string range $encoded $index $index_end]
             append result \n
         }
     }

     return $result
  }

  # ----------------------------------------
  # encode the given text
  proc encode {text} {
    set encoded ""
    set y 0
    for {set i 0} {$i < [string length $text] } {incr i} {
      binary scan [string index $text $i] c x
      if { $x < 0 } {
        set x [expr $x + 256 ]
      }
      set y [expr ( $y << 8 ) + $x]
      if { [expr $i % 3 ] == 2}  {
        append  encoded [string index $base64::charset [expr ( $y & 0xfc0000 ) >> 18 ]]
        append  encoded [string index $base64::charset [expr ( $y & 0x03f000 ) >> 12 ]]
        append  encoded [string index $base64::charset [expr ( $y & 0x000fc0 ) >> 6 ]]
        append  encoded [string index $base64::charset [expr ( $y & 0x00003f ) ]]
        set y 0
      }
    }
    if { [expr $i % 3 ] == 1 } {
      set y [ expr $y << 4 ]
      append encoded [string index $base64::charset [ expr ( $y & 0x000fc0 ) >> 6]]
      append encoded [string index $base64::charset [ expr ( $y & 0x00003f ) ]]
      append encoded "=="
    }
    if { [expr $i % 3 ] == 2 } {
      set y [ expr $y << 2 ]
      append  encoded [string index $base64::charset [expr ( $y & 0x03f000 ) >> 12 ]]
      append  encoded [string index $base64::charset [expr ( $y & 0x000fc0 ) >> 6 ]]
      append  encoded [string index $base64::charset [expr ( $y & 0x00003f ) ]]
      append encoded "="
    }
    return $encoded
  }

  # ----------------------------------------
  # decode the given text
  # Generously contributed by Pascual Alonso
  proc decode {text} {
    set decoded ""
    set y 0
    if {[string first = $text] == -1} {
      set lenx [string length $text]
    } else {
      set lenx [string first = $text]
    }
    for {set i 0} {$i < $lenx } {incr i} {
      set x [string first [string index $text $i] $base64::charset]
      set y [expr ( $y << 6 ) + $x]
      if { [expr $i % 4 ] == 3}  {
        append decoded \
	  [binary format c [expr $y >> 16 ]]
	append decoded \
	  [binary format c [expr ( $y & 0x00ff00 ) >> 8 ]]
	append decoded \
	  [binary format c [expr ( $y & 0x0000ff ) ]]
	set y 0
      }
    }
    if { [expr $i % 4 ] == 3 } {
      set y [ expr $y >> 2 ]
	append decoded \
	  [binary format c [expr ( $y & 0x00ff00 ) >> 8 ]]
	append decoded \
	  [binary format c [expr ( $y & 0x0000ff ) ]]
    }
    if { [expr $i % 4 ] == 2 } {
      set y [ expr $y >> 4 ]
	append decoded \
	  [binary format c [expr ( $y & 0x0000ff ) ]]
    }
    return $decoded
  }
}

# adds a widget into a frame, automatically names it and packs it,
# returns the window path

proc vTcl:formCompound:add {cpd type args} {

	global widget 
	set varname [vTcl:rename $cpd]

	global ${varname}_count

	if {! [info exists ${varname}_count] } {

	   set ${varname}_count 0
	}

	eval set count $${varname}_count

	set window_name $cpd.i$count
	set cmd "$type $window_name $args"
	eval $cmd
	pack $window_name -side top -anchor nw

	incr ${varname}_count

	return $window_name
}

# transfers the value from var1 to var2 if save_and_validate = 0
# transfers the value from var2 to var1 if save_and_validate = 1

proc vTcl:data_exchange_var {var1 var2 save_and_validate} {

	global widget

	# hum... we need to be smart here
	if [string match *(*) $var1] {
	   regexp {([a-zA-Z]+)\(} $var1 matchAll arrayName
	   global $arrayName
	} else {
	   global $var1
	}

	global $var2

	eval set value1 $$var1

	eval set value2 $$var2

	if {$save_and_validate} {

	   set $var1 $value2
   
	} else {
 
	   set $var2 $value1
	}
}

# from "Effective Tcl/Tk Programming, by Mark Harrison, Michael McLennan"

proc vTcl:notebook_create {win} {

    global nbInfo

    frame $win -class Notebook
    pack propagate $win 0

    set nbInfo($win-count) 0
    set nbInfo($win-pages) ""
    set nbInfo($win-current) ""
    return $win
}

proc vTcl:notebook_display {win name} {

    global nbInfo

    set page ""
    if {[info exists nbInfo($win-page-$name)]} {
        set page $nbInfo($win-page-$name)
    } elseif {[winfo exists $win.page$name]} {
        set page $win.page$name
    }
    if {$page == ""} {
        error "bad notebook page \"$name\""
    }

    vTcl:notebook_fix_size $win

    if {$nbInfo($win-current) != ""} {
        pack forget $nbInfo($win-current)
    }
    pack $page -expand yes -fill both
    set nbInfo($win-current) $page
}

proc vTcl:notebook_fix_size {win} {

    global nbInfo

    update idletasks

    set maxw 0
    set maxh 0
    foreach page $nbInfo($win-pages) {
        set w [winfo reqwidth $page]
        if {$w > $maxw} {
            set maxw $w
        }
        set h [winfo reqheight $page]
        if {$h > $maxh} {
            set maxh $h
        }
    }
    set bd [$win cget -borderwidth]
    set maxw [expr $maxw+2*$bd]
    set maxh [expr $maxh+2*$bd]
    $win configure -width $maxw -height $maxh
}

proc vTcl:notebook_init {} {

    option add *Notebook.borderWidth 2 widgetDefault
    option add *Notebook.relief sunken widgetDefault
}

proc vTcl:notebook_page {win name} {

    global nbInfo

    set page "$win.page[incr nbInfo($win-count)]"
    lappend nbInfo($win-pages) $page
    set nbInfo($win-page-$name) $page

    frame $page

    if {$nbInfo($win-count) == 1} {
        after idle [list vTcl:notebook_display $win $name]
    }
    return $page
}

proc vTcl:tabnotebook_create {win} {
global tnInfo

    frame $win -class Tabnotebook
    canvas $win.tabs -highlightthickness 0
    pack $win.tabs -fill x

    vTcl:notebook_create $win.notebook
    pack $win.notebook -expand yes -fill both

    set tnInfo($win-tabs) ""
    set tnInfo($win-current) ""
    set tnInfo($win-pending) ""
    return $win
}

proc vTcl:tabnotebook_display {win name} {

    global tnInfo

    vTcl:notebook_display $win.notebook $name

    set normal [option get $win tabColor Color]
    $win.tabs itemconfigure tab -fill $normal

    set active [option get $win activeTabColor Color]
    $win.tabs itemconfigure tab-$name -fill $active
    $win.tabs raise $name

    set tnInfo($win-current) $name
}

proc vTcl:tabnotebook_init {} {

        option add *Tabnotebook.tabs.background #666666 widgetDefault
	option add *Tabnotebook.margin 6 widgetDefault
	option add *Tabnotebook.tabColor #a6a6a6 widgetDefault
	option add *Tabnotebook.activeTabColor #d9d9d9 widgetDefault
	option add *Tabnotebook.tabFont  -*-helvetica-bold-r-normal--*-120-* widgetDefault
}

proc vTcl:tabnotebook_page {win name} {

    global tnInfo

    set page [vTcl:notebook_page $win.notebook $name]
    lappend tnInfo($win-tabs) $name

    if {$tnInfo($win-pending) == ""} {
        set id [after idle [list vTcl:tabnotebook_refresh $win]]
        set tnInfo($win-pending) $id
    }
    return $page
}

proc vTcl:tabnotebook_refresh {win} {

    global tnInfo

    $win.tabs delete all

    set margin [option get $win margin Margin]
    set color [option get $win tabColor Color]
    set font [option get $win tabFont Font]
    set x 2
    set maxh 0
    set bevel 3

    foreach name $tnInfo($win-tabs) {
        set id [$win.tabs create text  [expr $x+$margin+2] [expr -0.5*$margin]  -anchor sw -text $name -font $font  -tags [list $name]]

        set bbox [$win.tabs bbox $id]
        set wd [expr [lindex $bbox 2]-[lindex $bbox 0]]
        set ht [expr [lindex $bbox 3]-[lindex $bbox 1]]
        if {$ht > $maxh} {
            set maxh $ht
        }

        $win.tabs create polygon 0 0  $x 0  [expr $x+$margin-$bevel] [expr -$ht-$margin+$bevel] [expr $x+$margin] [expr -$ht-$margin]  [expr $x+$margin+$wd] [expr -$ht-$margin] [expr $x+$margin+$wd+$bevel] [expr -$ht-$margin+$bevel] [expr $x+$wd+2*$margin] 0  2000 0  2000 10  0 10  -outline black -fill $color  -tags [list $name tab tab-$name]

        $win.tabs raise $id

        $win.tabs bind $name <ButtonPress-1>  [list vTcl:tabnotebook_display $win $name]

        set x [expr $x+$wd+2*$margin]
    }
    set height [expr $maxh+2*$margin]
    $win.tabs move all 0 $height

    $win.tabs configure -width $x -height [expr $height+4]

    if {$tnInfo($win-current) != ""} {
        vTcl:tabnotebook_display $win $tnInfo($win-current)
    } else {
        vTcl:tabnotebook_display $win [lindex $tnInfo($win-tabs) 0]
    }
    set tnInfo($win-pending) ""
}

# initializes the option database

vTcl:notebook_init
vTcl:tabnotebook_init

proc vTcl:safe_encode_string {s} {

	regsub -all \" $s %quote s
      regsub -all {\[} $s %leftbracket s
      regsub -all {\]} $s %rightbracket s
      regsub -all \{ $s %leftbrace s
      regsub -all \} $s %rightbrace s

	return $s
}

proc vTcl:safe_decode_string {s} {

	regsub -all %quote $s \" s
      regsub -all %leftbracket $s {[} s
      regsub -all %rightbracket $s {]} s
      regsub -all %leftbrace $s \{ s
      regsub -all %rightbrace $s \} s

	return $s
}
