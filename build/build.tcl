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

set version 1.2.2b1
set bldroot /home/work/vtcl_new
set bldtmp $bldroot/build/tmp

file delete -force $bldtmp
file mkdir $bldtmp

set copyroot $bldtmp/vtcl-$version/usr/local/vtcl-$version

file mkdir $copyroot
file mkdir $copyroot/lib
file mkdir $copyroot/images/edit
file mkdir $copyroot/doc
file mkdir $copyroot/demo
file mkdir $copyroot/demo/images
file mkdir $copyroot/sample

exec cp $bldroot/ChangeLog                     $copyroot
exec cp $bldroot/LICENSE                       $copyroot
exec cp $bldroot/README                        $copyroot
exec cp $bldroot/vtcl                          $copyroot
exec cp $bldroot/vtclmac                       $copyroot
exec cp $bldroot/vt.tcl                        $copyroot
exec cp $bldroot/vtsetup.tcl                   $copyroot
exec cp $bldroot/vtcl                          $copyroot
eval exec cp $bldroot/lib/remove.sh            $copyroot/lib
eval exec cp $bldroot/lib/Makefile             $copyroot/lib
eval exec cp [glob $bldroot/lib/*.tcl]         $copyroot/lib
eval exec cp [glob $bldroot/images/*.ppm]      $copyroot/images
eval exec cp [glob $bldroot/images/*.xbm]      $copyroot/images
eval exec cp [glob $bldroot/images/*.xpm]      $copyroot/images
eval exec cp [glob $bldroot/images/*.gif]      $copyroot/images
eval exec cp [glob $bldroot/images/edit/*.gif] $copyroot/images/edit
eval exec cp [glob $bldroot/doc/*.*]           $copyroot/doc
eval exec cp [glob $bldroot/demo/*.*]          $copyroot/demo
eval exec cp $bldroot/demo/README              $copyroot/demo
eval exec cp [glob $bldroot/demo/images/*.*]   $copyroot/demo/images
eval exec cp [glob $bldroot/sample/*.tcl]       $copyroot/sample

cd $bldtmp
exec tar cf - -C $bldtmp vtcl-$version | gzip >vtcl-$version.tar.gz

cd $copyroot/..
exec tar cf - -C . vtcl-$version | gzip >vtcl-$version.tar.gz

cd $bldroot/build
file copy -force vtcl-$version-1.spec /root/RPM/SPECS
file copy -force $bldtmp/vtcl-$version.tar.gz /root/RPM/SOURCES
file copy -force $bldroot/images/title.gif /root/RPM/SOURCES

exec /bin/rpm -bb /root/RPM/SPECS/vtcl-$version-1.spec
