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
   {{All Files}          *            }
   {{GIF Files}          {.gif}       }
   {{Portable Pixel Map} {.ppm}       }
   {{X Windows Bitmap}   {.xbm}       }
}

# returns "photo" if a GIF or "bitmap" if a xbm

proc vTcl:image:get_creation_type {filename} {
    switch [string tolower [file extension $filename]] {
        .ppm -
        .jpg -
        .bmp -
        .gif    {return photo}
        .xbm    {return bitmap}
        default {return photo}
    }
}

proc vTcl:image:broken_image {} {
    return {
        R0lGODdhFAAUAPcAAAAAAIAAAACAAICAAAAAgIAAgACAgMDAwICAgP8AAAD/
        AP//AAAA//8A/wD//////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAACwAAAAAFAAUAAAIhAAPCBxIsKDBgwgPAljIUOBC
        BAkBPJg4UeBEBBAVPkCI4EHGghIHChAwsKNHgyEPCFBA0mFDkBtVjiz4AADK
        mAds0tRJMCVBBkAl8hwYMsFPBwyE3jzQwKhAoASUwmTagCjDmksbVDWIderC
        g1174gQ71CHFigfOhrXKUGfbrwnjyp0bEAA7
    }
}

proc {vTcl:image:create_new_image} {filename
                                    {description {no description}}
                                    {type {}}
                                    {data {}}} {
    global vTcl env

    # Does the image already exist?
    if {[info exists vTcl(images,files)]} {
        if {[lsearch -exact $vTcl(images,files) $filename] > -1} { return }
    }

    if {![info exists vTcl(sourcing)] && [string length $data] > 0} {
        set object [image create \
            [vTcl:image:get_creation_type $filename] \
            -data $data]
    } else {
        # Wait a minute... Does the file actually exist?
        if {! [file exists $filename] } {
            # Try current directory
            set script [file dirname [info script]]
            set filename [file join $script [file tail $filename] ]
        }

        if {![file exists $filename]} {
            set description "file not found!"
            set object [image create photo -data [vTcl:image:broken_image] ]
        } else {
            set object [image create \
                [vTcl:image:get_creation_type $filename] \
                -file $filename]
        }
    }

    set reference [vTcl:rename $filename]

    set vTcl(images,$reference,image)       $object
    set vTcl(images,$reference,description) $description
    set vTcl(images,$reference,type)        $type
    set vTcl(images,filename,$object)       $filename

    lappend vTcl(images,files) $filename
    lappend vTcl(images,$type) $object

    # return image name in case caller might want it
    return $object
}

proc {vTcl:image:get_description} {filename} {
    set reference [vTcl:rename $filename]
    return $::vTcl(images,$reference,description)
}

proc {vTcl:image:get_type} {filename} {
    set reference [vTcl:rename $filename]
    return $::vTcl(images,$reference,type)
}

proc {vTcl:image:get_image} {filename} {
    set reference [vTcl:rename $filename]

    # Let's do some checking first
    if {![info exists ::vTcl(images,$reference,image)]} {
        # Well, the path may be wrong; in that case check
        # only the filename instead, without the path.

        set imageTail [file tail $filename]

        foreach oneFile $::vTcl(images,files) {
            if {[file tail $oneFile] == $imageTail} {
                set reference [vTcl:rename $oneFile]
                break
            }
        }
    }
    return $::vTcl(images,$reference,image)
}

