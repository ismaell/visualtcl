#!/usr/bin/wish
if {![info exist vTcl(sourcing)]} {

		
		# provoke name search
	        catch {package require foobar}
	        set names [package names]
                
	        # check if BLT is available
	        if { [lsearch -exact $names BLT] != -1} { 

		   package require BLT
		   namespace import blt::vector
		   namespace import blt::graph
		   namespace import blt::hierbox
		   namespace import blt::stripchart
		}
	
		
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
                }
        
}
############################
# code to load stock images


if {![info exist vTcl(sourcing)]} {
proc vTcl:rename {name} {

    regsub -all "\\." $name "_" ret
    regsub -all "\\-" $ret "_" ret
    regsub -all " " $ret "_" ret
    regsub -all "/" $ret "__" ret

    return [string tolower $ret]
}

proc vTcl:image:create_new_image {filename description type} {
	
	global vTcl env
	set reference [vTcl:rename $filename]

	# image already existing ?
	if [info exists vTcl(images,files)] {
		
		set index [lsearch -exact $vTcl(images,files) $filename]
		
		if {$index != "-1"} {
			# cool, no more work to do
			return
		}
	}
	
	# wait a minute... does the file actually exist?
	if {! [file exists $filename] } {

		set description "file not found!"
		
		set object [image create bitmap -data {
		    #define open_width 16
		    #define open_height 16
		    static char open_bits[] = {
			0x7F, 0xFE, 
			0x41, 0x82, 
			0x21, 0x81, 
			0x41, 0x82, 
			0x21, 0x81, 
			0x21, 0x81, 
			0x21, 0x81, 
			0x91, 0x80,
			0x21, 0x81, 
			0x91, 0x80, 
			0x21, 0x81, 
			0x21, 0x81, 
			0x21, 0x81, 
			0x41, 0x82, 
			0x41, 0x82,
			0x7F, 0xFE};}]
		
	} else {

		set object [image create [vTcl:image:get_creation_type $filename] -file $filename]
	}
	
	set vTcl(images,$reference,image)       $object
	set vTcl(images,$reference,description) $description
	set vTcl(images,$reference,type)        $type
	set vTcl(images,filename,$object)       $filename

	lappend vTcl(images,files) $filename
	
	# return image name in case caller might want it
	return $object
}

proc vTcl:image:get_image {filename} {

	global vTcl
	set reference [vTcl:rename $filename]

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

vTcl:image:create_new_image "/home/work/vtcl_new/images/edit/copy.gif" "" "stock"
vTcl:image:create_new_image "/home/work/vtcl_new/images/edit/cut.gif" "" "stock"
vTcl:image:create_new_image "/home/work/vtcl_new/images/edit/paste.gif" "" "stock"
vTcl:image:create_new_image "/home/work/vtcl_new/images/edit/new.gif" "" "stock"
vTcl:image:create_new_image "/home/work/vtcl_new/images/edit/open.gif" "" "stock"
vTcl:image:create_new_image "/home/work/vtcl_new/images/edit/save.gif" "" "stock"
vTcl:image:create_new_image "/home/work/vtcl_new/images/edit/replace.gif" "" "stock"
}
############################
# code to load user images

############################
# code to load stock fonts


if {![info exist vTcl(sourcing)]} {
set vTcl(fonts,counter) 0
proc vTcl:font:add_font {font_descr font_type newkey} {

     global vTcl

     incr vTcl(fonts,counter)
     set newfont [eval font create $font_descr]

     lappend vTcl(fonts,objects) $newfont

     # each font has its unique key so that when a project is
     # reloaded, the key is used to find the font description

     if {$newkey == ""} {
          set newkey vTcl:font$vTcl(fonts,counter)
     }

     set vTcl(fonts,$newfont,type)                      $font_type
     set vTcl(fonts,$newfont,key)                       $newkey
     set vTcl(fonts,$vTcl(fonts,$newfont,key),object)   $newfont
     
     # in case caller needs it
     return $newfont
}

proc vTcl:font:get_font {key} {
	
	global vTcl
	
	return $vTcl(fonts,$key,object)
}

vTcl:font:add_font "-family helvetica -size 12 -weight normal -slant roman -underline 0 -overstrike 0" stock vTcl:font1
vTcl:font:add_font "-family helvetica -size 12 -weight normal -slant roman -underline 1 -overstrike 0" stock underline
vTcl:font:add_font "-family courier -size 12 -weight normal -slant roman -underline 0 -overstrike 0" stock vTcl:font3
vTcl:font:add_font "-family times -size 12 -weight normal -slant roman -underline 0 -overstrike 0" stock vTcl:font4
vTcl:font:add_font "-family helvetica -size 12 -weight bold -slant roman -underline 0 -overstrike 0" stock vTcl:font5
vTcl:font:add_font "-family courier -size 12 -weight bold -slant roman -underline 0 -overstrike 0" stock vTcl:font6
vTcl:font:add_font "-family times -size 12 -weight bold -slant roman -underline 0 -overstrike 0" stock vTcl:font7
vTcl:font:add_font "-family lucida -size 18 -weight normal -slant roman -underline 0 -overstrike 0" stock vTcl:font8
vTcl:font:add_font "-family lucida -size 18 -weight normal -slant italic -underline 0 -overstrike 0" stock vTcl:font9
}
############################
# code to load user fonts

#############################################################################
# Visual Tcl v1.21 Project
#

#################################
# GLOBAL VARIABLES
#
global widget; 
    set widget(ButtonBox1) {.top33.but35}
    set widget(CheckBox1) {.top33.fra36.che37}
    set widget(CheckBox2) {.top33.fra36.che38}
    set widget(RadioBox1) {.top33.fra34.rad35}
    set widget(notebook) {.top35.tab36}
    set widget(rev,.top33.but35) {ButtonBox1}
    set widget(rev,.top33.fra34.rad35) {RadioBox1}
    set widget(rev,.top33.fra36.che37) {CheckBox1}
    set widget(rev,.top33.fra36.che38) {CheckBox2}
    set widget(rev,.top35.tab36) {notebook}

#################################
# USER DEFINED PROCEDURES
#

proc {buttonbox} {pathName args} {
uplevel ::iwidgets::Buttonbox $pathName $args
}

proc {checkbox} {pathName args} {
uplevel ::iwidgets::Checkbox $pathName $args
}

proc {notebookPage1} {base {container 0}} {
global widget
    
    if {$base == ""} {
        set base .top33
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    toplevel $base -class Toplevel  -background #bcbcbc -highlightbackground #bcbcbc  -highlightcolor #000000 
    wm focusmodel $base passive
    wm geometry $base 428x293+123+165
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "New Toplevel 1"
    }
    frame $base.fra36  -background #bcbcbc -borderwidth 2 -cursor left_ptr -height 75  -highlightbackground #bcbcbc -highlightcolor #000000 -relief groove  -width 125 
    checkbox $base.fra36.che37  -background #febcbc -labeltext Settings! 
    checkbox $base.fra36.che38  -background #bce8bc -labeltext {Settings 2} 
    frame $base.fra34  -background #bcbcbc -borderwidth 2 -height 75  -highlightbackground #bcbcbc -highlightcolor #000000 -width 125 
    radiobox $base.fra34.rad35  -background #bc725c -labeltext {Settings 3} -relief sunken 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.fra36  -in $base -anchor center -expand 1 -fill both -side top 
    pack $base.fra36.che37  -in $base.fra36 -anchor n -expand 1 -fill both -side left 
    grid columnconf $base.fra36.che37 1 -weight 1
    grid rowconf $base.fra36.che37 1 -weight 1
    grid rowconf $base.fra36.che37 0 -minsize 8
    pack $base.fra36.che38  -in $base.fra36 -anchor n -expand 1 -fill both -side left 
    grid columnconf $base.fra36.che38 1 -weight 1
    grid rowconf $base.fra36.che38 1 -weight 1
    grid rowconf $base.fra36.che38 0 -minsize 8
    pack $base.fra34  -in $base -anchor center -expand 0 -fill x -side top 
    pack $base.fra34.rad35  -in $base.fra34 -anchor center -expand 0 -fill x -side top 
    grid columnconf $base.fra34.rad35 1 -weight 1
    grid rowconf $base.fra34.rad35 1 -weight 1
    grid rowconf $base.fra34.rad35 0 -minsize 8

    $base.fra36.che37 add check1 -text "Check 1"
    $base.fra36.che37 add check2 -text "Check 2"
    $base.fra36.che37 add check3 -text "Check 3"

    $base.fra36.che38 add check1 -text "Check 1"
    $base.fra36.che38 add check2 -text "Check 2"
    $base.fra36.che38 add check3 -text "Check 3"

    $base.fra34.rad35 add radio1 -text "Radio 1"
    $base.fra34.rad35 add radio2 -text "Radio 2"
    $base.fra34.rad35 add radio3 -text "Radio 3"
}

proc {radiobox} {pathName args} {
uplevel ::iwidgets::Radiobox $pathName $args
}

proc {tabnotebook} {pathName args} {
uplevel ::iwidgets::Tabnotebook $pathName $args
}

proc {main} {argc argv} {
global widget

    wm protocol .top35 WM_DELETE_WINDOW {exit}

    $widget(notebook) add -label "Page 1"
    $widget(notebook) add -label "Page 2"
    $widget(notebook) add -label "Page 3"

    set child [lindex [$widget(notebook) childsite] 0]

    notebookPage1 $child 1
    $widget(notebook) select 0
}

proc {Window} {args} {
global vTcl
    set cmd [lindex $args 0]
    set name [lindex $args 1]
    set newname [lindex $args 2]
    set rest [lrange $args 3 end]
    if {$name == "" || $cmd == ""} {return}
    if {$newname == ""} {
        set newname $name
    }
    set exists [winfo exists $newname]
    switch $cmd {
        show {
            if {$exists == "1" && $name != "."} {wm deiconify $name; return}
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

proc init {argc argv} {

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
    wm geometry $base 1x1+0+0
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm withdraw $base
    wm title $base "vt.tcl"
    }
    ###################
    # SETTING GEOMETRY
    ###################
}

proc vTclWindow.top35 {base {container 0}} {
    if {$base == ""} {
        set base .top35
    }
    if {[winfo exists $base] && (!$container)} {
        wm deiconify $base; return
    }
    ###################
    # CREATING WIDGETS
    ###################
    if {!$container} {
    toplevel $base -class Toplevel \
        -background #bcbcbc -highlightbackground #bcbcbc \
        -highlightcolor #000000 
    wm focusmodel $base passive
    wm geometry $base 450x368+177+212
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "New Toplevel 2"
    }
    tabnotebook $base.tab36 \
        -raiseselect 1 -tabpos n 
    frame $base.fra37 \
        -background #bcbcbc -borderwidth 2 -height 75 \
        -highlightbackground #bcbcbc -highlightcolor #000000 -width 125 
    button $base.fra37.but38 \
        -activebackground #bcbcbc -activeforeground #000000 \
        -background #bcbcbc \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -padx 9 -pady 3 -text {Next >} 
    button $base.fra37.but39 \
        -activebackground #bcbcbc -activeforeground #000000 \
        -background #bcbcbc \
        -font -adobe-helvetica-bold-r-normal--12-120-75-75-p-70-iso8859-1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -padx 9 -pady 3 -text {< Previous} 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.tab36 \
        -in $base -anchor center -expand 1 -fill both -side top 
    pack $base.fra37 \
        -in $base -anchor center -expand 0 -fill none -side right 
    pack $base.fra37.but38 \
        -in $base.fra37 -anchor center -expand 0 -fill none -side right 
    pack $base.fra37.but39 \
        -in $base.fra37 -anchor center -expand 0 -fill none -side right 
}

Window show .
Window show .top35

main $argc $argv
