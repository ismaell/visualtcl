##############################################################################
#
# lib_itcl.tcl - itcl widget support library
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
#
# Architecture by Stewart Allen
# Implementation by James Kramer usinge ideas from
# Kenneth H. Cox <kcox@senteinc.com>
#
# Maintained by Christian Gavin:
#   added support for more widgets
#   added support for new image/font managers
#   made sure children are not dumped and not viewed in the widget tree
#

# Initializes this library
#

# @@change by Christian Gavin 3/6/2000
# Itcl/tk and IWidgets support

catch {
    package require Itcl 3.0
    namespace import itcl::*
    package require Itk 3.0
    package require Iwidgets 3.0
    namespace import iwidgets::entryfield
    namespace import iwidgets::spinint
    namespace import iwidgets::combobox
    namespace import iwidgets::scrolledlistbox
    namespace import iwidgets::calendar
    namespace import iwidgets::dateentry
    namespace import iwidgets::scrolledhtml
    namespace import iwidgets::toolbar
    namespace import iwidgets::feedback
    namespace import iwidgets::optionmenu
    namespace import iwidgets::hierarchy
    namespace import iwidgets::buttonbox
    namespace import iwidgets::checkbox
    namespace import iwidgets::radiobox
    namespace import iwidgets::tabnotebook
    namespace import iwidgets::panedwindow
    namespace import iwidgets::scrolledtext
} errorText
vTcl:log $errorText

# @@end_change

proc vTcl:widget:lib:lib_itcl {args} {

    global vTcl
    #
    # see if we can define a class. if not, return
    #

    # @@change by Christian Gavin 3/6/2000

    # added namespace for itcl because some versions of itcl do
    # not declare classes with the full namespaces specified and assume
    # the namespace itcl has been exported

    if {[catch {itcl::class itcltest { constructor {args} {}}}]} {
        lappend vTcl(w,libsnames) {(not detected) [Incr Tcl/Tk] MegaWidgets Support Library}
        return
    }

    # @@end_change

    # @@change by Christian Gavin 3/6/2000
    # vTcl:log "Support for Itcl activated"

    # @@end_change

    # setup required variables
    vTcl:lib_itcl:setup

    # add items to toolbar

    # @@change by Christian Gavin 3/6/2000
    # added scrolledlistbox to the list of classes supported
    # added calendar
    # added dateentry
    # added scrolledhtml
    # added toolbar
    # added feedback
    # added optionmenu
    # added hierarchy
    # added buttonbox
    # added checkbox
    # added radiobox
    # added tabnotebook
    # added panedwindow
    # added scrolledtext
    # @@end_change

    foreach i {
        entryfield
        spinint
        combobox
        scrolledlistbox
        calendar
        dateentry
        scrolledhtml
        toolbar
        feedback
        optionmenu
        hierarchy
        buttonbox
        checkbox
        radiobox
        tabnotebook
        panedwindow
        scrolledtext
    } {
        set img_file [file join $vTcl(VTCL_HOME) images icon_$i.gif]
        if {![file exists $img_file]} {
            set img_file [file join $vTcl(VTCL_HOME) images unknown.gif]
        }
        image create photo "ctl_$i" -file $img_file
        vTcl:toolbar_add $i $i ctl_$i ""

	append vTcl(proc,ignore) "|$i"
    }
    # The Widget Browser needs images for all itcl classes.
    # The images need to be called, e.g. ctl_itclNoteBookFrame.
    # Don't put these in the toolbar, because they are not commands,
    # only classes.

    # announce ourselves!
    lappend vTcl(w,libsnames) {[Incr Tcl/Tk] MegaWidgets Support Library}
}

