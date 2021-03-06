#!/usr/bin/tclsh
##############################################################################
#
# build.tcl
#
# Tcl script file to:
#
# 1) generate a tar/gz installation for those who don't want to use RPM
#
# 2) generate a RPM file for Redhat / Mandrake users
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

set version 1.6.0
set bldroot d:/cygwin/home/cgavin/vtcl
set bldtmp $bldroot/build/tmp

file delete -force $bldtmp
file mkdir $bldroot/build
file mkdir $bldtmp

set copyroot $bldtmp/vtcl-$version/opt/local/vtcl-$version

file mkdir $copyroot
file mkdir $copyroot/lib
file mkdir $copyroot/lib/bwidget
file mkdir $copyroot/lib/bwidget/lang
file mkdir $copyroot/lib/bwidget/images
file mkdir $copyroot/lib/Help
file mkdir $copyroot/lib/ttd
file mkdir $copyroot/lib/Widgets
file mkdir $copyroot/lib/Widgets/bwidget
file mkdir $copyroot/lib/Widgets/core
file mkdir $copyroot/lib/Widgets/tix
file mkdir $copyroot/lib/Widgets/user
file mkdir $copyroot/lib/Widgets/vtcl
file mkdir $copyroot/lib/Widgets/itcl
file mkdir $copyroot/lib/Widgets/blt
file mkdir $copyroot/lib/Widgets/table
file mkdir $copyroot/lib/Widgets/tablelist
file mkdir $copyroot/images/edit
file mkdir $copyroot/doc
file mkdir $copyroot/demo
file mkdir $copyroot/demo/images
file mkdir $copyroot/demo/tutorial
file mkdir $copyroot/demo/tutorial/core
file mkdir $copyroot/demo/tutorial/megawidgets
file mkdir $copyroot/demo/tutorial/megawidgets/imagelist
file mkdir $copyroot/demo/tutorial/megawidgets/databaseview
file mkdir $copyroot/demo/tutorial/megawidgets/listviewer
file mkdir $copyroot/sample

