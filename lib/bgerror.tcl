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

    # adds the :: namespace to the proc name if needed
    proc ::stack_trace::make_unique procname {
        if { ! [string match ::* $procname] } {
            return ::$procname
        } else {
            return $procname
        }
    }

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

        $widget($top,stack_trace_callstack) insert end $context
    }

    proc {::stack_trace::get_statement_at_level} {top index} {

        global widget [vTcl:rename $top.errorInfo]

        set context [$widget($top,stack_trace_callstack) get $index]
        set context [string trim $context]

        if { [string match "(file*)"  $context] } {

            regexp {"([^"]+)"} $context matchAll filename
            regexp {line ([0-9]+)} $context matchAll lineno

            set statement [::stack_trace::get_file_contents $filename]
            return [::stack_trace::get_bloc_instruction $statement $lineno]

        } elseif { [string match "(command bound to event)" $context] || 
                   [string match {("uplevel" body line 1)} $context] ||
                   [string match {(code segment*)} $context] ||
                   [string match {(menu invoke)} $context]  ||
                   [string match {("after" script)} $context] } {

            set statement \
               [::stack_trace::get_code_snippet_from_error_info \
                [vTcl:at [vTcl:rename $top.errorInfo] ] $context]

            return $statement

        } elseif { [string match "(procedure*)" $context] || 
                   [string match "(compiling body of proc*)" $context] } {

            regexp {"([^"]+)"} $context matchAll procname
            set procname [::stack_trace::make_unique $procname]

            if { [ info proc $procname ] != ""} {

                regexp {line ([0-9]+)} $context matchAll lineno

                return [::stack_trace::get_proc_instruction $procname $lineno]

            } else {

                return ""
            }

        } elseif [string match "(*arm line *)" $context] {

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

        } elseif { [string match {("if" then script line *)} $context] ||
                   [string match {("eval" body line *)} $context] ||
                   [string match {(in namespace eval "*" script line *) ||
                   [string match {("foreach" body line *)} $context] } $context] } {

            set statement \
                [::stack_trace::get_statement_at_level \
                $top [expr $index + 1] ]

            if {$statement != ""} {

                regexp {line ([0-9]+)} $context matchAll lineno

                return [::stack_trace::get_bloc_instruction $statement $lineno]

            } else {

                return ""
            }

        } else {

            return ""
        }
    }

    proc {::stack_trace::extract_code} {top} {

        global widget
        global [vTcl:rename $top.errorInfo]

        # get current selection in listbox

        set indices  [$widget($top,stack_trace_callstack) curselection]

        if { [llength $indices] == 0 } {return}

        set index [lindex $indices 0]

        set context [$widget($top,stack_trace_callstack) get $index]
        set context [string trim $context]

        if { [string match "(file*)"  $context] } {

            regexp {"([^"]+)"} $context matchAll filename
            regexp {line ([0-9]+)} $context matchAll lineno

            ::stack_trace::set_details $top [::stack_trace::get_file_contents $filename]
            vTcl:syntax_color $widget($top,stack_trace_details) 0 -1
            ::stack_trace::highlight_details $top $lineno

        } elseif { [string match "(procedure*)" $context] ||
                   [string match "(compiling body of proc*)" $context] } {

            regexp {"([^"]+)"} $context matchAll procname
            set procname [::stack_trace::make_unique $procname]

            if { [ info proc $procname ] != ""} {

                regexp {line ([0-9]+)} $context matchAll lineno

                ::stack_trace::set_details $top  \
                    [::stack_trace::get_proc_details $procname]
                vTcl:syntax_color $widget($top,stack_trace_details)  0 -1
                ::stack_trace::highlight_details $top [expr $lineno +1]

            } else {

                ::stack_trace::set_details $top "(no code available)"
            }

        } elseif { [string match "(command bound to event)" $context] ||
                   [string match {("uplevel" body line 1)} $context] ||
                   [string match {(code segment*)} $context]  ||
                   [string match {(menu invoke)} $context] ||
                   [string match {("after" script)} $context] } {

            set statement \
                  [::stack_trace::get_code_snippet_from_error_info \
                  [vTcl:at [vTcl:rename $top.errorInfo] ] $context]

            ::stack_trace::set_details $top $statement
            vTcl:syntax_color $widget($top,stack_trace_details)  0 -1

        } elseif [string match "(*arm line *)" $context] {

            set statement \
                [::stack_trace::get_statement_at_level $top [expr $index + 1] ]

            if {$statement != ""} {

                set armindex [lindex [string range $context 1 end] 0]
                set arms     [::stack_trace::get_switch_arms $statement]
                set arm      [::stack_trace::get_switch_arm $arms $armindex]

                regexp {([0-9]+)} [lindex $context 3] matchAll lineno

                ::stack_trace::set_details $top $arm
                vTcl:syntax_color $widget($top,stack_trace_details)  0 -1
                ::stack_trace::highlight_details $top $lineno

            } else {

                 ::stack_trace::set_details $top "(no code available)"
            }

        } elseif { [string match {("if" then script line *)} $context]  ||
                   [string match {("eval" body line *)} $context] ||
                   [string match {(in namespace eval "*" script line *)} $context] ||
                   [string match {("foreach" body line *)} $context] } {

            set statement \
                [::stack_trace::get_statement_at_level $top [expr $index + 1] ]

	      if {$statement != ""} {

	          regexp {line ([0-9]+)} $context matchAll lineno

                ::stack_trace::set_details $top $statement
                vTcl:syntax_color $widget($top,stack_trace_details)  0 -1
                ::stack_trace::highlight_details $top $lineno

            } else {

                ::stack_trace::set_details $top "(no code available)"
            }

        } elseif [string match {("if" test expression)} $context] {

	      set statement \
                [::stack_trace::get_statement_at_level $top [expr $index + 1] ]

            ::stack_trace::set_details $top $statement
            vTcl:syntax_color $widget($top,stack_trace_details)  0 -1
            ::stack_trace::highlight_details $top 1

        } else {
            ::stack_trace::set_details $top "(no code available)"
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

        set args [info args $procname]
        set body [info body $procname]

        return "proc $procname [list $args] \{\n$body\n\}"
    }

    proc {::stack_trace::get_proc_instruction} {procname lineno} {

        set body [info body $procname]

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

        set t $widget($top,stack_trace_details)

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

        # show top of stack
        focus $widget($top,stack_trace_callstack)
        $widget($top,stack_trace_callstack) selection clear 0 end
        $widget($top,stack_trace_callstack) selection set 0
        $widget($top,stack_trace_callstack) activate 0

        ::stack_trace::extract_code $top
    }

    proc {::stack_trace::reset_stack} {top} {

        # this procedure resets the call stack

        global widget

        $widget($top,stack_trace_callstack) delete 0 end
    }

    proc {::stack_trace::set_details} {top details} {

        global widget

        $widget($top,stack_trace_details) delete 0.1 end
        $widget($top,stack_trace_details) insert 0.1 $details
    }

    proc {::stack_trace::set_error} {top error} {

        global widget

        $widget($top,stack_trace_msg) delete 0.1 end
        $widget($top,stack_trace_msg) insert 0.1 $error
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

    proc {::stack_trace::move_level} {top up_or_down} {

        global widget
        set indices  [$widget($top,stack_trace_callstack) curselection]

        if { [llength $indices] == 0 } return

        set index [lindex $indices 0]
        set size  [$widget($top,stack_trace_callstack) index end]

        switch $up_or_down {
            up {
                if {$index > 0} {
                    incr index -1
                }
            }
            down {
                if {$index < $size - 1} {
                    incr index
                }
            }
        }

        $widget($top,stack_trace_callstack) selection clear 0 end
        $widget($top,stack_trace_callstack) selection set $index
        $widget($top,stack_trace_callstack) activate $index

        ::stack_trace::extract_code $top
    }

    variable boxIndex 0
}