proc vTcl:lib_itcl:setup {} {
	global vTcl

	#
	# additional attributes to set on insert
	#
	set vTcl(scrolledlistbox,insert)    "-labeltext {Label:} "
	set vTcl(combobox,insert)           "-labeltext {Label:} "
	set vTcl(entryfield,insert)         "-labeltext {Label:} "
	set vTcl(spinint,insert)            "-labeltext {Label:} -range {0 10} -step 1"
	set vTcl(calendar,insert)	    ""
	set vTcl(dateentry,insert)	    "-labeltext {Selected date:}"
	set vTcl(scrolledhtml,insert)       ""
	set vTcl(toolbar,insert)            ""
	set vTcl(feedback,insert)           "-labeltext {Percent complete:}"
	set vTcl(optionmenu,insert)         "-labeltext {Select option:}"
	set vTcl(hierarchy,insert)          ""
	set vTcl(buttonbox,insert)          ""
	set vTcl(checkbox,insert)           ""
	set vTcl(radiobox,insert)           ""
	set vTcl(tabnotebook,insert)        ""
	set vTcl(panedwindow,insert)        ""
	set vTcl(scrolledtext,insert)       ""

	#
	# add to procedure, var, bind regular expressions
	#
	#
	# add to valid class list
	#
	lappend vTcl(classes) \
		Entryfield \
		Spinint \
		Combobox \
                Scrolledlistbox \
                Calendar \
                Dateentry \
                Scrolledhtml \
                Toolbar \
                Feedback \
                Optionmenu \
                Hierarchy \
                Buttonbox \
                Checkbox \
                Radiobox \
                Tabnotebook \
                Panedwindow \
                Scrolledtext

	# @@change by Christian Gavin 3/7/2000
	# list of megawidgets whose children are not visible by Vtcl

	lappend vTcl(megaWidget) Entryfield \
				 Spinint \
				 Combobox \
				 Scrolledlistbox \
				 Calendar \
				 Dateentry \
				 Scrolledhtml \
				 Toolbar \
				 Feedback \
				 Optionmenu \
				 Hierarchy \
				 Buttonbox \
				 Checkbox \
				 Radiobox \
				 Tabnotebook \
				 Panedwindow \
				 Scrolledtext

	# @@end_change

	#
	# register additional options that might be on itcl widgets,
	# and the option information that the Attribute Editor needs.
	#
	lappend vTcl(opt,list) \
	        -fixed \
	        -range \
	        -step \
	        -validate \
		-vcmd \
	        -labeltext \
	        -labelpos \
	        -textfont \
	        -items \
	        -decrement \
	        -increment \
	        -listheight \
	        -focuscommand \
	        -invalid \
	        -textbackground \
	        -arrowrelief \
	        -completion \
	        -dropdown \
	        -margin \
	        -popupcursor \
	        -selectioncommand \
	        -unique \
	        -dblclickcommand \
	        -visibleitems \
	        -alink \
	        -link \
	        -linkhighlight \
	        -balloonbackground \
	        -balloondelay1 \
	        -balloondelay2 \
	        -balloonfont \
	        -balloonforeground \
	        -helpvariable \
	        -barcolor \
	        -barheight \
	        -steps \
	        -troughcolor \
	        -clicktime \
	        -cyclicon \
	        -alwaysquery \
	        -closedicon \
	        -expanded \
	        -filter \
	        -iconcommand \
	        -markbackground \
	        -markforeground \
	        -menucursor \
	        -nodeicon \
	        -openicon \
	        -querycommand \
	        -textbackground \
	        -textfont \
	        -angle \
	        -backdrop \
	        -bevelamount \
	        -equaltabs \
	        -gap \
	        -raiseselect \
	        -start \
	        -tabbackground \
	        -tabborders \
	        -tabforeground \
	        -tabpos \
	        -sashborderwidth \
	        -sashcursor \
	        -sashheight \
	        -sashindent \
	        -sashwidth \
	        -thickness \
	        -sbwidth \
	        -clientdata \
	        -hscrollmode \
	        -vscrollmode \
	        -labelimage

	set vTcl(opt,-labelimage)     { {Label Img}        {}       image   {} }
	set vTcl(opt,-hscrollmode)    { {Horz Scroll}      {}
	                                choice {static dynamic none} }
	set vTcl(opt,-vscrollmode)    { {Vert Scroll}      {}
	                                choice {static dynamic none} }
	set vTcl(opt,-clientdata)     { {Client Data}      {}       type    {} }
	set vTcl(opt,-sbwidth)        { {ScrollBar Width}  {}       type    {} }
	set vTcl(opt,-sashborderwidth) { {Sash Bd Width}   {}       type    {} }
	set vTcl(opt,-sashcursor)     { {Sash Cursor}      {}       type    {} }
	set vTcl(opt,-sashheight)     { {Sash Height}      {}       type    {} }
	set vTcl(opt,-sashindent)     { {Sash Indent}      {}       type    {} }
	set vTcl(opt,-sashwidth)      { {Sash Width}       {}       type    {} }
	set vTcl(opt,-thickness)      { {Sep. Thickness}   {}       type    {} }
	set vTcl(opt,-angle)          { {Angle}            {}       type    {} }
	set vTcl(opt,-backdrop)       { {Backdrop Color}   Colors   color   {} }
	set vTcl(opt,-bevelamount)    { {Bevel amount}     {}       type    {} }
	set vTcl(opt,-equaltabs)      { {Equal tabs}       {}       boolean {0 1} }
	set vTcl(opt,-gap)            { {Overlap}          {}       type    {} }
	set vTcl(opt,-raiseselect)    { {Raise select}     {}       boolean {0 1} }
	set vTcl(opt,-start)          { {Start}            {}       type    {} }
	set vTcl(opt,-tabbackground)  { {Tab BgColor}      Colors   color   {} }
	set vTcl(opt,-tabborders)     { {Tab borders}      {}       boolean {0 1} }
	set vTcl(opt,-tabforeground)  { {Tab FgColor}      Colors   color   {} }
	set vTcl(opt,-tabpos)         { {Tab pos}          {}       choice {n s e w} }
	set vTcl(opt,-alwaysquery)    { {Always Query}     {}       boolean {0 1} }
	set vTcl(opt,-closedicon)     { {Closed icon}      {}       image   {} }
	set vTcl(opt,-expanded)       { {Expanded}         {}       boolean {0 1} }
	set vTcl(opt,-filter)         { {Filter}           {}       boolean {0 1} }
	set vTcl(opt,-iconcommand)    { {Icon Cmd}         {}       command {} }
	set vTcl(opt,-markbackground) { {Mark BgColor}     Colors   color   {} }
	set vTcl(opt,-markforeground) { {Mark FgColor}     Colors   color   {} }
	set vTcl(opt,-menucursor)     { {Menu Cursor}      {}       type    {} }
	set vTcl(opt,-nodeicon)       { {Node Icon}        {}       image   {} }
	set vTcl(opt,-openicon)       { {Open Icon}        {}       image   {} }
	set vTcl(opt,-querycommand)   { {Query Cmd}        {}       command {} }
	set vTcl(opt,-textbackground) { {Text BgColor}     Colors   color   {} }
	set vTcl(opt,-textfont)       { {Text Font}        {}       font    {} }
	set vTcl(opt,-clicktime)      { {Click Time}       {}       type    {} }
	set vTcl(opt,-cyclicon)       { {Cyclic}           {}       boolean {0 1} }
        set vTcl(opt,-barcolor)       { {Bar Color}        Colors   color   {} }
        set vTcl(opt,-troughcolor)    { {Trough Color}     Colors   color   {} }
        set vTcl(opt,-steps)          { {Steps}            {}       type    {} }
        set vTcl(opt,-barheight)      { {Bar Height}       {}       type    {} }
	set vTcl(opt,-balloonbackground) { {Balloon Bg}       Colors   color   {} }
	set vTcl(opt,-balloondelay1)     { {Balloon Delay 1}  {}       type    {} }
	set vTcl(opt,-balloondelay2)     { {Balloon Delay 2}  {}       type    {} }
	set vTcl(opt,-balloonfont)       { {Balloon Font}     {}       font    {} }
	set vTcl(opt,-balloonforeground) { {Balloon Fg}       Colors   color   {} }
	set vTcl(opt,-helpvariable)      { {Help Var}      {}       type    {} }
#	set vTcl(opt,-plotbackground) { {Plot BgColor}     Colors   color   {} }
	set vTcl(opt,-textfont)       { {Text Font}        {}       font    {} }
	set vTcl(opt,-labelpos)       { {Label Pos}        {}
	                                choice  {n ne e se s sw w nw center} }
	set vTcl(opt,-fixed)          { {Fixed}            longname type    {} }
	set vTcl(opt,-validate)       { {Validate}     {}
					choice {none focus focusin focusout key all} }
	set vTcl(opt,-vcmd)           { {Validate Cmd}     {}       command {}}
	set vTcl(opt,-decrement)      { {Decrement Cmd}    {}       command {}}
	set vTcl(opt,-increment)      { {Increment Cmd}    {}       command {}}
	set vTcl(opt,-labeltext)      { Label              longname type    {} }
	set vTcl(opt,-range)          { Range              longname type    {} }
	set vTcl(opt,-items)          { Items              {}  command  {} }
#	set vTcl(opt,-items)          { Items              longname type    {} }
	set vTcl(opt,-step)           { Step               longname type    {} }
	set vTcl(opt,-listheight)     { "List Height"      longname type    {} }
	set vTcl(opt,-focuscommand)   { {Focus Cmd}	   {}       command {}}
	set vTcl(opt,-invalid)        { {Invalid Cmd}      {}       command {}}
	set vTcl(opt,-textbackground) { {Text BgColor}     Colors   color   {}}
	set vTcl(opt,-arrowrelief)    { {Arrow Relief}     {}
	                                choice  {flat groove raised ridge sunken} }
	set vTcl(opt,-completion)     { {Completion}       {}       boolean {0 1} }
	set vTcl(opt,-dropdown)       { {Drop Down}        {}       boolean {0 1} }
	set vTcl(opt,-margin)         { {Margin}           {}       type    {} }
	set vTcl(opt,-popupcursor)    { {Popup Cursor}     {}       type    {} }
	set vTcl(opt,-selectioncommand) { {Selection Cmd}  {}       command {} }
	set vTcl(opt,-unique)         { {Unique}           {}       boolean {0 1} }
	set vTcl(opt,-dblclickcommand) { {DblClk Cmd}      {}       command {} }
	set vTcl(opt,-visibleitems)   { {Visible Items}    {}       type    {} }
	set vTcl(opt,-alink)          { {ALink color}      Colors   color   {}}
	set vTcl(opt,-link)           { {Link color}       Colors   color   {}}
	set vTcl(opt,-linkhighlight)  { {Link highlight}   Colors   color   {}}

	#
	# define dump procedures for widget types
	#
	set vTcl(Entryfield,dump_opt)          vTcl:lib_itcl:dump_widget_opt
	set vTcl(Spinint,dump_opt)             vTcl:lib_itcl:dump_widget_opt
	set vTcl(Combobox,dump_opt)            vTcl:lib_itcl:dump_combobox
	set vTcl(Scrolledlistbox,dump_opt)     vTcl:lib_itcl:dump_widget_opt
	set vTcl(Calendar,dump_opt)            vTcl:lib_itcl:dump_widget_opt
	set vTcl(Dateentry,dump_opt)           vTcl:lib_itcl:dump_widget_opt
	set vTcl(Scrolledhtml,dump_opt)        vTcl:lib_itcl:dump_widget_opt
	set vTcl(Toolbar,dump_opt)             vTcl:lib_itcl:dump_widget_opt
	set vTcl(Feedback,dump_opt)            vTcl:lib_itcl:dump_widget_opt
	set vTcl(Optionmenu,dump_opt)          vTcl:lib_itcl:dump_widget_opt
	set vTcl(Hierarchy,dump_opt)           vTcl:lib_itcl:dump_widget_opt
	set vTcl(Buttonbox,dump_opt)           vTcl:lib_itcl:dump_widget_opt
	set vTcl(Checkbox,dump_opt)            vTcl:lib_itcl:dump_widget_opt
	set vTcl(Radiobox,dump_opt)            vTcl:lib_itcl:dump_widget_opt
	set vTcl(Tabnotebook,dump_opt)         vTcl:lib_itcl:dump_widget_opt
	set vTcl(Panedwindow,dump_opt)         vTcl:lib_itcl:dump_widget_opt
	set vTcl(Scrolledtext,dump_opt)        vTcl:lib_itcl:dump_widget_opt

	#
	# define whether or not do dump children of a class
	#
	set vTcl(Entryfield,dump_children)         0
	set vTcl(Spinint,dump_children)            0
	set vTcl(Combobox,dump_children)           0
	set vTcl(Scrolledlistbox,dump_children)    0
	set vTcl(Calendar,dump_children)	   0
	set vTcl(Dateentry,dump_children)          0
	set vTcl(Scrolledhtml,dump_children)       0
	set vTcl(Toolbar,dump_children)            0
	set vTcl(Feedback,dump_children)           0
	set vTcl(Optionmenu,dump_children)         0
	set vTcl(Hierarchy,dump_children)          0
	set vTcl(Buttonbox,dump_children)          0
	set vTcl(Checkbox,dump_children)           0
	set vTcl(Radiobox,dump_children)           0
	set vTcl(Tabnotebook,dump_children)        0
	set vTcl(Panedwindow,dump_children)        0
	set vTcl(Scrolledtext,dump_children)       0

	# @@change by Christian Gavin 3/9/2000
	# code to be generated at the top of a file if Itcl is supported

	append vTcl(head,importheader) {

		# provoke name search
	        catch {package require foobar}
	        set names [package names]

	        # check if Itcl is available
	        if { [lsearch -exact $names Itcl] != -1} {

		   package require Itcl 3.0
		   namespace import itcl::* }

		# check if Itk is available
		if { [lsearch -exact $names Itk] != -1} {

		   package require Itk 3.0 }

		# check if Iwidgets is available
		if { [lsearch -exact $names Iwidgets] != -1} {

		   package require Iwidgets 3.0
                   namespace import iwidgets::entryfield
                   namespace import iwidgets::spinint
                   namespace import iwidgets::combobox
                   namespace import iwidgets::scrolledlistbox
                   namespace import iwidgets::calendar
                   namespace import iwidgets::dateentry
                   namespace import iwidgets::scrolledhtml
                   namespace import iwidgets::toolbar
                   namespace import iwidgets::feedback
                   namespace import iwidgets::optionmenu
                   namespace import iwidgets::hierarchy
                   namespace import iwidgets::buttonbox
                   namespace import iwidgets::checkbox
                   namespace import iwidgets::radiobox
                   namespace import iwidgets::tabnotebook
                   namespace import iwidgets::panedwindow
                   namespace import iwidgets::scrolledtext

                   option add *Scrolledhtml.sbWidth 10
                   option add *Scrolledtext.sbWidth 10
               	   option add *Scrolledlistbox.sbWidth 10
                }
        }

	# @@end_change

	# @@change by Christian Gavin 3/15/2000
	# procedure to return the label of a widget to display in the tree view

	set vTcl(Combobox,get_widget_tree_label)   \
	    vTcl:lib_itcl:get_widget_tree_label

	set vTcl(Scrolledlistbox,get_widget_tree_label) \
	    vTcl:lib_itcl:get_widget_tree_label

	set vTcl(Calendar,get_widget_tree_label)   \
	    vTcl:lib_itcl:get_widget_tree_label

	set vTcl(Dateentry,get_widget_tree_label)  \
	    vTcl:lib_itcl:get_widget_tree_label

	set vTcl(Scrolledhtml,get_widget_tree_label)  \
	    vTcl:lib_itcl:get_widget_tree_label

	set vTcl(Toolbar,get_widget_tree_label)    \
	    vTcl:lib_itcl:get_widget_tree_label

	set vTcl(Feedback,get_widget_tree_label)   \
	    vTcl:lib_itcl:get_widget_tree_label

	set vTcl(Optionmenu,get_widget_tree_label) \
	    vTcl:lib_itcl:get_widget_tree_label

	set vTcl(Hierarchy,get_widget_tree_label)  \
	    vTcl:lib_itcl:get_widget_tree_label

	set vTcl(Buttonbox,get_widget_tree_label)  \
	    vTcl:lib_itcl:get_widget_tree_label

	set vTcl(Checkbox,get_widget_tree_label)   \
	    vTcl:lib_itcl:get_widget_tree_label

	set vTcl(Radiobox,get_widget_tree_label)   \
	    vTcl:lib_itcl:get_widget_tree_label

	set vTcl(Tabnotebook,get_widget_tree_label)  \
	    vTcl:lib_itcl:get_widget_tree_label

	set vTcl(Panedwindow,get_widget_tree_label)  \
	    vTcl:lib_itcl:get_widget_tree_label

	set vTcl(Scrolledtext,get_widget_tree_label)  \
	    vTcl:lib_itcl:get_widget_tree_label

	# @@end_change

	# @@change by Christian Gavin 4/1/2000
	# translation of option values for Itcl widgets so that
	# fonts are correctly saved

	set vTcl(option,translate,-textfont) vTcl:font:translate
	set vTcl(option,noencase,-textfont) 1
	set vTcl(option,translate,-balloonfont) vTcl:font:translate
	set vTcl(option,noencase,-balloonfont) 1

	# @@end_change

	option add *Scrolledhtml.sbWidth 10
	option add *Scrolledtext.sbWidth 10
	option add *Scrolledlistbox.sbWidth 10

	# hum... this is not too clean, but the hierarchy widget creates
	# icons on the fly
	#
	# in brief, the hierarchy widget does not know about the following images:
	#    openFolder
	#    closedFolder
	#    nodeFolder
	#
	# unless their respective options -openFolder,-closedFolder,-nodeFolder
	# haven't been specified while creating a hierarchy widget in which case
	# Iwidgets creates them
	#
	# this creates problems while sourcing a Iwidgets project in vTcl
	#
	# see save_option proc below for resolution
}

