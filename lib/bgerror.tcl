##############################################################################
#
# bgerror.tcl - a replacement for the standard bgerror message box
#
# Copyright (C) 2000 Christian Gavin
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
#
##############################################################################

namespace eval ::stack_trace {

    # this procedure regularizes the stack trace returned in the error info
    #
    # normally, each level in the call stack is separated by (procedure 
    # blablah line 3) or ("b" arm line 76) etc.
    #
    # in some instances instead of the stack trace referring to a particular
    # location in a procedure eg. (procedure blablah line 3) it directly 
    # includes the code; example:
    #
    # invoked from within
    # "switch b {
    #		a {}
    #		b {bingo error here}
    #	}"
    #    invoked from within
    # "if {1} then {
    #	switch b {
    #		a {}
    #		b {bingo error here}
    #	}
    # }
    # "
    #
    # we transform it so that it becomes (we have added "(code segment 1)"):
    #
    # invoked from within
    # "switch b {
    #		a {}
    #		b {bingo error here}
    #	}"
    #    (code segment 1)
    #    invoked from within
    # "if {1} then {
    #	switch b {
    #		a {}
    #		b {bingo error here}
    #	}
    # }
    # "
    #
    # this makes it easier for the code here to parse the errorinfo; note that 
    # code segments are numbered in order to make the code simpler (hey, what
    # don't we do these days)

    proc {::stack_trace::regularize} {errorInfo} {

	set info_list [split $errorInfo \n]
	set last ""
	set new_list ""
	set num 1

	foreach item $info_list {

            if { [string match *\" $last] &&
                 [string trim $item] == "invoked from within" } {

                 lappend new_list "    (code segment $num)"
                 incr num
            }

            lappend new_list $item

            set last $item
	}

	return [join $new_list \n]
    }

    # returns the code from errorInfo between "invoked from within" and $line
    # for example, with line = "(command bound to event)" :
    #
    #    invoked from within
    #          "set foo $bar"
    #    (command bound to event)
    #
    # will return "set foo $bar"

    proc {::stack_trace::get_code_snippet_from_error_info} {errorInfo line} {

	set info_list [split $errorInfo \n]

	set index 0	
	set start 0
	set end [llength $info_list]
	set line [string trim $line]

	foreach item $info_list {

            set trimmed [string trim $item]

            if { $trimmed == "invoked from within" ||
                 $trimmed == "while executing" ||
                 $trimmed == "while compiling" } {
		set start [expr $index + 1]
            }

            if { $trimmed == $line } {
                set end [expr $index - 1]
                break
            }

            incr index
	}

	set returned [lrange $info_list $start $end]
	set returned [join $returned \n]

	# strip the quotes
	regexp {"(.*)"} $returned matchAll returned
	return $returned
    }

    proc {::stack_trace::get_file_contents} {filename} {

        if { ! [file exists $filename] } {
            return "(no code available)"
        }

        set in [open $filename r]
        set contents [read $in [file size $filename] ]
        close $in

        return $contents
    }

    proc {::stack_trace::add_stack} {top context} {

        global widget

        $top.$widget(child,stack_trace_callstack) insert end $context
    }

    proc {::stack_trace::get_statement_at_level} {top index} {

        global widget [vTcl:rename $top.errorInfo]

        set context [$top.$widget(child,stack_trace_callstack) get $index]
        set context [string trim $context]

        if { [string match "(file*)"  $context] } {

            regexp {"([^"]+)"} $context matchAll filename
            regexp {line ([0-9]+)} $context matchAll lineno

            set statement [::stack_trace::get_file_contents $filename]
            return [::stack_trace::get_bloc_instruction $statement $lineno]

        } elseif { [string match "(command bound to event)" $context] || 
                   [string match {("uplevel" body line 1)} $context] ||
                   [string match {(code segment*)} $context] } {

            set statement \
               [::stack_trace::get_code_snippet_from_error_info \
                [vTcl:at [vTcl:rename $top.errorInfo] ] $context]

            return $statement

        } elseif { [string match "(procedure*)" $context] || 
                   [string match "(compiling body of proc*)" $context] } {

            regexp {"([^"]+)"} $context matchAll procname

            if { [uplevel #0 "info proc $procname" ] != ""} {

                regexp {line ([0-9]+)} $context matchAll lineno

                return [::stack_trace::get_proc_instruction $procname $lineno]

            } else {

                return ""
            }

	} else {

            if [string match "(*arm line *)" $context] {

                set statement \
                    [::stack_trace::get_statement_at_level \
                    $top [expr $index + 1] ]

                if {$statement != ""} {

                    set armindex [lindex [string range $context 1 end] 0]
                    set arms     [::stack_trace::get_switch_arms $statement]
                    set arm      [::stack_trace::get_switch_arm $arms $armindex]

                    regexp {([0-9]+)} [lindex $context 3] matchAll lineno

                    return [::stack_trace::get_bloc_instruction $arm $lineno]

                } else {

                    return ""
                }

            } else {

                if [string match {("if" then script line *)} $context] {

                    set statement \
                        [::stack_trace::get_statement_at_level \
                        $top [expr $index + 1] ]

                    if {$statement != ""} {

                        regexp {([0-9]+)} [lindex $context 4] matchAll lineno

                        return [::stack_trace::get_bloc_instruction $statement $lineno]

                    } else {

                        return ""
                    }

                } else {

                    return ""
                }
            }
        }
    }

