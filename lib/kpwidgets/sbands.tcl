namespace eval kpwidgets::SBands {

	set registeredFrames {}

}
proc kpwidgets::SBands { path args } { 
	
	return [eval SBands::create $path $args] 
}
proc kpwidgets::SBands::configure { path args } { 

}

proc kpwidgets::SBands::create { path args } {
	array set maps [list SBands {} :cmd {}]	
	eval frame $path $maps(:cmd) -class SBands
	#::Widget::initFromODB SBands $path $maps(SBands)
	bind $path <Destroy> { destroy $path.sf }
	rename $path ::$path:cmd
	proc ::$path { cmd args } "return \[eval kpwidgets::SBands::\$cmd $path \$args\]"
	
	set sfw [ ScrolledWindow $path.sw -scrollbar vertical]
	set sff [ ScrollableFrame $path.sw.sff ]
	$sfw setwidget $sff
	set sf [$sff getframe]
	
	pack $sfw -fill both -expand yes 
	return $path
}

proc kpwidgets::SBands::foldOtherFramesAndUnfoldThisFrame { frameToUnfold } {
	foreach frameToFold $kpwidgets::SBands::registeredFrames { 
		if { $frameToFold != $frameToUnfold } { 
			# Fold all other frames :
			kpwidgets::SBands::foldOrUnfold $frameToFold "FOLD"
		} else {
			# Unfold the desired frame :
			kpwidgets::SBands::foldOrUnfold $frameToUnfold "UNFOLD"
		}
	}
}

proc kpwidgets::SBands::new_frame { path args } {
	set frame_name [ lindex $args 0 ]
	set title [ lindex $args 1 ]

	set bfrm [$path.sw.sff getframe].bfrm$frame_name
	set lbl $bfrm.lbl
	set frm $bfrm.frm
	pack [ frame $bfrm ] -expand yes -fill x
	set title [ linsert $title end (+) ]
	pack [ label $lbl -text $title -bg #aaaaaa -bd 1 -relief raised \
		-width 31 ] -side top -fill x -expand yes -padx 2
	frame $frm 

	# TODO : Add a vTcl menu preference to choose between the two following kinds of binding
	
	# First kind of binding :
	
    #bind $lbl <ButtonPress> "kpwidgets::SBands::foldOrUnfold $bfrm"

	# Second kind of binding :

	bind $lbl <ButtonPress> "kpwidgets::SBands::foldOtherFramesAndUnfoldThisFrame $bfrm"            ; # NOTE : I have tried this with <Enter>, it's working, but not very practical...

	# Store the frame :
	lappend kpwidgets::SBands::registeredFrames $bfrm	
	#puts "\[proc kpwidgets::SBands::new_frame\] Registered new frame on the scrollable band ($bfrm)" 
	# TODO : Logger
	
	set $path $frm
}

proc kpwidgets::SBands::foldOrUnfold { bfrm  { foldOrUnfold "SWITCH" } } {   ; # Second parameter can be SWITCH, FOLD or UNFOLD
	set frm $bfrm.frm 
	set lbl $bfrm.lbl
	
	set title [$lbl cget -text]

	# Elaborate the kind of folding the caller wants :
	set desiredAction ""
	if { $foldOrUnfold == "SWITCH" } {
		if { [catch { pack info $frm  } ] } {
			set desiredAction "UNFOLD"
		} else { 
			set desiredAction "FOLD"
		}
	} elseif { ($foldOrUnfold != "FOLD") && ($foldOrUnfold != "UNFOLD") } {
		puts "\[proc kpwidgets::SBands::foldOrUnfold\] Unexpected parameter ($foldOrUnfold)"
		# TODO : Use error logger...
		set desiredAction "UNFOLD"
	} else {
		set desiredAction $foldOrUnfold
	}

	if { $desiredAction == "FOLD" } {
		if { [lindex $title end] != "(+)" } {			
			lset title end (+)
			pack forget $frm 
			$lbl configure -text $title
		}
	} else {
		if { [lindex $title end] != "(-)" } {			
			pack $frm -expand yes -fill both -padx 10
			lset title end (-)
			$lbl configure -text $title
		}
	}
}

proc kpwidgets::SBands::childsite { path frame_name } {
	return [$path.sw.sff getframe].bfrm$frame_name.frm		
}

proc kpwidgets::SBands::current_childsite { path args } {
	
}

