##############################################################################
#
# globals.tcl - global variables
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

# widget data record format:
# {type} {name} {alias} {option list} {manager record} {bind record} {child widget list}

# bind record format:
# { {bindtag} {bind list record} }  ...

# bind list record format:
# { {event} {command} } ...

# option list record format:
# { {name} {value} } ...

# widget manager record format:
# {type} {option list} {manager specific list}

global vTcl

set vTcl(action)         ""
set vTcl(action_index)   -1
set vTcl(action_limit)   -1
set vTcl(balloon,first)  0
set vTcl(balloon,set)    0
set vTcl(balloon,soon)   0
set vTcl(bind,ignore)    ""
set vTcl(change)         0
set vTcl(console)        0
set vTcl(cursor,last)    ""
set vTcl(procs)          "init main"
set vTcl(file,base)      [pwd]
set vTcl(file,mode)      ""
set vTcl(file,type)      "*.tcl"
set vTcl(grid,x)         5
set vTcl(grid,y)         5
set vTcl(gui,main)       ".vTcl"
set vTcl(gui,ae)         "$vTcl(gui,main).ae"
set vTcl(gui,command)    "$vTcl(gui,main).comm"
set vTcl(gui,console)    "$vTcl(gui,main).con"
set vTcl(gui,proc)       "$vTcl(gui,main).proc"
set vTcl(gui,proclist)   "$vTcl(gui,main).proclist"
set vTcl(gui,toplist)    "$vTcl(gui,main).toplist"
set vTcl(gui,mgr)        "$vTcl(gui,main).mgr"
set vTcl(gui,prefs)      "$vTcl(gui,main).prefs"
set vTcl(gui,rc_menu)    "$vTcl(gui,main).rc"
set vTcl(gui,varlist)    "$vTcl(gui,main).varlist"
set vTcl(gui,statbar)    "$vTcl(gui,main).stat.f.bar"
set vTcl(gui,showlist)   ".vTcl.mgr .vTcl.ae .vTcl.con"
set vTcl(h,exist)        no
set vTcl(h,size)         3
set vTcl(hide)           ""
set vTcl(item_num)       1
set vTcl(key,x)          1
set vTcl(key,y)          1
set vTcl(key,w)          1
set vTcl(key,h)          1
set vTcl(mgrs,update)    yes
# preferences
set vTcl(pr,attr_on)     1
set vTcl(pr,balloon)     1
set vTcl(pr,encase)      list
set vTcl(pr,font_dlg)    ""
set vTcl(pr,font_fixed)  ""
set vTcl(pr,getname)     0
set vTcl(pr,geom_on)     1
set vTcl(pr,geom_comm)   "350x200"
set vTcl(pr,geom_proc)   "500x400"
set vTcl(pr,info_on)     1
set vTcl(pr,manager)     place
set vTcl(pr,shortname)   1
set vTcl(pr,saveglob)    0
set vTcl(pr,show_func)   1
set vTcl(pr,show_var)    -1
set vTcl(pr,show_top)    -1
set vTcl(pr,winfocus)    0
# end preferences
set vTcl(proc,name)      ""
set vTcl(proc,args)      ""
set vTcl(proc,body)      ""
set vTcl(proc,ignore)    "tcl.*|tk.*|auto_.*|bgerror|\\..*"
set vTcl(project,name)   ""
set vTcl(project,file)   ""
set vTcl(quit)           1
set vTcl(tool,list)      ""
set vTcl(tool,last)      ""
set vTcl(toolbar,width) 2
set vTcl(tops)           ""
set vTcl(undo)           ""
set vTcl(vars)           ""
set vTcl(var,name)       ""
set vTcl(var,value)      ""
set vTcl(var,ignore)     "vTcl.*|tix.*"
set vTcl(var_update)     "yes"
set vTcl(w,alias)        ""
set vTcl(w,class)        ""
set vTcl(w,def_mgr)      $vTcl(pr,manager)
set vTcl(w,grabbed)      0
set vTcl(w,info)         ""
set vTcl(w,insert)       .
set vTcl(w,libs)         ""
set vTcl(w,manager)      ""
set vTcl(w,mgrs)         "grid pack place wm"
set vTcl(w,options)      ""
set vTcl(w,widget)       ""
set vTcl(winname)        "vTclWindow"
set vTcl(windows)        ".vTcl.toolbar .vTcl.mgr .vTcl.ae .vTcl.wstat
                          .vTcl.proclist .vTcl.varlist .vTcl.toplist .vTcl.tree
                          .vTcl.con .vTcl.prefs .vTcl.about .vTcl.bind"
