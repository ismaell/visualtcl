namespace eval ::NewWizard {
    variable base	   .vTcl.newProjectWizard
    variable listbox
    variable DefaultFolder ""
    variable ProjectFolder ""
    variable ProjectName   ""
    variable ProjectFile   ""

proc WinButton {w args} {
    frame $w -width 74 -height 22
    eval button $w.b $args
    place $w.b -x 0 -y 0 -width 74 -height 22
    return $w
}

proc GetFolder {} {
    variable base
    variable ProjectFolder

    set cmd "tk_chooseDirectory -parent $base"
    if {$::tcl_platform(platform) != "macintosh"} {
    	lappend cmd -initialdir $ProjectFolder
    }
    set f [eval $cmd]
    if {[lempty $f]} { return }
    set ProjectFolder $f
    return $ProjectFolder
}

proc SetFolderFromName {} {
    variable DefaultFolder
    variable ProjectFolder
    variable ProjectName

    set ProjectFolder [file join $DefaultFolder $ProjectName]
    return 1
}

proc Raise1 {} {
    variable base

    set p [$base.main getframe 1]

    bind $base <Alt-t> "focus $p.left.list"
    bind $base <Alt-n> "focus $p.right.e1"
    bind $base <Alt-f> "focus $p.right.f1.e2"
    bind $base <Alt-m> "focus $p.right.e3"
}

proc Done {} {
    variable base
    variable listbox
    variable ProjectName
    variable ProjectFolder

    if {[lempty [$listbox selection get]]} {
    	::vTcl::MessageBox -title "Specify Project Type" -message \
	    "You must specify a Project Type"
	return
    }

    if {[lempty $ProjectName]} {
    	::vTcl::MessageBox -title "Specify Project Name" -message \
	    "You must specify a Project Name"
	return
    }

    if {[file exists $ProjectFolder]} {
    	::vTcl::MessageBox -title "Folder Exists" -message \
	    "A project already exists in '$ProjectFolder'"
	return
    }

    file mkdir $ProjectFolder

    Window hide $base

    ## Set the variable to end the grab.
    variable Done 1
}

} ;## eval namespace ::NewWizard

proc vTclWindow.vTcl.newProjectWizard {args} {
    global vTcl
    upvar #0 ::NewWizard::base base
    upvar #0 ::NewWizard::listbox listbox

    set ::NewWizard::DefaultFolder [file join [pwd] $vTcl(project,dir)]
    set ::NewWizard::ProjectFolder $::NewWizard::DefaultFolder
    set ::NewWizard::ProjectName   ""
    set ::NewWizard::ProjectFile   "main.tcl"

    if {[winfo exists $base]} {
    	wm deiconify $base
	$listbox raise 1
	return
    }

    toplevel $base
    wm transient $base .vTcl
    wm withdraw  $base
    wm geometry  $base 500x400
    wm title     $base "New Project Wizard"
    wm protocol  $base WM_DELETE_WINDOW "Window hide $base"
    wm resizable $base 0 0

    ## Button frame
    frame $base.top
    pack $base.top -side top -anchor e
    ::vTcl::OkButton $base.top.ok -command "::NewWizard::Done"
    pack $base.top.ok -side left
    ::vTcl::CancelButton $base.top.cancel -command "Window hide $base"
    pack $base.top.cancel -side left

    ## Let's just use a notebook.  I don't feel like writing a real wizard.
    set n [NoteBook $base.main -width 500 -height 400]
    pack $n -expand 1 -fill both

    ## Create page 1
    set p1 [$n insert end 1 -text "Project Info" -raisecmd ::NewWizard::Raise1]

    frame $p1.left
    pack $p1.left -side left -fill both

    label $p1.left.l -text "Project Type:" -underline 8
    pack $p1.left.l -side top -anchor w

    set listbox [ListBox $p1.left.list -bg white -width 25 -padx 25 -deltay 20]
    pack $listbox -fill both -expand 1

    set f [frame $p1.right]
    pack $f -side right -expand 1 -fill both

    label $f.l1 -text "Project Name:" -underline 8
    pack $f.l1 -anchor w
    entry $f.e1 -textvariable ::NewWizard::ProjectName \
   	 -validate focusout -vcmd "::NewWizard::SetFolderFromName"
    pack $f.e1 -fill x
    bind $f.e1 <Key-Return> "::NewWizard::SetFolderFromName"

    pack [frame $f.spacer1 -height 10]

    label $f.l2 -text "Project Folder:" -underline 8
    pack $f.l2 -anchor w
    frame $f.f1
    entry $f.f1.e2 -textvariable ::NewWizard::ProjectFolder
    button $f.f1.b1 -image [vTcl:image:get_image browse.gif] \
    	-command "::NewWizard::GetFolder"
    pack $f.f1 -fill x
    pack $f.f1.e2 -side left -fill x -expand 1
    pack $f.f1.b1 -side left

    pack [frame $f.spacer2 -height 10]

    label $f.l3 -text "Main Project File:" -underline 0
    pack $f.l3 -anchor w
    entry $f.e3 -textvariable ::NewWizard::ProjectFile
    pack $f.e3 -fill x

    set i 0
    foreach type $vTcl(project,types) {
	$listbox insert end [incr i] -text $type -image icon_toplevel.gif
    }
    $listbox selection set 1

    $listbox bindImage <Button-1> "$listbox selection set"
    $listbox bindText  <Button-1> "$listbox selection set"

    ## END Page 1

    vTcl:center $base 500 400

    ## Raise the first tab.
    $n raise 1

    wm deiconify $base
}