proc vTcl:lib_itcl:get_widget_tree_label {className {target ""}} {

	switch [string tolower $className] {

		"combobox"          {return "Combo Box"}
		"scrolledlistbox"   {return "Scrolled List Box"}
		"calendar"          {return "Calendar" }
		"dateentry"         {return "Date Entry" }
		"scrolledhtml"      {return "Scrolled HTML"}
		"toolbar"           {return "Toolbar"}
		"feedback"          {return "Feedback"}
		"optionmenu"        {return "Option Menu"}
		"hierarchy"         {return "Hierarchy"}
		"buttonbox"         {return "Button Box"}
		"checkbox"          {return "Check Box"}
		"radiobox"          {return "Radio Box"}
		"tabnotebook"       {return "Tab Notebook"}
		"panedwindow"       {return "Paned Window"}
		"scrolledtext"      {return "Scrolled Text"}

		default             {return ""}
	}
}

#
# individual widget commands executed after insert
#

proc vTcl:widget:toolbar:inscmd {target} {

	global env

	return "$target add button open \
		-balloonstr \"Open\" \
		-image [vTcl:image:get_image $env(VTCL_HOME)/images/edit/open.gif] \
		-command {tk_messageBox -message {TODO: Command handler here!}}"
}

proc vTcl:widget:optionmenu:inscmd {target} {

	return "$target insert 0 {Choice 1} {Choice 2} {Choice 3}"
}

