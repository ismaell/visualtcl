##############################################################################
#
# image.tcl  - procedures to handle a database of stock images and user images
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

##############################################################################
#
# @@change by Christian Gavin March 2000
# new file to display an image manager and an image selector for properties
# @@end_change

# bitmap types accepted by Visual Tcl

set vTcl(image,filetypes) {

	   {{GIF Files}          {.gif}       }
	   {{Portable Pixel Map} {.ppm}       }
	   {{X Windows Bitmap}   {.xbm}       }
	   {{All Files}          *            }
}

# returns "photo" if a GIF or "bitmap" if a xbm

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

proc {vTcl:image:create_new_image} {filename 
                                    {description {no description}} 
                                    {type {}}} {
	
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

proc {vTcl:image:get_description} {filename} {

	global vTcl
	set reference [vTcl:rename $filename]

	return $vTcl(images,$reference,description)
}

proc {vTcl:image:get_type} {filename} {

	global vTcl
	set reference [vTcl:rename $filename]

	return $vTcl(images,$reference,type)
}

proc {vTcl:image:get_image} {filename} {

	global vTcl
	set reference [vTcl:rename $filename]

	return $vTcl(images,$reference,image)
}

proc {vTcl:image:init_img_manager} {} {

	global vTcl env tcl_platform

	# in case an image editor has not been specified yet,
	# set a default
	
	set noeditor 0
	
	if {![info exists vTcl(pr,imageeditor)]} {

		set noeditor 1

	} elseif {$vTcl(pr,imageeditor) == ""} {

		set noeditor 1
	}
	
	if {$noeditor} {
		
		switch $tcl_platform(platform) {
			
			"unix" {
				set vTcl(pr,imageeditor) "gimp"
			}
			
			"windows" {
				set vTcl(pr,imageeditor) "C:/Program Files/Accessories/mspaint.exe"
			}
			
			"default" {
				set vTcl(pr,imageeditor) ""
			}
		}
	}
	
	set base $vTcl(images,manager_dlg,win).cpd29.03

	$base configure -state normal -tabs {0.2i 3i 3.75i}
	$base delete 0.0 end

	foreach image $vTcl(images,files) {

	   set reference [vTcl:rename $image]
	   set object $vTcl(images,$reference,image)
   
	   catch {
	   	label $base.$reference -image $object
	   	
 	  	vTcl:set_balloon $base.$reference "$image"

	   }

	   catch {
                set realname $image
                if {$tcl_platform(platform) == "windows"} {
                     regsub -all / $realname {\\\\} realname
                }

                button $base.${reference}_edit \
                    -image [vTcl:image:get_image $env(VTCL_HOME)/images/edit/open.gif] \
                    -command "exec \"\$vTcl(pr,imageeditor)\" \"$realname\" &"

                vTcl:set_balloon $base.${reference}_edit "Edit image"
           }

	   if {$vTcl(images,$reference,type) == "user"} {

		   catch {
		   	button $base.${reference}_delete \
		   	-image [vTcl:image:get_image $env(VTCL_HOME)/images/edit/cut.gif] \
	 	  	-command "vTcl:image:ask_delete_image \"$image\""
	 	  	
	 	  	vTcl:set_balloon $base.${reference}_delete "Remove image from list"
	 	   }

		   catch {
		   	button $base.${reference}_replace \
		   	-image [vTcl:image:get_image $env(VTCL_HOME)/images/edit/replace.gif] \
		   	-command "vTcl:image:replace_image \"$image\""

	 	  	vTcl:set_balloon $base.${reference}_replace "Replace image by another"
		   }
	   }
   
	   $base insert end "$image: $vTcl(images,$reference,description)"
	   $base insert end " ($vTcl(images,$reference,type))\n"
	   $base insert end "[image type $object] [image width $object] x [image height $object]"
	   $base insert end " ($object)\n\n\t"
   
	   $base window create end -window $base.$reference
	   $base insert end "\t"
	   $base window create end -window $base.${reference}_edit
	
	   if {$vTcl(images,$reference,type) == "user"} {
		   $base insert end " "
		   $base window create end -window $base.${reference}_delete
		   $base insert end " "
		   $base window create end -window $base.${reference}_replace
	   }
   
	   $base insert end "\n\n___________________________________________________________________\n\n"
	}

	$base configure -state disabled
}

proc {vTcl:image:init_stock} {} {

	global vTcl env

	if [info exist vTcl(images,files)] {

	   foreach image $vTcl(images,files) {
	      catch {
	         image delete $image
	      }
	   }
	}

	set vTcl(images,files) ""

	vTcl:image:create_new_image "$env(VTCL_HOME)/images/edit/copy.gif"    "" stock
	vTcl:image:create_new_image "$env(VTCL_HOME)/images/edit/cut.gif"     "" stock
	vTcl:image:create_new_image "$env(VTCL_HOME)/images/edit/paste.gif"   "" stock
	vTcl:image:create_new_image "$env(VTCL_HOME)/images/edit/new.gif"     "" stock
	vTcl:image:create_new_image "$env(VTCL_HOME)/images/edit/open.gif"    "" stock
	vTcl:image:create_new_image "$env(VTCL_HOME)/images/edit/save.gif"    "" stock
	vTcl:image:create_new_image "$env(VTCL_HOME)/images/edit/replace.gif" "" stock
}

proc {vTcl:image:new_image_file} {} {

	global vTcl tk_strictMotif

	set types $vTcl(image,filetypes)

	set tk_strictMotif 0
	set newImageFile [tk_getOpenFile -filetypes $types  -defaultextension .gif]
	set tk_strictMotif 1

	set object ""
	
	if {$newImageFile != ""} {

	    # just double-check that it doesn't exist!
    
	    if {[lsearch -exact $vTcl(images,files) $newImageFile] != -1} {
    
	        tk_messageBox -title "New image" \
	                      -message "Image already imported!" \
	                      -icon error
	                      
	    } else {

	         set object [vTcl:image:create_new_image $newImageFile "user image" "user"]
         
	         # let's refresh!
	         vTcl:image:refresh_manager 1.0
		 
		 return $object
	    } 
	}
}

proc vTcl:image:replace_image {filename} {

	global vTcl tk_strictMotif

	set types $vTcl(image,filetypes)

	set tk_strictMotif 0
	set newImageFile [tk_getOpenFile -filetypes $types  -defaultextension .gif]
	set tk_strictMotif 1

	if {$newImageFile != ""} {

	    # just double-check that it doesn't exist!
    
	    if {[lsearch -exact $vTcl(images,files) $newImageFile] != -1} {
    
	        tk_messageBox -title "New image"  -message "Image already imported!"  -icon error
	    } else {
	    	
	    	set index [lsearch -exact $vTcl(images,files) $filename]
	    	set vTcl(images,files) \
	    	   [lreplace $vTcl(images,files) $index $index $newImageFile]
	    	
    		set object    [vTcl:image:get_image $filename]
    		
    		set oldreference [vTcl:rename $filename]
		set reference    [vTcl:rename $newImageFile]
		
		image create [vTcl:image:get_creation_type $newImageFile] $object -file $newImageFile
		
	        set vTcl(images,$reference,image)       $object
	        set vTcl(images,$reference,description) [vTcl:image:get_description $filename]
	        set vTcl(images,$reference,type)        [vTcl:image:get_type $filename]
	        set vTcl(images,filename,$object)       $newImageFile

		unset vTcl(images,$oldreference,image)
		unset vTcl(images,$oldreference,description)
		unset vTcl(images,$oldreference,type)
		
		set pos [vTcl:image:get_manager_position]
		vTcl:image:refresh_manager $pos
	    }
	}
}

proc vTcl:image:fill_noborder_image_list {t} {

	global vTcl

	update
	$t configure -state normal -tabs "[winfo width $t]p"
	$t delete 0.0 end

	foreach image $vTcl(images,files) {

            set object [vTcl:image:get_image $image]
	    set reference [vTcl:rename $image]
          
	    $t image create end -image $object
	    $t insert end " $image\t" vTcl:image_list:$object
	    $t insert end "\n\n"
	         
	    $t tag bind vTcl:image_list:$object <Enter> \
	        "$t tag configure vTcl:image_list:$object -relief raised -borderwidth 2"
           
	    $t tag bind vTcl:image_list:$object <Leave> \
	        "$t tag configure vTcl:image_list:$object -relief flat -borderwidth 0"

 	    $t tag bind vTcl:image_list:$object <ButtonPress-1> \
	        "set vTcl(images,selector_dlg,current) $object"
	}

	# add additional item to create a new image
	$t insert end "\nNew image...\t\n\t" vTcl:image_list:new

	$t tag bind vTcl:image_list:new <Enter> \
		"$t tag configure vTcl:image_list:new -relief raised -borderwidth 2"

	$t tag bind vTcl:image_list:new <Leave> \
		"$t tag configure vTcl:image_list:new -relief flat -borderwidth 0"
		
	$t tag bind vTcl:image_list:new <ButtonPress-1> \
		"set vTcl(images,selector_dlg,current) <new>"
	
	$t configure -state disabled
}

proc vTcl:image:create_selector_dlg {base} {

    if {$base == ""} {
        set base .vTcl.noborder_imagelist
    }
    
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    global vTcl
    global tcl_platform

    set vTcl(images,selector_dlg,win) $base
    set vTcl(images,selector_dlg,current)  ""
    
    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel \
        -background #bcbcbc -highlightbackground #bcbcbc \
        -highlightcolor #000000 
    wm focusmodel $base passive

    vTcl:prepare_pulldown $base 496 252
    
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm resizable $base 1 1
    wm deiconify $base

    frame $base.cpd29 \
        -background #bcbcbc -borderwidth 1 -height 30 \
        -highlightbackground #bcbcbc -highlightcolor #000000 -relief raised \
        -width 30 
    scrollbar $base.cpd29.02 \
        -activebackground #bcbcbc -background #bcbcbc -borderwidth 1 \
        -command "$base.cpd29.03 yview" -cursor left_ptr \
        -highlightbackground #bcbcbc -highlightcolor #000000 -orient vert \
        -troughcolor #bcbcbc
    text $base.cpd29.03 \
        -background #bcbcbc \
        -foreground #000000 -highlightbackground #f3f3f3 \
        -highlightcolor #000000 -selectbackground #000080 \
        -selectforeground #ffffff -state disabled \
        -yscrollcommand "$base.cpd29.02 set" -cursor left_ptr
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.cpd29 \
        -in $base -anchor center -expand 1 -fill both -side top 
    grid columnconf $base.cpd29 0 -weight 1
    grid rowconf $base.cpd29 0 -weight 1
    grid $base.cpd29.02 \
        -in $base.cpd29 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns 
    grid $base.cpd29.03 \
        -in $base.cpd29 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw 
        
    vTcl:display_pulldown $base 496 252

    vTcl:image:fill_noborder_image_list $base.cpd29.03
}

proc vTcl:prompt_user_image {target option} {

    global vTcl
    if {$target == ""} {return}
    set base ".vTcl.com_[vTcl:rename ${target}${option}]"
    
    if {[catch {set object [$target cget $option]}] == 1} {
        return
    }

    vTcl:image:create_selector_dlg ""

    # is there an initial filename ?
    if [info exist vTcl(images,filename,$object)] {
    
    }
        
    # don't reposition dialog according to parent
    vTcl:dialog_wait $vTcl(images,selector_dlg,win) vTcl(images,selector_dlg,current) 1
    destroy $vTcl(images,selector_dlg,win)
    
    # return value ?
    set r $vTcl(images,selector_dlg,current)

    # user wants a new image?
    if {$r == "<new>"} {
    	
    	set r [vTcl:image:new_image_file]
    }
        
    if {$r != ""} {
	    $target configure $option $r

	    # refresh property manager
	    vTcl:update_widget_info $target
	    vTcl:prop:update_attr
    }
}

proc vTcl:image:dump_proc {fileID name} {

	puts $fileID "proc $name {" nonewline
	puts $fileID "[info args $name]} {" nonewline
	puts $fileID "[info body $name]}" 

	puts $fileID ""
}

proc vTcl:image:generate_image_stock {fileID} {
	
	global vTcl
	
	puts $fileID {############################}
	puts $fileID "\# code to load stock images\n"
        puts $fileID "\nif {!\[info exist vTcl(sourcing)\]} \{"

	vTcl:image:dump_proc $fileID "vTcl:rename"
	vTcl:image:dump_proc $fileID "vTcl:image:create_new_image"
	vTcl:image:dump_proc $fileID "vTcl:image:get_image"
	vTcl:image:dump_proc $fileID "vTcl:image:get_creation_type"
		
	foreach image $vTcl(images,files) {

		if {[vTcl:image:get_type $image] == "stock"} {
			
			puts $fileID "vTcl:image:create_new_image \"$image\" " nonewline
			puts $fileID "\"[vTcl:image:get_description $image]\" " nonewline
			puts $fileID "\"[vTcl:image:get_type $image]\""
		}
	}
	
	puts $fileID "\}"
}

proc vTcl:image:generate_image_user {fileID} {

	global vTcl

	puts $fileID {############################}
	puts $fileID "\# code to load user images\n"
	
	foreach image $vTcl(images,files) {

		if {[vTcl:image:get_type $image] == "user"} {
			
			puts $fileID "vTcl:image:create_new_image \"$image\" " nonewline
			puts $fileID "\"[vTcl:image:get_description $image]\" " nonewline
			puts $fileID "\"[vTcl:image:get_type $image]\""
		}
	}
}

proc vTcl:image:delete_image {image} {

	global vTcl
	
	set object [vTcl:image:get_image $image]
	set reference [vTcl:rename $image]
			
	image delete $object
			
	set index [lsearch -exact $vTcl(images,files) $image]
	set vTcl(images,files) [lreplace $vTcl(images,files) $index $index]
			
	unset vTcl(images,$reference,image)
	unset vTcl(images,$reference,description)
	unset vTcl(images,$reference,type)
	unset vTcl(images,filename,$object)
}

proc vTcl:image:ask_delete_image {image} {
	
	set result [
	
		tk_messageBox \
			-message "Do you want to remove $image from the project?" \
			-title "Visual Tcl" \
			-type yesno \
			-icon question
	]
	
	if {$result == "yes"} {
		
		set pos [vTcl:image:get_manager_position]

		vTcl:image:delete_image $image
		vTcl:image:refresh_manager $pos
	}
}

proc vTcl:image:remove_user_images {} {

	global vTcl
	
	foreach image $vTcl(images,files) {

		if {[vTcl:image:get_type $image] == "user"} {
	
			vTcl:image:delete_image $image		
		}
	}
	
	vTcl:image:refresh_manager
}

proc vTclWindow.vTcl.imgManager {args} {
	
    set base ""
    if {$base == ""} {
        set base .vTcl.imgManager
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }

    global vTcl
    set vTcl(images,manager_dlg,status) ""
    set vTcl(images,manager_dlg,win) $base

    ###################
    # CREATING WIDGETS
    ###################
    toplevel $base -class Toplevel \
        -background #bcbcbc -highlightbackground #bcbcbc \
        -highlightcolor #000000 
    wm focusmodel $base passive
    wm geometry $base 494x581+405+156
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm deiconify $base
    wm title $base "Image manager"
    wm protocol $base WM_DELETE_WINDOW "wm withdraw $base"
    wm transient .vTcl.imgManager .vTcl
    
    label $base.lab28 \
        -background #bcbcbc -borderwidth 1 \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -relief sunken -text Images 
    frame $base.cpd29 \
        -background #bcbcbc -borderwidth 1 -height 30 \
        -highlightbackground #bcbcbc -highlightcolor #000000 -relief raised \
        -width 30 
    scrollbar $base.cpd29.01 \
        -activebackground #bcbcbc -background #bcbcbc -borderwidth 1 \
        -command "$base.cpd29.03 xview" -cursor left_ptr \
        -highlightbackground #bcbcbc -highlightcolor #000000 -orient horiz \
        -troughcolor #bcbcbc
    scrollbar $base.cpd29.02 \
        -activebackground #bcbcbc -background #bcbcbc -borderwidth 1 \
        -command "$base.cpd29.03 yview" -cursor left_ptr \
        -highlightbackground #bcbcbc -highlightcolor #000000 -orient vert \
        -troughcolor #bcbcbc 
    text $base.cpd29.03 \
        -background #bcbcbc -cursor left_ptr \
        -foreground #000000 -height 1 -highlightbackground #f3f3f3 \
        -highlightcolor #000000 -selectbackground #000080 \
        -selectforeground #ffffff -state disabled -tabs {0.2i 3i 3.75i} \
        -width 8 -wrap none -xscrollcommand "$base.cpd29.01 set" \
        -yscrollcommand "$base.cpd29.02 set"
    frame $base.fra30 \
        -background #bcbcbc -borderwidth 2 -height 75 \
        -highlightbackground #bcbcbc -highlightcolor #000000 -relief groove \
        -width 125 
    button $base.fra30.but31 \
        -activebackground #bcbcbc -activeforeground #000000 \
        -background #bcbcbc \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -padx 9 -pady 3 -text Close \
        -command "wm withdraw $base"
    button $base.but32 \
        -activebackground #bcbcbc -activeforeground #000000 \
        -background #bcbcbc -command vTcl:image:new_image_file \
        -foreground #000000 -highlightbackground #bcbcbc \
        -highlightcolor #000000 -padx 9 -pady 3 -text {Add new image...} 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.lab28 \
        -in $base -anchor center -expand 0 -fill x -side top 
    pack $base.cpd29 \
        -in $base -anchor center -expand 1 -fill both -side top 
    grid columnconf $base.cpd29 0 -weight 1
    grid rowconf $base.cpd29 0 -weight 1
    grid $base.cpd29.01 \
        -in $base.cpd29 -column 0 -row 1 -columnspan 1 -rowspan 1 -sticky ew 
    grid $base.cpd29.02 \
        -in $base.cpd29 -column 1 -row 0 -columnspan 1 -rowspan 1 -sticky ns 
    grid $base.cpd29.03 \
        -in $base.cpd29 -column 0 -row 0 -columnspan 1 -rowspan 1 \
        -sticky nesw 
    pack $base.fra30 \
        -in $base -anchor center -expand 0 -fill x -side bottom 
    pack $base.fra30.but31 \
        -in $base.fra30 -anchor center -expand 0 -fill x -side bottom 
    pack $base.but32 \
        -in $base -anchor center -expand 0 -fill x -side top 

    catch {wm geometry $base $vTcl(geometry,$base)}
    
    vTcl:image:init_img_manager
}

proc vTcl:image:prompt_image_manager {} {

    Window show .vTcl.imgManager
}

proc vTcl:image:get_files_list {} {
	
	global vTcl
	
	return $vTcl(images,files)
}

# translation for options when saving files
set vTcl(option,translate,-image) vTcl:image:translate
set vTcl(option,noencase,-image) 1

proc vTcl:image:translate {value} {

	global vTcl
	
       	if [info exists vTcl(images,filename,$value)] {

      		set value "\[vTcl:image:get_image \"$vTcl(images,filename,$value)\"\]"
      	}
      	
      	return $value
}

proc vTcl:image:refresh_manager {{position 0.0}} {

	global vTcl
		
        if [info exists vTcl(images,manager_dlg,win)] {
	         	
	       	if [winfo exists $vTcl(images,manager_dlg,win)] {

	         	vTcl:image:init_img_manager
			$vTcl(images,manager_dlg,win).cpd29.03 yview moveto $position
		}
	}
}

proc vTcl:image:get_manager_position {} {
	
	global vTcl
	
	return [lindex [$vTcl(images,manager_dlg,win).cpd29.03 yview] 0]
}
