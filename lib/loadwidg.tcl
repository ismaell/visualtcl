proc vTcl:LoadWidgets {dir} {
    global vTcl tmp

    foreach subdir [glob $dir/*] {
	if {![file isdirectory $subdir]} { continue }
	foreach file [lsort [glob -nocomplain $subdir/*.wgt]] {
	    set tmp(lib) [file tail $subdir]
	    vTcl:LoadWidget $tmp(lib) $file
	}
    }

    set vTcl(libs) [vTcl:lrmdups $vTcl(libs)]
    set vTcl(classes) [vTcl:lrmdups $vTcl(classes)]
    set vTcl(options) [vTcl:lrmdups $vTcl(options)]

    return
}

proc vTcl:LoadWidget {lib file} {
    global tmp vTcl widgets classes

    set file [file tail $file]
    set file [file join $vTcl(VTCL_HOME) lib Widgets $lib $file]

    if {![file exists $file]} { set file $file.wgt }
    if {![file exists $file]} { return }

    uplevel #0 source [list $file]

    if {[info exists tmp(isSuperClass)]} {
	if {![info exists tmp(typeCmd)]} {
	    return -code error "Must specify a TypeCmd in a super class"
	}
	
	SetClassArray

    	if {![info exists tmp(superClass)]} { unset tmp }
    	return
    }

    if {![info exists tmp(name)]} { return }
    if {![info exists tmp(class)]} { unset tmp; return }

    ## We already have this widget.
    if {[info exists widgets($tmp(name),class)]} { unset tmp; return }

    SetClassArray

    if {[info exists tmp(isSuperClass)] && $tmp(isSuperClass)} {
	unset tmp
    	return
    }

    SetWidgetArray

    lappend vTcl(libs) $tmp(lib)
    lappend vTcl(classes) $tmp(class)
    lappend vTcl(lib_$tmp(lib),classes) $tmp(class)
    lappend vTcl(lib_$tmp(lib),widgets) $tmp(name)

    unset tmp
}

proc SetClassArray {} {
    global tmp classes

    array set classes "
	$tmp(class),lib			vtcl
	$tmp(class),createCmd		[vTcl:lower_first $tmp(class)]
	$tmp(class),resizable		1
	$tmp(class),dumpChildren	1
	$tmp(class),dumpCmd		vTcl:dump_widget_opt
	$tmp(class),options		{}
	$tmp(class),defaultOptions	{}
	$tmp(class),insertCmd		{}
	$tmp(class),dblClickCmd		{}
	$tmp(class),treeLabel		{}
	$tmp(class),exportCmds		{}
	$tmp(class),functionCmds	{}
	$tmp(class),functionText	{}
	$tmp(class),typeCmd		{}
	$tmp(class),widgetProc		{}
    "

    foreach elem [array names classes $tmp(class),*] {
	lassign [split $elem ,] name var
    	if {![info exists tmp($var)]} { continue }
	set classes($elem) $tmp($var)
    }
}

proc SetWidgetArray {} {
    global vTcl tmp widgets

    array set widgets "
	$tmp(name),name			$tmp(name)
	$tmp(name),class		$tmp(class)
	$tmp(name),icon			icon_[vTcl:lower_first $tmp(name)].gif
	$tmp(name),balloon		$tmp(name)
	$tmp(name),addOptions		{}
	$tmp(name),autoPlace		0
    "

    foreach elem [array names widgets $tmp(name),*] {
	lassign [split $elem ,] name var
    	if {![info exists tmp($var)]} { continue }
	set widgets($elem) $tmp($var)
    }

    ## Create the toolbar icon.
    set icon [file join $vTcl(VTCL_HOME) images $widgets($tmp(name),icon)]
    if {[file exists $icon]} {
	set widgets($tmp(name),image) \
	    [image create photo "ctl_$tmp(name)" -file $icon]
    } else {
    	unset widgets($tmp(name),icon)
    }
}

proc Name {name} {
    global tmp
    set tmp(name) $name
}

proc Class {name} {
    global tmp
    set tmp(class) $name
}

proc Lib {lib} {
    global tmp
    set tmp(lib) $lib
}

proc CreateCmd {cmd} {
    global tmp
    set tmp(createCmd) $cmd
}

proc Icon {icon} {
    global tmp
    set tmp(icon) $icon
}

proc AddOptions {args} {
    global tmp
    eval lappend tmp(addOptions) $args
}

proc Balloon {args} {
    global tmp
    set tmp(balloon) $args
}

proc Option {args} {
    global tmp
    eval lappend tmp(options) $args
}

proc DefaultOptions {args} {
    global tmp
    eval lappend tmp(defaultOptions) $args
}

proc DumpCmd {val} {
    global tmp
    set tmp(dumpCmd) $val
}

proc DumpChildren {val} {
    global tmp
    set num 0
    if {[string tolower $val] == "yes"} { set num 1 }
    set tmp(dumpChildren) $num
}

proc InsertCmd {name} {
    global tmp
    set tmp(insertCmd) $name
}

proc DoubleClickCmd {name} {
    global tmp
    set tmp(dblClickCmd) $name
}

proc TreeLabel {args} {
    global tmp
    set tmp(treeLabel) $args
}

proc Export {name} {
    global tmp
    lappend tmp(exportCmds) $name
}

proc NewOption {args} {
    global tmp options vTcl
    lassign $args option text type choices title
    lappend vTcl(options) $option
    set options($option,text) $text
    set options($option,type) $type
    set options($option,choices) $choices
    set options($option,title) $title
}

proc Function {name command} {
    global tmp
    lappend tmp(functionText) $name
    lappend tmp(functionCmds) $command
}

proc SuperClass {val} {
    global tmp 
    set tmp(superClass) $val
    vTcl:LoadWidget $tmp(lib) $val
    unset tmp(isSuperClass)
}

proc IsSuperClass {val} {
    global tmp
    set num 0
    if {[string tolower $val] == "yes"} { set num 1 }
    set tmp(isSuperClass) $num
}

proc Resizable {val} {
    global tmp
    set val [string tolower $val]
    if {[string match "n*" $val]} { set tmp(resizable) 0 }
    if {[string match "b*" $val]} { set tmp(resizable) 1 }
    if {[string match "h*" $val]} { set tmp(resizable) 2 }
    if {[string match "v*" $val]} { set tmp(resizable) 3 }
}

proc TypeCmd {val} {
    global tmp
    set tmp(typeCmd) $val
}

proc AutoPlace {val} {
    global tmp
    set num 0
    if {[string tolower $val] == "yes"} { set num 1 }
    set tmp(autoPlace) $num
}