set vTcl(newtops)        1
set vTcl(mode)           "EDIT"
set vTcl(pwd)            [pwd]
set vTcl(redo)           ""
set vTcl(save)           ""
set vTcl(tab)            "    "
set vTcl(tab2)           "$vTcl(tab)$vTcl(tab)"

set vTcl(cmpd,list)      ""
set vTcl(syscmpd,list)   ""

set vTcl(attr,tops)     "aspect command focusmodel geometry grid
                         iconbitmap iconmask iconname iconposition
                         iconwindow maxsize minsize overrideredirect
                         resizable sizefrom state title"

set vTcl(attr,winfo)    "children class geometry height ismapped
                         manager name parent rootx rooty toplevel
                         width x y"

#
# Default attributes to append on insert
#
set vTcl(grid,insert)   ""
set vTcl(pack,insert)   ""
set vTcl(place,insert)  "-x 5 -y 5 -bordermode ignore"

#
# Geometry Manager Attributes       LabelName     Balloon  Type   Choices   CfgCmd     Group
#
set vTcl(m,pack,list) "-anchor -expand -fill -side -ipadx -ipady -padx -pady -in"
set vTcl(m,pack,extlist) ""
set vTcl(m,pack,-anchor)           { anchor          {}       choice  {n ne e se s sw w nw center} }
set vTcl(m,pack,-expand)           { expand          {}       boolean {0 1} }
set vTcl(m,pack,-fill)             { fill            {}       choice  {none x y both} }
set vTcl(m,pack,-side)             { side            {}       choice  {top bottom left right} }
set vTcl(m,pack,-ipadx)            { {int. x pad}    {}       type    {} }
set vTcl(m,pack,-ipady)            { {int. y pad}    {}       type    {} }
set vTcl(m,pack,-padx)             { {ext. x pad}    {}       type    {} }
set vTcl(m,pack,-pady)             { {ext. y pad}    {}       type    {} }
set vTcl(m,pack,-in)               { inside          {}       type    {} }

set vTcl(m,place,list) "-anchor -x -y -relx -rely -width -height -relwidth -relheight -in"
set vTcl(m,place,extlist) ""
set vTcl(m,place,-anchor)          { {anchor}        {}       choice  {n ne e se s sw w nw center} }
set vTcl(m,place,-x)               { {x position}    {}       type    {} }
set vTcl(m,place,-y)               { {y position}    {}       type    {} }
set vTcl(m,place,-width)           { width           {}       type    {} }
set vTcl(m,place,-height)          { height          {}       type    {} }
set vTcl(m,place,-relx)            { {relative x}    {}       type    {} }
set vTcl(m,place,-rely)            { {relative y}    {}       type    {} }
set vTcl(m,place,-relwidth)        { {rel. width}    {}       type    {} }
set vTcl(m,place,-relheight)       { {rel. height}   {}       type    {} }
set vTcl(m,place,-in)              { inside          {}       type    {} }