    proc {::stack_trace::extract_code} {top} {

        global widget
        global [vTcl:rename $top.errorInfo]

        # get current selection in listbox

        set indices  [$top.$widget(child,stack_trace_callstack) curselection]

        if { [llength $indices] == 0 } return

        set index [lindex $indices 0]

        set context [$top.$widget(child,stack_trace_callstack) get $index]
        set context [string trim $context]

        if { [string match "(file*)"  $context] } {

            regexp {"([^"]+)"} $context matchAll filename
            regexp {line ([0-9]+)} $context matchAll lineno

            ::stack_trace::set_details $top [::stack_trace::get_file_contents $filename]
            vTcl:syntax_color $top.$widget(child,stack_trace_details) 0 -1
            ::stack_trace::highlight_details $top $lineno

        } elseif { [string match "(procedure*)" $context] || 
                   [string match "(compiling body of proc*)" $context] } {

            regexp {"([^"]+)"} $context matchAll procname

            if { [uplevel #0 "info proc $procname" ] != ""} {

                regexp {line ([0-9]+)} $context matchAll lineno

                ::stack_trace::set_details $top  \
                    [::stack_trace::get_proc_details $procname]
                vTcl:syntax_color $top.$widget(child,stack_trace_details)  0 -1
                ::stack_trace::highlight_details $top [expr $lineno +1]

            } else {

                ::stack_trace::set_details $top "(no code available)"
            }

        } elseif { [string match "(command bound to event)" $context] || 
                   [string match {("uplevel" body line 1)} $context] ||
                   [string match {(code segment*)} $context] } {

            set statement \
                  [::stack_trace::get_code_snippet_from_error_info \
                  [vTcl:at [vTcl:rename $top.errorInfo] ] $context]

            ::stack_trace::set_details $top $statement
            vTcl:syntax_color $top.$widget(child,stack_trace_details)  0 -1

        } else {

            if [string match "(*arm line *)" $context] {

                set statement \
                    [::stack_trace::get_statement_at_level $top [expr $index + 1] ]

                if {$statement != ""} {

                    set armindex [lindex [string range $context 1 end] 0]
                    set arms     [::stack_trace::get_switch_arms $statement]
                    set arm      [::stack_trace::get_switch_arm $arms $armindex]

                    regexp {([0-9]+)} [lindex $context 3] matchAll lineno

                    ::stack_trace::set_details $top $arm
                    vTcl:syntax_color $top.$widget(child,stack_trace_details)  0 -1
                    ::stack_trace::highlight_details $top $lineno

                } else {

                    ::stack_trace::set_details $top "(no code available)"
                }

            } else {

                if [string match {("if" then script line *)} $context] {

	              set statement \
                          [::stack_trace::get_statement_at_level $top [expr $index + 1] ]

	              if {$statement != ""} {

	                  regexp {([0-9]+)} [lindex $context 4] matchAll lineno

                          ::stack_trace::set_details $top $statement
                          vTcl:syntax_color $top.$widget(child,stack_trace_details)  0 -1
                          ::stack_trace::highlight_details $top $lineno

                      } else {

                          ::stack_trace::set_details $top "(no code available)"
                      }

                } elseif [string match {("if" test expression)} $context] {

	              set statement \
                          [::stack_trace::get_statement_at_level $top [expr $index + 1] ]

                          ::stack_trace::set_details $top $statement
                          vTcl:syntax_color $top.$widget(child,stack_trace_details)  0 -1
                          ::stack_trace::highlight_details $top 1

                } else {
                    ::stack_trace::set_details $top "(no code available)"
                }
            }
        }
    }

    proc {::stack_trace::extract_error} {error} {

        global widget

        regexp (\[^\n\]+) $error matchAll message

        return $message
    }

    proc {::stack_trace::extract_stack} {error} {

        global widget

        set items [split $error \n]
        set result ""

        foreach item $items {

        if [string match (*) [string trim $item] ] {
            lappend result [string trim $item]
        }
        }

        return $result
    }

    proc {::stack_trace::get_proc_details} {procname} {

        global widget

        set args [uplevel #0 "info args $procname"]
        set body [uplevel #0 "info body $procname"]

        return "proc $procname [list $args] \{\n$body\n\}"
    }

    proc {::stack_trace::get_proc_instruction} {procname lineno} {

        set body [uplevel #0 "info body $procname"]

        return [::stack_trace::get_bloc_instruction $body $lineno]
    }

    proc {::stack_trace::get_bloc_instruction} {body lineno} {

        set body [split $body \n]
        set size [llength $body]

	    set line [lindex $body [expr $lineno - 1] ]

        while {! [info complete $line] } {

            incr lineno

            # end of bloc reached?
            if {$lineno == $size} {
               break
            }

            append line \n
            append line [lindex $body [expr $lineno - 1] ]
        }

        return $line
    }

    proc {::stack_trace::highlight_details} {top lineno} {

        global widget vTcl

        set t $top.$widget(child,stack_trace_details)

        foreach tag $vTcl(syntax,tags) {

            $t tag remove $tag $lineno.0 [expr $lineno + 1].0
        }

        $t tag add vTcl:highlight $lineno.0 [expr $lineno + 1].0

        $t tag configure vTcl:highlight  \
            -relief raised  \
            -background white \
            -foreground black  \
            -borderwidth 2

        $t see $lineno.0
    }

    proc {::stack_trace::init_bgerror} {top error errorInfo} {

        global widget

        ::stack_trace::set_error $top  [::stack_trace::extract_error $errorInfo]

        set stack [::stack_trace::extract_stack $errorInfo]

        ::stack_trace::reset_stack $top

        foreach context $stack {
        ::stack_trace::add_stack $top $context
        }

        # save for future use
        global [vTcl:rename $top.errorInfo]
        set [vTcl:rename $top.errorInfo] $errorInfo
    }

    proc {::stack_trace::reset_stack} {top} {

        # this procedure resets the call stack

        global widget

        $top.$widget(child,stack_trace_callstack) delete 0 end
    }

    proc {::stack_trace::set_details} {top details} {

        global widget

        $top.$widget(child,stack_trace_details) delete 0.1 end
        $top.$widget(child,stack_trace_details) insert 0.1 $details
    }

    proc {::stack_trace::set_error} {top error} {

        global widget

        $top.$widget(child,stack_trace_msg) delete 0.1 end
        $top.$widget(child,stack_trace_msg) insert 0.1 $error
    }

    # return a list such as {pattern body pattern body ...} from
    # a complete switch statement

    proc {::stack_trace::get_switch_arms} {statement} {

       if { [lindex $statement 0] != "switch"} {
           return ""
       }

       set length [llength $statement]
       set index 1
       set item ""

       # start with the options

	   while {$index < $length} {

          set item [lindex $statement $index]
          if [regexp -- {-[a-z]+} $item ] {

             incr index
             continue
          }

          if {$item == "--"} {
             incr index
          }

          # we have reached the end of options
          break
       }

       # now skips the string to switch
       incr index

       # one bloc ?
       if {$index == $length - 1} {

          return [lindex $statement $index]
       } else {

          return [lrange $statement $index [expr $length - 1] ]
       }
    }

    # returns the code for a given arm of a switch statement, using
    # the arms returned by the previous procedure

    proc {::stack_trace::get_switch_arm} {arms arm} {

        set length [llength $arms]

        for {set index 0} \
            {$index < $length} \
            {set index [expr $index + 2] } {

            if { [lindex $arms $index] == $arm } {
                return [lrange $arms $index [expr $index + 1] ]
            }
        }

        # nope
        return ""
    }

    variable boxIndex 0
}

proc vTclWindow.vTcl.stack_trace {base {container 0}} {
    if {$base == ""} {
        set base .vTcl.stack_trace
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }

    global widget vTcl
    set widget(rev,$base) {stack_trace}
    set {widget(stack_trace)} "$base"
    set {widget(child,stack_trace)} ""
    set widget(rev,$base.cpd18.01.cpd20.03) {stack_trace_msg}
    set {widget(stack_trace_msg)} "$base.cpd18.01.cpd20.03"
    set {widget(child,stack_trace_msg)} "cpd18.01.cpd20.03"
    set widget(rev,$base.cpd18.02.cpd21.01.cpd22.01) {stack_trace_callstack}
    set {widget(stack_trace_callstack)} "$base.cpd18.02.cpd21.01.cpd22.01"
    set {widget(child,stack_trace_callstack)} "cpd18.02.cpd21.01.cpd22.01"
    set widget(rev,$base.cpd18.02.cpd21.02.cpd23.03) {stack_trace_details}
    set {widget(stack_trace_details)} "$base.cpd18.02.cpd21.02.cpd23.03"
    set {widget(child,stack_trace_details)} "cpd18.02.cpd21.02.cpd23.03"

    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    toplevel $base -class Toplevel \
        -background #dcdcdc -highlightbackground #dcdcdc \
        -highlightcolor #000000
    wm focusmodel $base passive
    wm geometry $base 585x456+139+158
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Stack trace"
    }
    frame $base.cpd18 \
        -background #000000 -height 100 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -width 200
    frame $base.cpd18.01 \
        -background #9900991B99FE -highlightbackground #dcdcdc \
        -highlightcolor #000000
    label $base.cpd18.01.lab19 \
        -background #ffffff -borderwidth 1 -foreground #000000 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -relief raised \
        -text Error
    frame $base.cpd18.01.cpd20 \
        -background #dcdcdc -borderwidth 1 -height 30 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -relief raised \
        -width 30
    scrollbar $base.cpd18.01.cpd20.01 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.cpd18.01.cpd20.03 xview" -cursor left_ptr \
        -highlightbackground #dcdcdc -highlightcolor #000000 -orient horiz \
        -troughcolor #dcdcdc 
    scrollbar $base.cpd18.01.cpd20.02 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.cpd18.01.cpd20.03 yview" -cursor left_ptr \
        -highlightbackground #dcdcdc -highlightcolor #000000 -orient vert \
        -troughcolor #dcdcdc 
    text $base.cpd18.01.cpd20.03 \
        -background #dcdcdc \
        -font [vTcl:font:get_font "vTcl:font8"] \
        -foreground #000000 -height 1 -highlightbackground #ffffff \
        -highlightcolor #000000 -selectbackground #008080 \
        -selectforeground #ffffff -width 8 \
        -xscrollcommand "$base.cpd18.01.cpd20.01 set" \
        -yscrollcommand "$base.cpd18.01.cpd20.02 set"
    frame $base.cpd18.02 \
        -background #9900991B99FE -highlightbackground #dcdcdc \
        -highlightcolor #000000
    frame $base.cpd18.02.cpd21 \
        -background #000000 -height 100 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -width 200
    frame $base.cpd18.02.cpd21.01 \
        -background #9900991B99FE -highlightbackground #dcdcdc \
        -highlightcolor #000000
    frame $base.cpd18.02.cpd21.01.cpd22 \
        -background #dcdcdc -borderwidth 1 -height 30 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -relief raised \
        -width 30
    listbox $base.cpd18.02.cpd21.01.cpd22.01 \
        -background #dcdcdc \
        -font -Adobe-Helvetica-Medium-R-Normal-*-*-120-*-*-*-*-*-* \
        -foreground #000000 -highlightbackground #ffffff \
        -highlightcolor #000000 -selectbackground #008080 \
        -selectforeground #ffffff \
        -xscrollcommand "$base.cpd18.02.cpd21.01.cpd22.02 set" \
        -yscrollcommand "$base.cpd18.02.cpd21.01.cpd22.03 set"
    bind $base.cpd18.02.cpd21.01.cpd22.01 <ButtonRelease-1> {
        set window %W
        set components [split $window .]
        set components [lrange $components 0 2]

        ::stack_trace::extract_code [join $components .]
    }
    scrollbar $base.cpd18.02.cpd21.01.cpd22.02 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.cpd18.02.cpd21.01.cpd22.01 xview" -cursor left_ptr \
        -highlightbackground #dcdcdc -highlightcolor #000000 -orient horiz \
        -troughcolor #dcdcdc 
    scrollbar $base.cpd18.02.cpd21.01.cpd22.03 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.cpd18.02.cpd21.01.cpd22.01 yview" -cursor left_ptr \
        -highlightbackground #dcdcdc -highlightcolor #000000 -orient vert \
        -troughcolor #dcdcdc 
    button $base.cpd18.02.cpd21.01.but1 \
        -text "show errorInfo" \
        -command "::stack_trace::set_details $base \[vTcl:at [vTcl:rename $base.errorInfo] \]"
    frame $base.cpd18.02.cpd21.02 \
        -background #9900991B99FE -highlightbackground #dcdcdc \
        -highlightcolor #000000
    frame $base.cpd18.02.cpd21.02.cpd23 \
        -background #dcdcdc -borderwidth 1 -height 30 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -relief raised \
        -width 30
    scrollbar $base.cpd18.02.cpd21.02.cpd23.01 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.cpd18.02.cpd21.02.cpd23.03 xview" -cursor left_ptr \
        -highlightbackground #dcdcdc -highlightcolor #000000 -orient horiz \
        -troughcolor #dcdcdc 
    scrollbar $base.cpd18.02.cpd21.02.cpd23.02 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.cpd18.02.cpd21.02.cpd23.03 yview" -cursor left_ptr \
        -highlightbackground #dcdcdc -highlightcolor #000000 -orient vert \
        -troughcolor #dcdcdc 
    text $base.cpd18.02.cpd21.02.cpd23.03 \
        -background #dcdcdc -font $vTcl(pr,font_fixed) \
        -foreground #000000 -height 1 -highlightbackground #ffffff \
        -highlightcolor #000000 -selectbackground #008080 \
        -selectforeground #ffffff -width 8 -wrap none \
        -xscrollcommand "$base.cpd18.02.cpd21.02.cpd23.01 set" \
        -yscrollcommand "$base.cpd18.02.cpd21.02.cpd23.02 set"
    frame $base.cpd18.02.cpd21.03 \
        -background #ff0000 -borderwidth 2 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -relief raised
    bind $base.cpd18.02.cpd21.03 <B1-Motion> {
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
    frame $base.cpd18.03 \
        -background #ff0000 -borderwidth 2 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -relief raised
    bind $base.cpd18.03 <B1-Motion> {
        set root [ split %W . ]
    set nb [ llength $root ]
    incr nb -1
    set root [ lreplace $root $nb $nb ]
    set root [ join $root . ]
    set height [ winfo height $root ].0

    set val [ expr (%Y - [winfo rooty $root]) /$height ]

    if { $val >= 0 && $val <= 1.0 } {

        place $root.01 -relheight $val
        place $root.03 -rely $val
        place $root.02 -relheight [ expr 1.0 - $val ]
    }
    }
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.cpd18 \
        -in $base -anchor center -expand 1 -fill both -side top
    place $base.cpd18.01 \
        -x 0 -y 0 -relwidth 1 -height -1 -relheight 0.2939 -anchor nw \
        -bordermode ignore
    pack $base.cpd18.01.lab19 \
        -in $base.cpd18.01 -anchor center -expand 0 -fill x -side top
    pack $base.cpd18.01.cpd20 \
        -in $base.cpd18.01 -anchor center -expand 1 -fill both -side top
    grid columnconf $base.cpd18.01.cpd20 0 -weight 1
    grid rowconf $base.cpd18.01.cpd20 0 -weight 1
    grid $base.cpd18.01.cpd20.01 \
        -in $base.cpd18.01.cpd20 -column 0 -row 1 -columnspan 1 -rowspan 1 \
        -sticky ew
    grid $base.cpd18.01.cpd20.02 \
        -in $base.cpd18.01.cpd20 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns
    grid $base.cpd18.01.cpd20.03 \
        -in $base.cpd18.01.cpd20 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw
    place $base.cpd18.02 \
        -x 0 -y 0 -rely 1 -relwidth 1 -height -1 -relheight 0.7061 -anchor sw \
        -bordermode ignore
    pack $base.cpd18.02.cpd21 \
        -in $base.cpd18.02 -anchor center -expand 1 -fill both -side top
    place $base.cpd18.02.cpd21.01 \
        -x 0 -y 0 -width -1 -relwidth 0.3467 -relheight 1 -anchor nw \
        -bordermode ignore
    pack $base.cpd18.02.cpd21.01.cpd22 \
        -in $base.cpd18.02.cpd21.01 -anchor center -expand 1 -fill both \
        -side top
    grid columnconf $base.cpd18.02.cpd21.01.cpd22 0 -weight 1
    grid rowconf $base.cpd18.02.cpd21.01.cpd22 0 -weight 1
    grid $base.cpd18.02.cpd21.01.cpd22.01 \
        -in $base.cpd18.02.cpd21.01.cpd22 -column 0 -row 0 -columnspan 1 \
        -rowspan 1 -sticky nesw
    grid $base.cpd18.02.cpd21.01.cpd22.02 \
        -in $base.cpd18.02.cpd21.01.cpd22 -column 0 -row 1 -columnspan 1 \
        -rowspan 1 -sticky ew
    grid $base.cpd18.02.cpd21.01.cpd22.03 \
        -in $base.cpd18.02.cpd21.01.cpd22 -column 1 -row 0 -columnspan 1 \
        -rowspan 1 -sticky ns
    pack $base.cpd18.02.cpd21.01.but1 \
        -in $base.cpd18.02.cpd21.01 -side bottom -fill x
    place $base.cpd18.02.cpd21.02 \
        -x 0 -relx 1 -y 0 -width -1 -relwidth 0.6533 -relheight 1 -anchor ne \
        -bordermode ignore
    pack $base.cpd18.02.cpd21.02.cpd23 \
        -in $base.cpd18.02.cpd21.02 -anchor center -expand 1 -fill both \
        -side top
    grid columnconf $base.cpd18.02.cpd21.02.cpd23 0 -weight 1
    grid rowconf $base.cpd18.02.cpd21.02.cpd23 0 -weight 1
    grid $base.cpd18.02.cpd21.02.cpd23.01 \
        -in $base.cpd18.02.cpd21.02.cpd23 -column 0 -row 1 -columnspan 1 \
        -rowspan 1 -sticky ew
    grid $base.cpd18.02.cpd21.02.cpd23.02 \
        -in $base.cpd18.02.cpd21.02.cpd23 -column 1 -row 0 -columnspan 1 \
        -rowspan 1 -sticky ns
    grid $base.cpd18.02.cpd21.02.cpd23.03 \
        -in $base.cpd18.02.cpd21.02.cpd23 -column 0 -row 0 -columnspan 1 \
        -rowspan 1 -sticky nesw
    place $base.cpd18.02.cpd21.03 \
        -x 0 -relx 0.3467 -y 0 -rely 0.9 -width 10 -height 10 -anchor s \
        -bordermode ignore
    place $base.cpd18.03 \
        -x 0 -relx 0.9 -y 0 -rely 0.2939 -width 10 -height 10 -anchor e \
        -bordermode ignore
}

proc vTclWindow.vTcl.bgerror {base {container 0}} {
    if {$base == ""} {
        set base .vTcl.bgerror
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }

    global [vTcl:rename $base.error]
    global [vTcl:rename $base.errorInfo]

    eval set error     $[vTcl:rename $base.error]
    eval set errorInfo $[vTcl:rename $base.errorInfo]

    global widget
    set widget(rev,$base) {error_box}
    set {widget(error_box)} "$base"
    set {widget(child,error_box)} ""
    set widget(rev,$base.fra20.cpd23.03) {error_box_text}
    set {widget(error_box_text)} "$base.fra20.cpd23.03"
    set {widget(child,error_box_text)} "fra20.cpd23.03"

    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    toplevel $base -class Toplevel \
        -background #dcdcdc -highlightbackground #dcdcdc \
        -highlightcolor #000000
    wm focusmodel $base passive
    wm geometry $base 333x248+196+396
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Error"
    }
    frame $base.fra20 \
        -background #dcdcdc -borderwidth 2 -height 75 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -width 125
    label $base.fra20.lab21 \
        -background #dcdcdc -bitmap error -borderwidth 0 -foreground #000000 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -padx 0 -pady 0 \
        -relief raised -text label
    frame $base.fra20.cpd23 \
        -background #dcdcdc -height 30 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -width 30
    scrollbar $base.fra20.cpd23.02 \
        -activebackground #dcdcdc -background #dcdcdc \
        -command "$base.fra20.cpd23.03 yview" -cursor left_ptr \
        -highlightbackground #dcdcdc -highlightcolor #000000 -orient vert \
        -troughcolor #dcdcdc
    text $base.fra20.cpd23.03 \
        -background #dcdcdc -font [vTcl:font:get_font "vTcl:font8"] \
        -foreground #000000 -height 1 -highlightbackground #ffffff \
        -highlightcolor #000000 -selectbackground #008080 \
        -selectforeground #ffffff -width 8 -wrap word \
        -yscrollcommand "$base.fra20.cpd23.02 set"
    frame $base.fra25 \
        -background #dcdcdc -borderwidth 2 -height 75 \
        -highlightbackground #dcdcdc -highlightcolor #000000 -width 125
    button $base.fra25.but26 \
        -activebackground #dcdcdc -activeforeground #000000 \
        -background #dcdcdc -foreground #000000 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -padx 9 -pady 3 -text OK \
        -command "
            set [vTcl:rename $base.dialogStatus] ok
            destroy $base"
    button $base.fra25.but27 \
        -activebackground #dcdcdc -activeforeground #000000 \
        -background #dcdcdc -foreground #000000 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -padx 9 -pady 3 -text {Skip messages} \
        -command "set [vTcl:rename $base.dialogStatus] skip
                  destroy $base"
    button $base.fra25.but28 \
        -activebackground #dcdcdc -activeforeground #000000 \
        -background #dcdcdc -foreground #000000 -highlightbackground #dcdcdc \
        -highlightcolor #000000 -padx 9 -pady 3 -text {Stack Trace...}  \
        -command "
            set newtop .vTcl.stack_trace$::stack_trace::boxIndex
            vTclWindow.vTcl.stack_trace \$newtop
            ::stack_trace::init_bgerror \$newtop [list $error] [list $errorInfo]
            set [vTcl:rename $base.dialogStatus] ok
            after idle \{destroy $base\}"

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra20 \
        -in $base -anchor center -expand 1 -fill both -pady 2 -side top
    pack $base.fra20.lab21 \
        -in $base.fra20 -anchor e -expand 0 -fill none -padx 5 -side left
    pack $base.fra20.cpd23 \
        -in $base.fra20 -anchor center -expand 1 -fill both -padx 2 -side top
    grid columnconf $base.fra20.cpd23 0 -weight 1
    grid rowconf $base.fra20.cpd23 0 -weight 1
    grid $base.fra20.cpd23.02 \
        -in $base.fra20.cpd23 -column 1 -row 0 -columnspan 1 -rowspan 1 \
        -sticky ns
    grid $base.fra20.cpd23.03 \
        -in $base.fra20.cpd23 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw
    pack $base.fra25 \
        -in $base -anchor center -expand 0 -fill x -pady 4 -side top
    pack $base.fra25.but26 \
        -in $base.fra25 -anchor center -expand 1 -fill none -side left
    pack $base.fra25.but27 \
        -in $base.fra25 -anchor center -expand 1 -fill none -side left
    pack $base.fra25.but28 \
        -in $base.fra25 -anchor center -expand 1 -fill none -side left

    $base.$widget(child,error_box_text) insert 1.0 $error
}

proc bgerror {error} {

    global widget errorInfo

    incr ::stack_trace::boxIndex

    set top ".vTcl.bgerror$::stack_trace::boxIndex"

    global [vTcl:rename $top.error]
    global [vTcl:rename $top.errorInfo]
    global [vTcl:rename $top.dialogStatus]

    set [vTcl:rename $top.error] $error
    set [vTcl:rename $top.errorInfo] [::stack_trace::regularize $errorInfo]
    set [vTcl:rename $top.dialogStatus] 0

    vTclWindow.vTcl.bgerror $top

	vwait [vTcl:rename $top.dialogStatus]

    eval set status $[vTcl:rename $top.dialogStatus]

    # don't leak memory, please !
    unset [vTcl:rename $top.error]
    unset [vTcl:rename $top.errorInfo]
    unset [vTcl:rename $top.dialogStatus]

    if {$status == "skip"} {

		return -code break

    } else {

        return
    }
}

