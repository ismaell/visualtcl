##############################################################################
#
# menu.tcl - library of main app menu items
#
# Copyright (C) 1996-1998 Stewart Allen
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

set vTcl(menu,file) {
    {New              Ctrl+N       vTcl:new                   }
    {separator        {}           {}                         }
    {Open...          Ctrl+O       vTcl:open                  }
    {Save             Ctrl+S       vTcl:save                  }
    {{Save As...}     {}           vTcl:save_as               }
    {{Save As With Binary...} {}   vTcl:save_as_binary        }
    {Close            Ctrl+W       vTcl:close                 }
    {separator        {}           {}                         }
    {Source...        {}           vTcl:file_source           }
    {Preferences...   {}           vTclWindow.vTcl.prefs      }
    {separator        {}           {}                         }
    {Quit             Ctrl+Q       vTcl:quit                  }
}

set vTcl(menu,edit) {
    {Undo             Ctrl+Z       vTcl:pop_action            }
    {Redo             Ctrl+R       vTcl:redo_action           }
    {separator        {}           {}                         }
    {Cut              Ctrl+X       vTcl:cut                   }
    {Copy             Ctrl+C       vTcl:copy                  }
    {Paste            Ctrl+V       vTcl:paste                 }
    {separator        {}           {}                         }
    {Delete           {}           vTcl:delete                }
    {separator        {}           {}                         }
    {Images...        {}           vTcl:image:prompt_image_manager }
    {Fonts...         {}           vTcl:font:prompt_font_manager   }
}

set vTcl(menu,mode) {
    {{Test Mode}      Alt+T        {vTcl:setup_unbind_tree .} }
    {{Edit Mode}      Alt+E        {vTcl:setup_bind_tree .}   }
}

set vTcl(menu,system) {
}

set vTcl(menu,user) {
}

set vTcl(menu,insert) {
    {{System}         {menu system} {} }
    {{User}           {menu user}   {} }
}

set vTcl(menu,compound) {
    {Create           Alt+C         {vTcl:name_compound $vTcl(w,widget)} }
    {Insert           {menu insert} {}                         }
    {separator        {}            {}                         }
    {{Save Compounds...} {}            vTcl:save_compounds        }
    {{Load Compounds...} {}            vTcl:load_compounds        }
    {separator        {}            {}                         }
    {{Save as Tclet}  {}            {vTcl:create_tclet $vTcl(w,widget)}  }
}

set vTcl(menu,options) {
    {{Set Insert}      Alt+I        vTcl:set_insert            }
    {{Set Alias}       Alt+A        {vTcl:set_alias $vTcl(w,widget)}     }
    {separator         {}           {}                         }
    {{Select Toplevel} {}           vTcl:select_toplevel       }
    {{Select Parent}   {}           vTcl:select_parent         }
    {separator         {}           {}                         }
    {Bindings          Alt+B        vTcl:show_bindings         }
    {Properties        Alt+P        {vTcl:properties $vTcl(w,widget)}    }
    {separator         {}           {}                         }
    {Hide              {}           vTcl:hide                  }
}

#    {Project             {}        vTcl:project:show          }
set vTcl(menu,window) {
    {{Attribute Editor}  {}         vTcl:show_propmgr          }
    {{Function List}     {}         {vTcl:proclist:show 1}     }
    {{Window List}       {}         {vTcl:toplist:show 1}      }
    {separator           {}         {}                         }
    {{Command Console}   {}         vTcl:show_console          }
    {{Widget Tree}       Alt+W      vTcl:show_wtree            }
}

set vTcl(menu,help) {
    {{About Visual Tcl...}  {}         vTclWindow.vTcl.about      }
    {{Libraries...}         {}         vTclWindow.vTcl.infolibs   }
    {{Index of Help...}     {}         vTclWindow.vTcl.help       }
}

proc vTcl:menu:insert {menu name {root ""}} {
    global vTcl tcl_version
    if {$tcl_version >= 8} {
        set tab ""
    } else {
        set tab "\t"
    }
    if {$root != ""} {
        if {![winfo exists $root]} {
            menu $root
        }
        $root add cascade -label [vTcl:upper_first $name] -menu $menu
    }
    menu $menu -tearoff 0
    set vTcl(menu,$name,m) $menu
    foreach item $vTcl(menu,$name) {
        set txt [lindex $item 0]
        set acc [lindex $item 1]
        if {[llength $acc] > 1} {
            vTcl:menu:insert $menu.[lindex $acc 1] [lindex $acc 1] $menu
        } else {
            set cmd [lindex $item 2]
            if {$txt == "separator"} {
                $menu add separator
            } else {
                $menu add command -label $txt$tab -accel $acc -command $cmd
                set vTcl(menu,$name,widget) $menu
            }
        }
    }
}