proc {vTcl:image:init_img_manager} {} {
    global vTcl tcl_platform

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
		set vTcl(pr,imageeditor) \
		    "C:/Program Files/Accessories/mspaint.exe"
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
		 regsub -all / $realname {\\} realname
	    }

	    set file [file join $vTcl(VTCL_HOME) images edit open.gif]
	    button $base.${reference}_edit \
		-image [vTcl:image:get_image $file] \
		-command "vTcl:image:external_editor [list $realname]"

	    vTcl:set_balloon $base.${reference}_edit "Edit image"
	}

	if {$vTcl(images,$reference,type) == "user"} {
	    catch {
		set file [file join $vTcl(VTCL_HOME) images edit remove.gif]
		button $base.${reference}_delete \
		-image [vTcl:image:get_image $file] \
		-command "vTcl:image:ask_delete_image \"$image\""

		vTcl:set_balloon $base.${reference}_delete "Delete image"
	    }

	    catch {
		set file [file join $vTcl(VTCL_HOME) images edit replace.gif]
		button $base.${reference}_replace \
		-image [vTcl:image:get_image $file] \
		-command "vTcl:image:replace_image \"$image\""

		vTcl:set_balloon $base.${reference}_replace "Replace image"
	   }
       }

       $base insert end "$image: $vTcl(images,$reference,description)"
       $base insert end " ($vTcl(images,$reference,type))\n"
       $base insert end "[image type $object] [image width $object] x [image height $object]"
       $base insert end "\n\n\t"

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
    global vTcl

    catch {
        package require Img
        ## if Img is there, add more file types
        lappend vTcl(image,filetypes) \
                {{JPEG Images}     {.jpg}} \
                {{Windows Bitmaps} {.bmp}}
    }

    if [info exist vTcl(images,files)] {
	foreach image $vTcl(images,files) {
	    catch { image delete $image }
	}
    }

    set vTcl(images,files) ""

    set images {
    	copy
	cut
	inswidg
	paste
	new
	ok
	open
	save
	replace
	add
	remove
	show
	hide
	refresh
	search
	browse
    }

    foreach file $images {
	set file [file join $vTcl(VTCL_HOME) images edit $file.gif]
    	vTcl:image:create_new_image $file {} stock
    }
}

proc {vTcl:image:new_image_file} {} {
    global vTcl tk_strictMotif

    set types $vTcl(image,filetypes)

    set tk_strictMotif 0
    set newImageFile [tk_getOpenFile -filetypes $types  -defaultextension .gif]
    set tk_strictMotif 1

    set object ""

    if {[lempty $newImageFile]} { return }

    # just double-check that it doesn't exist!

    if {[lsearch -exact $vTcl(images,files) $newImageFile] != -1} {
	::vTcl::MessageBox -title "New image" \
	    -message "Image already imported!" \
	    -icon error

	return
    }
    set object [vTcl:image:create_new_image $newImageFile "user image" "user"]

    # let's refresh!
    vTcl:image:refresh_manager 1.0

    return $object
}

proc vTcl:image:replace_image {filename} {
    global vTcl tk_strictMotif

    set types $vTcl(image,filetypes)

    set tk_strictMotif 0
    set newImageFile [tk_getOpenFile -filetypes $types  -defaultextension .gif]
    set tk_strictMotif 1

    if {[lempty $newImageFile]} { return }

    # just double-check that it doesn't exist!

    if {[lsearch -exact $vTcl(images,files) $newImageFile] != -1} {
	::vTcl::MessageBox \
	    -title "New image" \
	    -message "Image already imported!" \
	    -icon error
	return
    }

    lremove vTcl(images,files) $filename

    set object [vTcl:image:get_image $filename]

    set oldreference [vTcl:rename $filename]
    set reference    [vTcl:rename $newImageFile]

    image create [vTcl:image:get_creation_type $newImageFile] \
        $object -file $newImageFile

    set vTcl(images,$reference,image)       $object
    set vTcl(images,$reference,description) \
        [vTcl:image:get_description $filename]
    set vTcl(images,$reference,type)        [vTcl:image:get_type $filename]
    set vTcl(images,filename,$object)       $newImageFile

    unset vTcl(images,$oldreference,image)
    unset vTcl(images,$oldreference,description)
    unset vTcl(images,$oldreference,type)

    set pos [vTcl:image:get_manager_position]
    vTcl:image:refresh_manager $pos
}

