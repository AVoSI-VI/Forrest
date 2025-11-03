import std/[tables,dirs, paths, strutils, sequtils, os]

import jsony

import data
# base wish list


proc write_tree*(directory: string = "."): Table[string, seq[string]]=
    #TODO: revisit
    var objectMap: Table[system.string, seq[string]] = (
        if fileExists("./.Forrest/serialized/Forrest.json"):
            var contentsOfForrestJson = readFile("./.Forrest/serialized/Forrest.json")
            contentsOfForrestJson.fromJson(Table[string, seq[string]])
        else:
            initTable[string, seq[string]]()
    )
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
    try:
        let f = open("./.Forrest/serialized/Forrest.json", fmWrite)
        defer: f.close
        f.writeLine(objectMap.toJson())
    except Exception as e:
        echo "unable to write serialized Forrest.json file"
        echo ""
        echo e.msg
    return changes

proc empty_current_directory()=
    let directory = "."
    for files in walkDirRec(Path(directory)):
        let splitUpDir = string(files).split("/")
        let sFiles = $files
        if splitUpDir.contains(".git") or splitUpDir.contains(".Forrest"): #skip git directories by default
            continue
        try:
            removeFile(sfiles)
        except Exception as e:
            echo "unable to clear current directory"
            echo ""
            echo e.msg

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