#!/opt/tcltk/bin/tclsh8.3
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

set version 1.5.1b2
set bldroot /home/cgavin/vtcl
set bldtmp $bldroot/build/tmp

file delete -force $bldtmp
file mkdir $bldtmp

set copyroot $bldtmp/vtcl-$version/usr/local/vtcl-$version

file mkdir $copyroot
file mkdir $copyroot/lib
file mkdir $copyroot/lib/Help
file mkdir $copyroot/lib/Widgets
file mkdir $copyroot/lib/Widgets/bwidget
file mkdir $copyroot/lib/Widgets/core
file mkdir $copyroot/lib/Widgets/tix
file mkdir $copyroot/lib/Widgets/user
file mkdir $copyroot/lib/Widgets/vtcl
file mkdir $copyroot/lib/Widgets/itcl
file mkdir $copyroot/lib/Widgets/blt
file mkdir $copyroot/lib/Widgets/table
file mkdir $copyroot/images/edit
file mkdir $copyroot/doc
file mkdir $copyroot/demo
file mkdir $copyroot/demo/images
file mkdir $copyroot/sample

exec cp $bldroot/ChangeLog                                $copyroot
exec cp $bldroot/LICENSE                                  $copyroot
exec cp $bldroot/README                                   $copyroot
exec cp $bldroot/vtclmac                                  $copyroot
exec cp $bldroot/vtcl.tcl                                 $copyroot
exec cp $bldroot/vtsetup.tcl                              $copyroot
exec cp $bldroot/configure                                $copyroot
eval exec cp [glob $bldroot/lib/*.tcl]                    $copyroot/lib
eval exec cp [glob $bldroot/lib/Help/Main]                $copyroot/lib/Help
eval exec cp [glob $bldroot/lib/Help/Preferences]         $copyroot/lib/Help
eval exec cp [glob $bldroot/lib/Help/PropManager]         $copyroot/lib/Help
eval exec cp [glob $bldroot/lib/Help/WidgetTree]          $copyroot/lib/Help
eval exec cp [glob $bldroot/lib/Help/Tips]                $copyroot/lib/Help
eval exec cp [glob $bldroot/lib/Widgets/bwidget/*.*]      $copyroot/lib/Widgets/bwidget
eval exec cp [glob $bldroot/lib/Widgets/core/*.*]         $copyroot/lib/Widgets/core
eval exec cp [glob $bldroot/lib/Widgets/tix/*.*]          $copyroot/lib/Widgets/tix
#eval exec cp [glob $bldroot/lib/Widgets/user/*.*]        $copyroot/lib/Widgets/user
eval exec cp [glob $bldroot/lib/Widgets/vtcl/*.*]         $copyroot/lib/Widgets/vtcl
eval exec cp [glob $bldroot/lib/Widgets/itcl/*.*]         $copyroot/lib/Widgets/itcl
eval exec cp [glob $bldroot/lib/Widgets/blt/*.*]          $copyroot/lib/Widgets/blt
eval exec cp [glob $bldroot/lib/Widgets/table/*.*]        $copyroot/lib/Widgets/table
eval exec cp [glob $bldroot/images/*.ppm]                 $copyroot/images
eval exec cp [glob $bldroot/images/*.xbm]                 $copyroot/images
eval exec cp [glob $bldroot/images/*.xpm]                 $copyroot/images
eval exec cp [glob $bldroot/images/*.gif]                 $copyroot/images
eval exec cp [glob $bldroot/images/edit/*.gif]            $copyroot/images/edit
eval exec cp [glob $bldroot/doc/*.*]                      $copyroot/doc
eval exec cp [glob $bldroot/demo/*.*]                     $copyroot/demo
eval exec cp $bldroot/demo/README                         $copyroot/demo
eval exec cp [glob $bldroot/demo/images/*.*]              $copyroot/demo/images
eval exec cp [glob $bldroot/sample/*.tcl]                 $copyroot/sample

# temp for the alpha version
file delete -force $copyroot/lib/lib_bwidget.tcl
file delete -force $copyroot/lib/lib_mclistbox.tcl
file delete -force $copyroot/lib/lib_tcombobox.tcl
file delete -force $copyroot/lib/lib_user.tcl

cd $bldtmp
exec tar cf - -C $bldtmp vtcl-$version | gzip >vtcl-$version.tar.gz

cd $copyroot/..
exec tar cf - -C . vtcl-$version | gzip >vtcl-$version.tar.gz

# cd $bldroot/build
# file copy -force vtcl-$version-1.spec /root/RPM/SPECS
# file copy -force $bldtmp/vtcl-$version.tar.gz /root/RPM/SOURCES
# file copy -force $bldroot/images/title.gif /root/RPM/SOURCES

# exec /bin/rpm -bb /root/RPM/SPECS/vtcl-$version-1.spec
