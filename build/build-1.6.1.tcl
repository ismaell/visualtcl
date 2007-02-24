#!/usr/bin/tclsh
#############################################################################
#
#
# build-1.6.1.tcl
#
# Tcl script to generate a tar/gz installation file for the
# 1.6.1 vTcl version path.
#
# Copyright (C) 2007 http://vtcl.sourceforge.net/
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
#
##############################################################################

#
# Notes:
#
# The script has 1 *optional* argument: the release "type", like "a1", "b2".
#
# Run this script inside directory "build" (where it is placed in CVS).
#
# Should be kept as platform independent as possible. Currently it depends
# only on tar and gzip.
#
# This script is idem-potent; it can be called several times with the same
# result. So, if it fails for some reason, fix the reason and just re-run it.
#

#=============================================================================
# Static configuration

set version  1.6.1[lindex $argv 0]

set dirsToRelease  {demo doc freewrap images lib sample}

set topFilesToRelease  {ChangeLog configure LICENSE README vtcl.tcl vtclmac}

#=============================================================================


proc deleteControlFiles {dir}  {
    foreach file [glob -nocomplain "$dir/*"]  {
        if {[file isdir $file]}  {
            if {[file tail $file] == "CVS"}  {
                file delete -force $file
            } else {
                deleteControlFiles $file
            }
        }
    }
}


#=============================================================================
# Let's make a local directory and copy into there the files of interest.
# In the end, we'll zip it all.

set root  vtcl-$version

file delete -force $root

file mkdir $root

# Copy top files
foreach file $topFilesToRelease  {
    file copy ../$file $root
}

# Copy directories
foreach dir $dirsToRelease  {
    file copy ../$dir $root
}

# Remove the CVS directories and other possible control/meta files
deleteControlFiles $root

# tar-gzip it...
exec tar czf $root.tar.gz $root

# and cleanup.
file delete -force $root

puts "$root released!..."


