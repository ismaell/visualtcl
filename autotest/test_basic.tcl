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
        do {Window show .vTcl.about} \
        expect {winfo exist .vTcl.about}
vTcl:test_case "Application Windows: Closing About Box" \
        do {
                .vTcl.about.fra30.but31 invoke
                vTcl:test_trace ".vTcl.about => [wm state .vTcl.about]"
        } \
        expect {expr {[wm state .vTcl.about] == "withdrawn"}}
vTcl:test_case "Application Windows: Libraries" \
        do {Window show .vTcl.infolibs} \
        expect {winfo exist .vTcl.infolibs}
vTcl:test_case "Application Windows: Closing Libraries Window" \
        do {
                .vTcl.infolibs.but40 invoke
                vTcl:test_trace ".vTcl.infolibs => [wm state .vTcl.infolibs]"
        } \
        expect {expr {[wm state .vTcl.infolibs] == "withdrawn"}}
vTcl:test_case "Application Windows: Preferences" \
        do {Window show .vTcl.prefs} \
        expect {winfo exist .vTcl.prefs}
vTcl:test_case "Preferences: Basics tab" \
        do {vTcl:tabnotebook_display .vTcl.prefs.tb "Basics"} \
        expect {set toto 1}
vTcl:test_case "Preferences: Project tab" \
        do {vTcl:tabnotebook_display .vTcl.prefs.tb "Project"} \
        expect {set toto 1}
vTcl:test_case "Preferences: Fonts tab" \
        do {vTcl:tabnotebook_display .vTcl.prefs.tb "Fonts"} \
        expect {set toto 1}
vTcl:test_case "Preferences: Colors tab" \
        do {vTcl:tabnotebook_display .vTcl.prefs.tb "Colors"} \
        expect {set toto 1}
vTcl:test_case "Preferences: Images tab" \
        do {vTcl:tabnotebook_display .vTcl.prefs.tb "Images"} \
        expect {set toto 1}
vTcl:test_case "Preferences: closing preferences" \
        do {.vTcl.prefs.fra19.but21 invoke} \
        expect {expr {[wm state .vTcl.prefs] == "withdrawn"}}
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