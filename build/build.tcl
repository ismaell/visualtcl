#!/usr/bin/tclsh

set bldroot /home/work/vtcl_new
set bldtmp $bldroot/build/tmp

file delete -force $bldtmp
file mkdir $bldtmp

set copyroot $bldtmp/vtcl-1.2.2/usr/local/vtcl-1.2.2

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
eval exec cp [glob $bldroot/sample/*.*]        $copyroot/sample

cd $bldtmp
exec tar cf - -C $bldtmp vtcl-1.2.2 | gzip >vtcl-1.2.2.tar.gz

cd $copyroot/..
exec tar cf - -C . vtcl-1.2.2 | gzip >vtcl-1.2.2.tar.gz

cd $bldroot/build
file copy -force vtcl-1.2.2-1.spec /root/RPM/SPECS
file copy -force $bldtmp/vtcl-1.2.2.tar.gz /root/RPM/SOURCES
file copy -force $bldroot/images/title.gif /root/RPM/SOURCES

exec /bin/rpm -bb /root/RPM/SPECS/vtcl-1.2.2-1.spec
