
proc vTcl:lib_table:init {} {

    global vTcl

    if {[catch {package require Tktable} erg]} {

        lappend vTcl(libNames) {(not detected) tkTable Widgets Support Library}
        return 0
    }

    lappend vTcl(libNames) {tkTable Widgets Support Library}
    return 1
}

proc vTcl:widget:lib:lib_table {args} {
    global vTcl

    set order { Table }

    vTcl:lib:add_widgets_to_toolbar $order

    append vTcl(head,importheader) {
        # Provoke name search
        catch {package require foobar}
        set names [package names]

        # Check if Tktable is available
        if { [lsearch -exact $names Tktable] != -1} {
            package require Tktable
        }
    }
}
