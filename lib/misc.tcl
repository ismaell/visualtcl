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
    set s [string toupper [string range $string 0 0]]
    set l [string range $string 1 end]
    return "${s}${l}"
}

proc vTcl:lower_first {string} {
    set s [string tolower [string range $string 0 0]]
    set l [string range $string 1 end]
    return "${s}${l}"
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
			set noencase 1
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

proc vTcl:right_click {widget x y} {
    global vTcl
    $vTcl(gui,rc_menu) post $x $y
    grab $vTcl(gui,rc_menu)
    bind $vTcl(gui,rc_menu) <ButtonRelease> {
        grab release $vTcl(gui,rc_menu)
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
            vTcl:put_compound \$vTcl(cmpd:$i)
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
            vTcl:put_compound \$vTcl(syscmpd:$i)
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

proc vTcl:forAllMatches {w tags callback} {

	global vTcl
	scan [$w index end] %d numLines

	for {set i 1} {$i <= $numLines} {incr i} {
              
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

proc vTcl:syntax_color {w} {
	
	global vTcl

	set patterns ""

	foreach tag $vTcl(syntax,tags) {

		$w tag remove $tag 0.0 end	
	}
	
	vTcl:forAllMatches $w $vTcl(syntax,tags) vTcl:syntax_item
	
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