exec cp $bldroot/ChangeLog                                $copyroot
exec cp $bldroot/LICENSE                                  $copyroot
exec cp $bldroot/README                                   $copyroot
exec cp $bldroot/vtclmac                                  $copyroot
exec cp $bldroot/vtcl.tcl                                 $copyroot
exec cp $bldroot/configure                                $copyroot
eval exec cp [glob $bldroot/lib/*.tcl]                    $copyroot/lib
eval exec cp [glob $bldroot/lib/ttd/*.tcl]                $copyroot/lib/ttd
eval exec cp [glob $bldroot/lib/bwidget/*.tcl]            $copyroot/lib/bwidget
eval exec cp [glob $bldroot/lib/bwidget/lang/*.rc]        $copyroot/lib/bwidget/lang
eval exec cp [glob $bldroot/lib/bwidget/images/*.gif]     $copyroot/lib/bwidget/images
eval exec cp [glob $bldroot/lib/bwidget/images/*.xbm]     $copyroot/lib/bwidget/images
eval exec cp [glob $bldroot/lib/Help/Main]                $copyroot/lib/Help
eval exec cp [glob $bldroot/lib/Help/Preferences]         $copyroot/lib/Help
eval exec cp [glob $bldroot/lib/Help/PropManager]         $copyroot/lib/Help
eval exec cp [glob $bldroot/lib/Help/WidgetTree]          $copyroot/lib/Help
eval exec cp [glob $bldroot/lib/Help/Tips]                $copyroot/lib/Help
eval exec cp [glob $bldroot/lib/Help/About.txt]           $copyroot/lib/Help
eval exec cp [glob $bldroot/lib/Help/about.ttd]           $copyroot/lib/Help
eval exec cp [glob $bldroot/lib/Help/reference.ttd]       $copyroot/lib/Help
eval exec cp [glob $bldroot/lib/Widgets/bwidget/*.*]      $copyroot/lib/Widgets/bwidget
eval exec cp [glob $bldroot/lib/Widgets/core/*.*]         $copyroot/lib/Widgets/core
eval exec cp [glob $bldroot/lib/Widgets/tix/*.*]          $copyroot/lib/Widgets/tix
#eval exec cp [glob $bldroot/lib/Widgets/user/*.*]        $copyroot/lib/Widgets/user
eval exec cp [glob $bldroot/lib/Widgets/vtcl/*.*]         $copyroot/lib/Widgets/vtcl
eval exec cp [glob $bldroot/lib/Widgets/itcl/*.*]         $copyroot/lib/Widgets/itcl
eval exec cp [glob $bldroot/lib/Widgets/blt/*.*]          $copyroot/lib/Widgets/blt
eval exec cp [glob $bldroot/lib/Widgets/table/*.*]        $copyroot/lib/Widgets/table
eval exec cp [glob $bldroot/lib/Widgets/tablelist/*.*]    $copyroot/lib/Widgets/tablelist
eval exec cp [glob $bldroot/images/*.ppm]                 $copyroot/images
eval exec cp [glob $bldroot/images/*.xbm]                 $copyroot/images
eval exec cp [glob $bldroot/images/*.xpm]                 $copyroot/images
eval exec cp [glob $bldroot/images/*.gif]                 $copyroot/images
eval exec cp [glob $bldroot/images/edit/*.gif]            $copyroot/images/edit
eval exec cp [glob $bldroot/doc/*.*]                      $copyroot/doc
eval exec cp [glob $bldroot/demo/*.tcl]                   $copyroot/demo
eval exec cp [glob $bldroot/demo/*.ttd]                   $copyroot/demo
eval exec cp [glob $bldroot/demo/*.html]                  $copyroot/demo
eval exec cp $bldroot/demo/README                         $copyroot/demo
eval exec cp [glob $bldroot/demo/images/*.*]              $copyroot/demo/images
eval exec cp [glob $bldroot/demo/tutorial/core/*.tcl]     $copyroot/demo/tutorial/core
eval exec cp [glob $bldroot/demo/tutorial/megawidgets/imagelist/*.tcl]     $copyroot/demo/tutorial/megawidgets/imagelist
eval exec cp [glob $bldroot/demo/tutorial/megawidgets/imagelist/*.txt]     $copyroot/demo/tutorial/megawidgets/imagelist
eval exec cp [glob $bldroot/demo/tutorial/megawidgets/databaseview/*.tcl]  $copyroot/demo/tutorial/megawidgets/databaseview
eval exec cp [glob $bldroot/demo/tutorial/megawidgets/databaseview/*.txt]  $copyroot/demo/tutorial/megawidgets/databaseview
eval exec cp [glob $bldroot/demo/tutorial/megawidgets/listviewer/*.tcl]     $copyroot/demo/tutorial/megawidgets/listviewer
eval exec cp [glob $bldroot/sample/*.tcl]                 $copyroot/sample

# stuff to get rid of
file delete -force $copyroot/demo/bitmapbutton_compound.tcl
file delete -force $copyroot/demo/bitmapbutton_compound2.tcl
file delete -force $copyroot/demo/bitmapbutton_test.tcl
file delete -force $copyroot/demo/bitmapbutton_test_2.tcl
file delete -force $copyroot/demo/ex1_cmpd.tcl
file delete -force $copyroot/demo/makeunix.tcl
file delete -force $copyroot/demo/test1compound.tcl
file delete -force $copyroot/lib/makeunix.tcl
file delete -force $copyroot/lib/bwidget/makeunix.tcl
file delete -force $copyroot/lib/Widgets/bwidget/makeunix.tcl
file delete -force $copyroot/lib/Widgets/core/makeunix.tcl
file delete -force $copyroot/lib/Widgets/itcl/makeunix.tcl
file delete -force $copyroot/lib/Widgets/tix/makeunix.tcl
file delete -force $copyroot/lib/Widgets/blt/makeunix.tcl
file delete -force $copyroot/lib/Widgets/vtcl/makeunix.tcl
file delete -force $copyroot/demo/tutorial/core/makeunix.tcl
file delete -force $copyroot/demo/tutorial/megawidgets/databaseview/makeunix.tcl
file delete -force $copyroot/demo/tutorial/megawidgets/imagelist/makeunix.tcl
file delete -force $copyroot/demo/tutorial/megawidgets/listviewer/makeunix.tcl

# temp for the alpha version
file delete -force $copyroot/lib/lib_user.tcl

cd $bldtmp
exec tar cf - -C $bldtmp vtcl-$version | gzip >vtcl-$version.tar.gz

cd $copyroot/..
exec tar cf - -C . vtcl-$version | gzip >vtcl-$version.tar.gz

#cd $bldroot/build
#file copy -force vtcl-$version-1.spec         /root/rpm/SPECS
#file copy -force $bldtmp/vtcl-$version.tar.gz /root/rpm/SOURCES
#file copy -force $bldroot/images/title.gif    /root/rpm/SOURCES
#
#exec /bin/rpm -ba /root/rpm/SPECS/vtcl-$version-1.spec
