import std/[tables,dirs, paths, strutils, sequtils]

import jsony

import data
# base wish list


proc write_tree*(directory: string = "."): Table[string, seq[string]]=
    #TODO check if objectMap dumpfile exists -> use that else create initial objectMap
    var objectMap: Table[system.string, seq[string]] = initTable[string, seq[string]]()
    var changes: Table[system.string, seq[string]] = initTable[string, seq[string]]()
    for files in walkDirRec(Path(directory)):
        #split out the directory for easier ignore
        let splitUpDir = string(files).split("/")
        let sFiles = $files #only do the string conversion once
        if splitUpDir.contains(".git") or splitUpDir.contains(".Forrest"): #skip git directories by default
            continue
        let oid = data.hash_object(string(files))
        if not objectMap.hasKey(sFiles):
            objectMap[sFiles] = @[oid]
            changes[sFiles] = @[oid]
        elif objectMap.hasKey(sFiles) and objectMap[sFiles].contains(oid):
            continue
        else:
            objectMap[sFiles].add(oid)
            changes[sFiles].add(oid)

    #TODO jsony and dump objectMap to .Forrest/serialized
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