proc vTclWindow.vTcl.stack_trace {base} {
    if {$base == ""} {
        set base .vTcl.stack_trace
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    global widget vTcl
    vTcl:DefineAlias $base stack_trace vTcl:Toplevel:WidgetProc "" 0
    vTcl:DefineAlias $base.cpd18.01.cpd20.03 stack_trace_msg vTcl:WidgetProc $base 0
    vTcl:DefineAlias $base.cpd18.02.cpd21.01.cpd22.01 stack_trace_callstack vTcl:WidgetProc $base 0
    vTcl:DefineAlias $base.cpd18.02.cpd21.02.cpd23.03 stack_trace_details vTcl:WidgetProc $base 0

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm transient $base .vTcl
    wm focusmodel $base passive
    wm geometry $base 575x446+139+158
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Stack trace"

    frame $base.cpd18 \
        -background #000000 -height 100 -highlightcolor #000000 -width 200
    frame $base.cpd18.01
    frame $base.cpd18.01.fratop
    label $base.cpd18.01.fratop.lab19 \
        -borderwidth 1 -relief flat -text Error
    ::vTcl::OkButton $base.cpd18.01.fratop.close -command "destroy $base"

    ScrolledWindow $base.cpd18.01.cpd20
    text $base.cpd18.01.cpd20.03 \
        -background #dcdcdc \
        -font [vTcl:font:get_font "vTcl:font8"] \
        -foreground #000000 -highlightbackground #ffffff \
        -highlightcolor #000000 -selectbackground #008080 \
        -selectforeground #ffffff
    $base.cpd18.01.cpd20 setwidget $base.cpd18.01.cpd20.03

    frame $base.cpd18.02
    frame $base.cpd18.02.cpd21 -background #000000
    frame $base.cpd18.02.cpd21.01

    ScrolledWindow $base.cpd18.02.cpd21.01.cpd22
    listbox $base.cpd18.02.cpd21.01.cpd22.01 -background white
    $base.cpd18.02.cpd21.01.cpd22 setwidget $base.cpd18.02.cpd21.01.cpd22.01

    bindtags $base.cpd18.02.cpd21.01.cpd22.01 \
        "Listbox $base.cpd18.02.cpd21.01.cpd22.01 $base all"
    bind $base.cpd18.02.cpd21.01.cpd22.01 <ButtonPress-1> \
        "focus %W"
    bind $base.cpd18.02.cpd21.01.cpd22.01 <ButtonRelease-1> \
        "::stack_trace::extract_code $base"
    bind $base.cpd18.02.cpd21.01.cpd22.01 <Key-Up> \
        "::stack_trace::extract_code $base"
    bind $base.cpd18.02.cpd21.01.cpd22.01 <Key-Down> \
        "::stack_trace::extract_code $base"

    frame $base.cpd18.02.cpd21.01.fra01
    button $base.cpd18.02.cpd21.01.fra01.but1 \
        -image icon_message.gif \
        -command "::stack_trace::set_details $base \[vTcl:at [vTcl:rename $base.errorInfo] \]"
    vTcl:set_balloon $base.cpd18.02.cpd21.01.fra01.but1 "Show errorInfo"
    button $base.cpd18.02.cpd21.01.fra01.but2 \
        -image up -width 20 -height 20 \
        -command "::stack_trace::move_level $base up"
    vTcl:set_balloon $base.cpd18.02.cpd21.01.fra01.but2 "Up one stack level"
    button $base.cpd18.02.cpd21.01.fra01.but3 \
        -image down -width 20 -height 20  \
        -command "::stack_trace::move_level $base down"
    vTcl:set_balloon $base.cpd18.02.cpd21.01.fra01.but3 "Down one stack level"
    frame $base.cpd18.02.cpd21.02 \
        -background #9900991B99FE -highlightbackground #dcdcdc \
        -highlightcolor #000000

    ScrolledWindow $base.cpd18.02.cpd21.02.cpd23 -background #dcdcdc
    text $base.cpd18.02.cpd21.02.cpd23.03 \
        -background #dcdcdc \
        -foreground #000000 -height 1 -highlightbackground #ffffff \
        -width 8 -wrap none
    $base.cpd18.02.cpd21.02.cpd23 setwidget $base.cpd18.02.cpd21.02.cpd23.03

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
    pack $base.cpd18.01.fratop \
        -in $base.cpd18.01 -fill x -side top
    pack $base.cpd18.01.fratop.lab19 \
        -in $base.cpd18.01.fratop -anchor center -expand 0 -fill x -side left
    pack $base.cpd18.01.fratop.close \
        -in $base.cpd18.01.fratop -side right

    pack $base.cpd18.01.cpd20 \
        -in $base.cpd18.01 -anchor center -expand 1 -fill both -side top
    pack $base.cpd18.01.cpd20.03

    place $base.cpd18.02 \
        -x 0 -y 0 -rely 1 -relwidth 1 -height -1 -relheight 0.7061 -anchor sw \
        -bordermode ignore
    pack $base.cpd18.02.cpd21 \
        -in $base.cpd18.02 -anchor center -expand 1 -fill both -side top
    place $base.cpd18.02.cpd21.01 \
        -x 0 -y 0 -width -1 -relwidth 0.3467 -relheight 1 -anchor nw \
        -bordermode ignore
    pack $base.cpd18.02.cpd21.01.fra01 \
        -in $base.cpd18.02.cpd21.01 -side top -fill x
    pack $base.cpd18.02.cpd21.01.fra01.but1 \
        -in $base.cpd18.02.cpd21.01.fra01 -side left
    pack $base.cpd18.02.cpd21.01.fra01.but2 \
        -in $base.cpd18.02.cpd21.01.fra01 -side left
    pack $base.cpd18.02.cpd21.01.fra01.but3 \
        -in $base.cpd18.02.cpd21.01.fra01 -side left

    pack $base.cpd18.02.cpd21.01.cpd22 \
        -in $base.cpd18.02.cpd21.01 -anchor center -expand 1 -fill both \
        -side top
    pack $base.cpd18.02.cpd21.01.cpd22.01

    place $base.cpd18.02.cpd21.02 \
        -x 0 -relx 1 -y 0 -width -1 -relwidth 0.6533 -relheight 1 -anchor ne \
        -bordermode ignore

    pack $base.cpd18.02.cpd21.02.cpd23 \
        -in $base.cpd18.02.cpd21.02 -anchor center -expand 1 -fill both \
        -side top
    pack $base.cpd18.02.cpd21.02.cpd23.03

    place $base.cpd18.02.cpd21.03 \
        -x 0 -relx 0.3467 -y 0 -rely 0.9 -width 10 -height 10 -anchor s \
        -bordermode ignore
    place $base.cpd18.03 \
        -x 0 -relx 0.9 -y 0 -rely 0.2939 -width 10 -height 10 -anchor e \
        -bordermode ignore

    vTcl:set_balloon $base.cpd18.01.fratop.close "Close"
}

proc vTclWindow.vTcl.bgerror {base} {
    if {$base == ""} {
        set base .vTcl.bgerror
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    global [vTcl:rename $base.error]
    global [vTcl:rename $base.errorInfo]

    eval set error     $[vTcl:rename $base.error]
    eval set errorInfo $[vTcl:rename $base.errorInfo]

    global widget
    vTcl:DefineAlias $base error_box vTcl:Toplevel:WidgetProc "" 0
    vTcl:DefineAlias $base.fra20.cpd23.03 error_box_text vTcl:WidgetProc $base 0

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel
    wm focusmodel $base passive
    wm geometry $base 333x248+196+396
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Error"
    wm protocol $base WM_DELETE_WINDOW "
            set [vTcl:rename $base.dialogStatus] ok
            destroy $base"
    
    frame $base.fra20 \
        -borderwidth 2
    label $base.fra20.lab21 \
        -bitmap error -borderwidth 0 \
        -padx 0 -pady 0 -relief raised -text label

    ScrolledWindow $base.fra20.cpd23
    text $base.fra20.cpd23.03 \
        -background #dcdcdc -font [vTcl:font:get_font "vTcl:font8"] \
        -foreground #000000 -height 1 -highlightbackground #ffffff \
        -highlightcolor #000000 -selectbackground #008080 \
        -selectforeground #ffffff -width 8 -wrap word
    $base.fra20.cpd23 setwidget $base.fra20.cpd23.03

    frame $base.fra25 \
        -borderwidth 2
    button $base.fra25.but26 \
        -padx 9 -text OK \
        -command "
            set [vTcl:rename $base.dialogStatus] ok
            destroy $base"
    button $base.fra25.but27 \
        -padx 9 -text {Skip messages} \
        -command "set [vTcl:rename $base.dialogStatus] skip
                  destroy $base"
    button $base.fra25.but28 \
        -padx 9 -text {Stack Trace...}  \
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
    pack $base.fra20.cpd23.03

    pack $base.fra25 \
        -in $base -anchor center -expand 0 -fill x -pady 4 -side top
    pack $base.fra25.but26 \
        -in $base.fra25 -anchor center -expand 1 -fill none -side left
    pack $base.fra25.but27 \
        -in $base.fra25 -anchor center -expand 1 -fill none -side left
    pack $base.fra25.but28 \
        -in $base.fra25 -anchor center -expand 1 -fill none -side left

    $widget($base,error_box_text) insert 1.0 $error
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

    if {$status != "skip"} {

        return
    }

    return -code break
}
