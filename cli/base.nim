import std/[tables,dirs, paths, strutils, sequtils]

import jsony

import data
# base wish list


proc write_tree*(directory: string = "."): Table[string, string]=
    var changes = initTable[string, string]()
    for files in walkDirRec(Path(directory)):
        #split out the directory for easier ignore
        let splitUpDir = string(files).split("/")
        if splitUpDir.contains(".git") or splitUpDir.contains(".Forrest"): #skip git directories by default
            continue
        let oid = data.hash_object(string(files))
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