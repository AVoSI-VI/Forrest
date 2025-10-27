import std/tables

import jsony
# base wish list

proc write_tree*(directory: string = "."): Table[string, string]=
    
    var changes = initTable[string, string]()
    return changes

proc empty_current_directory()=
    discard

proc read_tree()=
    discard

proc write_clone_file()=
    discard

proc roll_back_file()=
    discard

proc show_oid_history()=
    discard

proc commit(message: string)=
    discard

proc checkout()=
    discard

proc get_commit()=
    discard

proc is_ignored()=
    discard