proc vTcl:widget:buttonbox:inscmd {target} {

	return "$target add ok     -text OK ;\
	        $target add cancel -text Cancel ;\
	        $target add help   -text Help"
}

proc vTcl:widget:checkbox:inscmd {target} {

	return "$target add check1   -text {Check 1} ;\
	        $target add check2   -text {Check 2} ;\
	        $target add check3   -text {Check 3}"
}

proc vTcl:widget:radiobox:inscmd {target} {

	return "$target add radio1   -text {Radio 1} ;\
	        $target add radio2   -text {Radio 2} ;\
	        $target add radio3   -text {Radio 3}"
}

proc vTcl:widget:tabnotebook:inscmd {target} {

	return "$target add -label {Page 1} ;\
	        $target add -label {Page 2} ;\
	        $target add -label {Page 3} ;\
	        $target select 0"
}

proc vTcl:widget:panedwindow:inscmd {target} {

	return "$target add pane1; $target add pane2"
}

#
# per-widget-class dump procedures
#
#
# Utility proc.  Ignore color options (-background, etc.) based on
# preference.
#
# returns:
#   1 means save the option
#   0 means don't save it

proc vTcl:lib_itcl:save_option {opt} {

    set opt_name  [lindex $opt 0]
    set opt_value [lindex $opt 4]

    if {$opt_name  == "-openicon" &&
        $opt_value == "openFolder"} {
        return 0 }

    if {$opt_name  == "-closedicon" &&
        $opt_value == "closedFolder"} {
        return 0 }

    if {$opt_name  == "-nodeicon" &&
        $opt_value == "nodeFolder"} {
        return 0 }

    vTcl:log "save_option '$opt'"
    return 1
}