proc vTcl:image:tag_image_list {t tagname object} {

    $t tag bind $tagname <Enter> \
        "$t tag configure $tagname -background gray -relief raised -borderwidth 2"

    $t tag bind $tagname <Leave> \
        "$t tag configure $tagname -background white -relief flat -borderwidth 0"

    $t tag bind $tagname <ButtonPress-1> \
        "set vTcl(images,selector_dlg,current) $object"
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

        vTcl:image:tag_image_list $t \
                                  vTcl:image_list:$object \
                                  $object
    }

    # add additional item to create a new image
    $t insert end "\n New image...\t\n\t" vTcl:image_list:new

    vTcl:image:tag_image_list $t \
                              vTcl:image_list:new \
                              <new>

    # cancel
    $t insert end "\n Cancel\t\n\t" vTcl:image_list:cancel

    vTcl:image:tag_image_list $t \
                              vTcl:image_list:cancel \
                              <cancel>

    $t tag configure vTcl:image_list:cancel -foreground #ff0000

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

    ScrolledWindow $base.cpd29 -background #bcbcbc
    text $base.cpd29.03 \
        -background white \
        -foreground #000000 -highlightbackground #f3f3f3 \
        -highlightcolor #000000 -selectbackground #000080 \
        -selectforeground #ffffff -state disabled -cursor left_ptr
    $base.cpd29 setwidget $base.cpd29.03

    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.cpd29 \
        -in $base -anchor center -expand 1 -fill both -side top
    pack $base.cpd29.03

    vTcl:display_pulldown $base 496 252 \
        "set vTcl(images,selector_dlg,current) <cancel>"

    vTcl:image:fill_noborder_image_list $base.cpd29.03
}

proc vTcl:prompt_user_image {target option} {

    global vTcl
    if {$target == ""} {return}
    set base ".vTcl.com_[vTcl:rename ${target}${option}]"

    if {[catch {set object [$target cget $option]}] == 1} {
        return
    }

    set r [vTcl:prompt_user_image2 $object]

    if {$r != ""} {
	    $target configure $option $r

	    # refresh property manager
	    vTcl:update_widget_info $target
	    vTcl:prop:update_attr
    }
}

proc vTcl:prompt_user_image2 {image} {

    global vTcl

    vTcl:image:create_selector_dlg ""

    # is there an initial filename ?
    if [info exist vTcl(images,filename,$image)] {
    }

    # don't reposition dialog according to parent
    vTcl:dialog_wait $vTcl(images,selector_dlg,win) vTcl(images,selector_dlg,current) 1
    destroy $vTcl(images,selector_dlg,win)

    # return value ?
    set r $vTcl(images,selector_dlg,current)

    # user wants a new image?
    if {$r == "<new>"} {

        set r [vTcl:image:new_image_file]
    } elseif {$r == "<cancel>"} {

        set r ""
    }

    if {$r != ""} {
        return $r
    } else {
        return $image
    }
}

proc vTcl:image:dump_create_image {image} {

    global vTcl

    if { ! [info exists vTcl(pr,saveimagesinline)] } {

    	set vTcl(pr,saveimagesinline) 0
    }

    if {$vTcl(pr,saveimagesinline)} {

        set inline \n[::base64::encode_file $image]
    } else {

        set inline ""
    }

    set result [list \
                   [vTcl:portable_filename $image] \
                   [vTcl:image:get_description $image] \
                   [vTcl:image:get_type $image] \
                   $inline]

    return $vTcl(tab)$vTcl(tab)[list $result]
}

proc vTcl:image:dump_create_image_header {} {

    global vTcl

    return "foreach img \{\n"
}

proc vTcl:image:dump_create_image_footer {} {

    global vTcl

    set result ""
    append result "\n$vTcl(tab)$vTcl(tab)$vTcl(tab)\} \{\n"
    append result "$vTcl(tab)eval set _file \[lindex \$img 0\]\n"
    append result "$vTcl(tab)vTcl:image:create_new_image\\\n"
    append result "$vTcl(tab)$vTcl(tab)"
    append result "\$_file \[lindex \$img 1\] "
    append result "\[lindex \$img 2\] \[lindex \$img 3\]\n"
    append result "\}\n"
}

