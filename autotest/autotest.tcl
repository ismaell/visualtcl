set _test 0

proc vTcl:test_start {} {
    after 2000 {set _test [expr 1 - $_test] }
    global _test
    vwait _test
}

proc vTcl:test_case {name _do action _expect expect} {

    vTcl:test_start
    set outID [open autotest/result.txt a]
    puts $outID "=================================================="
    if {[catch {uplevel #0 [list interp eval "" $action]} error]} then {
        global errorInfo
        puts $outID "$name:"
        puts $outID "     => Exception:"
        puts $outID "$errorInfo"
        close $outID
        return
    }

    set pass [uplevel #0 [list interp eval "" $expect]]

    if {$pass} then {
        puts $outID "$name:"
        puts $outID "    Succeed."
    } else {
        puts $outID "$name:"
        puts $outID "     => Failed !!!"
    }

    close $outID
}
