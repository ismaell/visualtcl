#############################################################################
# Visual Tcl v1.51 Project
#

source autotest/autotest.tcl

after 2000 {

vTcl:test_case "Application Startup" \
	do { } \
	expect {winfo exist .vTcl}
vTcl:test_case "Application Windows: Toolbar" \
	do {} \
	expect {winfo exist .vTcl.toolbar}
vTcl:test_case "Application Windows: Property Editor" \
	do {} \
	expect {winfo exist .vTcl.ae}
vTcl:test_case "New project" \
	do vTcl:new \
	expect {set newtop [lindex $vTcl(tops) 0]
              string match .top* $newtop}
vTcl:exit
}