# Utility proc.  Dump a itcl widget.
# Differs from vTcl:dump_widget_opt in that it tries harder to avoid
# dumping options that shouldn't really be dumped, e.g. -fg,-bg,-font.

proc vTcl:lib_itcl:dump_widget_opt {target basename} {

    global vTcl
    set result ""
    set class [vTcl:get_class $target]
    set result "$vTcl(tab)[vTcl:lower_first $class] $basename"
    set opt [$target configure]
    set keep_opt ""
    foreach e $opt {
        if [vTcl:lib_itcl:save_option $e] {
            lappend keep_opt $e
        }
    }
    set p [vTcl:get_opts_special $keep_opt $target]
    if {$p != ""} {
    	vTcl:log "=> megawidget: $p"
        append result " \\\n[vTcl:clean_pairs $p]\n"
    } else {
        append result "\n"
    }
    append result [vTcl:dump_widget_bind $target $basename]
    return $result
}

# Utility proc.  Dump a itcl widget.
# Differs from vTcl:dump_widget_opt in that it tries harder to avoid
# dumping options that shouldn't really be dumped, e.g. -fg,-bg,-font.

proc vTcl:lib_itcl:dump_combobox {target basename} {
    global vTcl
    # @@change by Christian Gavin 3/8/2000
    # removed editable stuff
    # @@end_change
    set result [vTcl:lib_itcl:dump_widget_opt $target $basename]
    return $result
}