set vTcl(m,grid,list) "-sticky -row -column -rowspan -columnspan -ipadx -ipady -padx -pady -in"
set vTcl(m,grid,extlist) ""
set vTcl(m,grid,-sticky)           { sticky          {}       type    {n s e w} }
set vTcl(m,grid,-row)              { row             {}       type    {} }
set vTcl(m,grid,-column)           { column          {}       type    {} }
set vTcl(m,grid,-rowspan)          { {row span}      {}       type    {} }
set vTcl(m,grid,-columnspan)       { {col span}      {}       type    {} }
set vTcl(m,grid,-ipadx)            { {int. x pad}    {}       type    {} }
set vTcl(m,grid,-ipady)            { {int. y pad}    {}       type    {} }
set vTcl(m,grid,-padx)             { {ext. x pad}    {}       type    {} }
set vTcl(m,grid,-pady)             { {ext. y pad}    {}       type    {} }
set vTcl(m,grid,-in)               { inside          {}       type    {} }

set vTcl(m,grid,extlist) "row,weight column,weight row,minsize column,minsize"
set vTcl(m,grid,column,weight)     { {col weight}    {}       type    {} {vTcl:grid:conf_ext} }
set vTcl(m,grid,column,minsize)    { {col minsize}   {}       type    {} {vTcl:grid:conf_ext} }
set vTcl(m,grid,row,weight)        { {row weight}    {}       type    {} {vTcl:grid:conf_ext} }
set vTcl(m,grid,row,minsize)       { {row minsize}   {}       type    {} {vTcl:grid:conf_ext} }

set vTcl(m,wm,list) ""
set vTcl(m,wm,extlist) "geometry,x geometry,y geometry,w geometry,h resizable,w resizable,h
                        minsize,x minsize,y maxsize,x maxsize,y state title"
set vTcl(m,wm,geometry,x)          { {x position}    {}       type    {} {vTcl:wm:conf_geom} }
set vTcl(m,wm,geometry,y)          { {y position}    {}       type    {} {vTcl:wm:conf_geom} }
set vTcl(m,wm,geometry,w)          { width           {}       type    {} {vTcl:wm:conf_geom} }
set vTcl(m,wm,geometry,h)          { height          {}       type    {} {vTcl:wm:conf_geom} }
set vTcl(m,wm,resizable,w)         { {resize width}  {}       boolean {0 1} {vTcl:wm:conf_resize} }
set vTcl(m,wm,resizable,h)         { {resize height} {}       boolean {0 1} {vTcl:wm:conf_resize} }
set vTcl(m,wm,minsize,x)           { {x minsize}     {}       type    {} {vTcl:wm:conf_minmax} }
set vTcl(m,wm,minsize,y)           { {y minsize}     {}       type    {} {vTcl:wm:conf_minmax} }
set vTcl(m,wm,maxsize,x)           { {x maxsize}     {}       type    {} {vTcl:wm:conf_minmax} }
set vTcl(m,wm,maxsize,y)           { {y maxsize}     {}       type    {} {vTcl:wm:conf_minmax} }
set vTcl(m,wm,state)               { state           {}       choice  {iconify deiconify withdraw} {vTcl:wm:conf_state} }
set vTcl(m,wm,title)               { title           {}       type    {} {vTcl:wm:conf_title} }

set vTcl(m,menubar,list) ""
set vTcl(m,menubar,extlist) ""

#
# Widget Attributes
#
set vTcl(opt,list) "
    -background
    -foreground
    -activebackground
    -activeforeground
    -highlightbackground
    -highlightcolor
    -selectcolor
    -selectbackground
    -selectforeground
    -disabledforeground
    -insertbackground
    -troughcolor

    -activerelief
    -relief
    -sliderrelief

    -bordermode
    -borderwidth
    -elementborderwidth
    -insertborderwidth
    -selectborderwidth
    -highlightthickness
    -padx
    -pady

    -height
    -width
    -orient
    -insertwidth

    -bitmap
    -cursor
    -image
    -selectimage

    -command
    -xscrollcommand
    -yscrollcommand

    -text
    -textvariable
    -font
    -justify
    -wrap
    -wraplength
    -spacing1
    -spacing2
    -spacing3
    -closeenough
    -underline
    -aspect
    -anchor
    -tabs
    -insertofftime
    -insertontime

    -exportselection
    -indicatoron
    -label
    -repeatdelay
    -repeatinterval
    -tickinterval
    -jump
    -showvalue
    -resolution
    -from
    -to

    -confine
    -menu
    -selectmode
    -setgrid

    -variable
    -offvalue
    -onvalue
    -value

    -screen
    -show
    -state
    -takefocus

    -sliderlength
    -scrollregion
    -xscrollincrement
    -yscrollincrement