proc vTcl:image:generate_image_stock {fileID} {
    global vTcl

    ## We're not using any images.  We don't need this code.
    if {[lempty $vTcl(dump,stockImages)] && [lempty $vTcl(dump,userImages)]} {
    	return
    }

    puts $fileID "\n"
    puts $fileID {#############################################################################}
    puts $fileID "\#\# vTcl Code to Load Stock Images\n"
    puts $fileID "\nif {!\[info exist vTcl(sourcing)\]} \{"

    foreach i {vTcl:rename
               vTcl:image:create_new_image
               vTcl:image:get_image
               vTcl:image:get_creation_type
               vTcl:image:broken_image} {
        puts $fileID [vTcl:dump_proc $i]
    }

    puts $fileID [vTcl:image:dump_create_image_header]

    foreach image $vTcl(dump,stockImages) {
	set file $vTcl(images,filename,$image)
	puts $fileID [vTcl:image:dump_create_image $file]
    }

    puts $fileID [vTcl:image:dump_create_image_footer]
    puts $fileID "\}"
}

proc vTcl:image:generate_image_user {fileID} {
    global vTcl

    if {[lempty $vTcl(dump,userImages)]} { return }

    puts $fileID {#############################################################################}
    puts $fileID "\#\# vTcl Code to Load User Images\n"
    puts $fileID "catch \{package require Img\}\n"

    puts $fileID [vTcl:image:dump_create_image_header]

    foreach image $vTcl(dump,userImages) {
	set file $vTcl(images,filename,$image)
	puts $fileID [vTcl:image:dump_create_image $file]
    }

    puts $fileID [vTcl:image:dump_create_image_footer]
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
	::vTcl::MessageBox \
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

proc vTcl:image:reload_images {} {
    global vTcl

    foreach image $vTcl(images,files) {
        set object [vTcl:image:get_image $image]
        $object configure -file $image
    }
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
    toplevel $base -class Toplevel
    wm withdraw $base
    wm focusmodel $base passive
    wm maxsize $base 1009 738
    wm minsize $base 1 1
    update
    wm overrideredirect $base 0
    wm resizable $base 1 1
    wm title $base "Image manager"
    wm protocol $base WM_DELETE_WINDOW "wm withdraw $base"
    wm transient .vTcl.imgManager .vTcl

    ScrolledWindow $base.cpd29
    text $base.cpd29.03 \
        -background white -cursor left_ptr \
        -height 1 -borderwidth 0 \
        -state disabled -tabs {0.2i 3i 3.75i} \
        -width 8 -wrap none
    $base.cpd29 setwidget $base.cpd29.03

    frame $base.butfr
    vTcl:toolbar_button $base.butfr.but32 \
        -command vTcl:image:new_image_file \
        -padx 3 -pady 3 -image [vTcl:image:get_image add.gif]
    vTcl:toolbar_button $base.butfr.but34 \
        -command vTcl:image:reload_images \
        -padx 3 -pady 3 -image [vTcl:image:get_image refresh.gif]
    ::vTcl::OkButton $base.butfr.but33 -command "Window hide $base"
    ###################
    # SETTING GEOMETRY
    ###################
    pack $base.cpd29 \
        -in $base -anchor center -expand 1 -fill both -side bottom
    pack $base.cpd29.03

    pack $base.butfr -fill x -side top
    pack $base.butfr.but32 \
        -anchor nw -expand 0 -fill none -side left
    vTcl:set_balloon $base.butfr.but32 "Add new image"
    pack $base.butfr.but34 \
        -anchor nw -expand 0 -fill none -side left
    vTcl:set_balloon $base.butfr.but34 "Reload images"
    pack $base.butfr.but33 \
    	-anchor nw -expand 0 -fill none -side right
    vTcl:set_balloon $base.butfr.but33 "Close"

    wm geometry $base 494x581
    vTcl:center $base 494 581
    catch {wm geometry $base $vTcl(geometry,$base)}
    wm deiconify $base

    vTcl:image:init_img_manager
    vTcl:setup_vTcl:bind $base
}

proc vTcl:image:prompt_image_manager {} {

    Window show .vTcl.imgManager
}

proc vTcl:image:get_files_list {} {
    global vTcl

    if {$vTcl(pr,saveimagesinline)} {

        # if we save images inline we don't need to wrap them
        return ""
    }

    return $vTcl(images,files)
}

# translation for options when saving files
set vTcl(option,translate,-image) vTcl:image:translate
set vTcl(option,noencase,-image) 1

proc vTcl:image:translate {value} {
    global vTcl

    if [info exists vTcl(images,filename,$value)] {
        set newvalue "\[vTcl:image:get_image "
        append newvalue "[vTcl:portable_filename $vTcl(images,filename,$value)]\]"
        return $newvalue
    } else {
        return $value
    }
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

proc vTcl:image:external_editor {imageName} {
    global vTcl
    if {[catch {exec "$vTcl(pr,imageeditor)" "$imageName" &}]} {
        vTcl:error "Could not execute external image editor!"
    }
}
