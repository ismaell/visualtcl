#############################################################################
# Visual Tcl v1.51 Project
#

source autotest/autotest.tcl

vTcl:tests {

# special initialization because we were sourced
set vTcl(tops) ""
set argc 0
set argv ""

vTcl:test_case "Application Startup" \
	do { } \
	expect {winfo exist .vTcl}
vTcl:test_case "Application Windows: Toolbar" \
	do {} \
	expect {winfo exist .vTcl.toolbar}
vTcl:test_case "Application Windows: Property Editor" \
	do {} \
	expect {winfo exist .vTcl.ae}
vTcl:test_case "Application Windows: Windows List" \
        do {vTcl:toplist:show 1} \
        expect {winfo exist .vTcl.toplist}
vTcl:test_case "Application Windows: Command Console" \
        do {vTcl:show_console} \
        expect {winfo exist .vTcl.tkcon}
vTcl:test_case "Application Windows: About Box" \
        do {vTclWindow.vTcl.about} \
        expect {winfo exist .vTcl.about}
vTcl:test_case "Application Windows: Closing About Box" \
        do {
                .vTcl.about.fra30.but31 invoke
                vTcl:test_trace ".vTcl.about => [wm state .vTcl.about]"
        } \
        expect {expr {[wm state .vTcl.about] == "withdrawn"}}
vTcl:test_case "New project" \
        do {
                vTcl:test_trace "vTcl(tops)=$vTcl(tops)"
	        vTcl:new
                vTcl:test_trace "vTcl(tops)=$vTcl(tops)"
        } \
	expect {set newtop [lindex $vTcl(tops) 0]
              string match .top* $newtop}
vTcl:save_prefs
vTcl:exit
}