"

set vTcl(opt,-activebackground)    { {active bg}     Colors   color   {} }
set vTcl(opt,-activeforeground)    { {active fg}     Colors   color   {} }
set vTcl(opt,-activerelief)        { {active relief} {}       choice  {flat groove raised ridge sunken} }
set vTcl(opt,-anchor)              { anchor          {}       choice  {n ne e se s sw w nw center} }
set vTcl(opt,-aspect)              { aspect          {}       type    {} }
set vTcl(opt,-bd)                  { {borderwidth}   {}       type    {} }
set vTcl(opt,-borderwidth)         { {borderwidth}   {}       type    {} }
set vTcl(opt,-bg)                  { background      {}       color   {} }
set vTcl(opt,-background)          { background      {}       color   {} }
set vTcl(opt,-bitmap)              { bitmap          {}       type    {} }
set vTcl(opt,-bordermode)          { {border mode}   {}       choice  {inside ignore outside} }
set vTcl(opt,-closeenough)         { closeness       {}       type    {} }
set vTcl(opt,-command)             { command         {}       command {} }
set vTcl(opt,-confine)             { confine         {}       boolean {0 1} }
set vTcl(opt,-cursor)              { cursor          {}       type    {} }
set vTcl(opt,-disabledforeground)  { {disabled fg}   Colors   color   {} }
set vTcl(opt,-elementborderwidth)  { {element bd}    {}       type    {} }
set vTcl(opt,-exportselection)     { export          {}       boolean {0 1} }
set vTcl(opt,-fg)                  { foreground      Colors   color   {} }
set vTcl(opt,-foreground)          { foreground      Colors   color   {} }
set vTcl(opt,-font)                { font            {}       type    {} }
set vTcl(opt,-height)              { height          {}       type    {} }
set vTcl(opt,-highlightbackground) { {hilight bg}    Colors   color   {} }
set vTcl(opt,-highlightcolor)      { {hilight color} Colors   color   {} }
set vTcl(opt,-highlightthickness)  { {hilight bd}    {}       type    {} }
set vTcl(opt,-image)               { image           {}       type    {} }
set vTcl(opt,-indicatoron)         { indicator       {}       boolean {0 1} }
set vTcl(opt,-insertbackground)    { {insert bg}     Colors   color   {} }
set vTcl(opt,-insertborderwidth)   { {insert bd}     {}       type    {} }
set vTcl(opt,-insertofftime)       { {insert off time} {}     type    {} }
set vTcl(opt,-insertontime)        { {insert on time} {}      type    {} }
set vTcl(opt,-insertwidth)         { {insert wd}     {}       type    {} }
set vTcl(opt,-jump)                { jump            {}       boolean {0 1} }
set vTcl(opt,-justify)             { justify         {}       choice  {left right center} }
set vTcl(opt,-menu)                { menu            {}       menu    {} }
set vTcl(opt,-offvalue)            { {off value}     {}       type    {} }
set vTcl(opt,-onvalue)             { {on value}      {}       type    {} }
set vTcl(opt,-orient)              { orient          {}       choice  {vertical horizontal} }
set vTcl(opt,-padx)                { {x pad}         {}       type    {} }
set vTcl(opt,-pady)                { {y pad}         {}       type    {} }
set vTcl(opt,-relief)              { relief          {}       choice  {flat groove raised ridge sunken} }
set vTcl(opt,-repeatdelay)         { {repeat delay}  {}       type    {} }
set vTcl(opt,-repeatinterval)      { {repeat intrvl} {}       type    {} }
set vTcl(opt,-screen)              { screen          {}       type    {} }
set vTcl(opt,-scrollregion)        { {scroll region} {}       type    {} }
set vTcl(opt,-selectbackground)    { {select bg}     Colors   color   {} }
set vTcl(opt,-selectborderwidth)   { {select bd}     {}       type    {} }
set vTcl(opt,-selectcolor)         { {select color}  Colors   color   {} }
set vTcl(opt,-selectforeground)    { {select fg}     Colors   color   {} }
set vTcl(opt,-selectimage)         { {select image}  {}       type    {} }
set vTcl(opt,-selectmode)          { {select mode}   {}       type    {} }
set vTcl(opt,-setgrid)             { {set grid}      {}       boolean {0 1} }
set vTcl(opt,-show)                { show            {}       type    {} }
set vTcl(opt,-showvalue)           { {show value}    {}       boolean {0 1} }
set vTcl(opt,-sliderlength)        { {slider length} {}       type    {} }
set vTcl(opt,-sliderrelief)        { {slider relief} {}       choice  {flat groove raised ridge sunken} }
set vTcl(opt,-spacing1)            { spacing1        {}       type    {} }
set vTcl(opt,-spacing2)            { spacing2        {}       type    {} }
set vTcl(opt,-spacing3)            { spacing3        {}       type    {} }
set vTcl(opt,-state)               { state           {}       choice  {normal active disabled} }
set vTcl(opt,-tabs)                { tabs            {}       type    {} }
set vTcl(opt,-takefocus)           { {take focus}    {}       type    {} }
set vTcl(opt,-text)                { text            {}       type    {} }
set vTcl(opt,-textvariable)        { {text var}      {}       type    {} }
set vTcl(opt,-tickinterval)        { {tic interval}  {}       type    {} }
set vTcl(opt,-from)                { {from value}    {}       type    {} }
set vTcl(opt,-to)                  { {to value}      {}       type    {} }
set vTcl(opt,-label)               { label           {}       type    {} }
set vTcl(opt,-resolution)          { resolution      {}       type    {} }
set vTcl(opt,-troughcolor)         { {trough color}  Colors   color   {} }
set vTcl(opt,-underline)           { underline       {}       type    {} }
set vTcl(opt,-value)               { value           {}       type    {} }
set vTcl(opt,-variable)            { variable        {}       type    {} }
set vTcl(opt,-width)               { width           {}       type    {} }
set vTcl(opt,-wrap)                { wrap            {}       choice  {char none word} }
set vTcl(opt,-wraplength)          { {wrap length}   {}       type    {} }
set vTcl(opt,-xscrollincrement)    { {x increment}   {}       type    {} }
set vTcl(opt,-yscrollincrement)    { {y increment}   {}       type    {} }
set vTcl(opt,-xscrollcommand)      { {x scroll cmd}  {}       command {} }
set vTcl(opt,-yscrollcommand)      { {y scroll cmd}  {}       command {} }

set vTcl(head,proj) [string trim {
#############################################################################
# Visual Tcl v$vTcl(version) Project
#
}]

set vTcl(head,vars) [string trim {
#################################
# GLOBAL VARIABLES
#
}]

set vTcl(head,procs) [string trim {
#################################
# USER DEFINED PROCEDURES
#
}]

set vTcl(head,gui) [string trim {
#################################
# VTCL GENERATED GUI PROCEDURES
#
}]

set vTcl(head,proc,widgets) "$vTcl(tab)###################
$vTcl(tab)# CREATING WIDGETS
$vTcl(tab)###################
"

set vTcl(head,proc,geometry) "$vTcl(tab)###################
$vTcl(tab)# SETTING GEOMETRY
$vTcl(tab)###################
"


