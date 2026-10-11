import std/[tables, dirs, paths, strutils, os]

# import jsony

import data
import ../lib/[serializeinteractions, clearing]

proc write_worktree_file*(path, contents: string)=
    let parent = parentDir(path)
    if parent.len > 0 and parent != "." and parent != "./":
        os.createDir(parent)
    writeFile(path, contents)

proc write_tree*(directory: string = "."): tuple[objectMap: Table[string, seq[string]], changes: Table[string, seq[string]]]=
    #TODO: revisit
    # var objectMap: Table[system.string, seq[string]] = (
    #     if fileExists("./.Forrest/serialized/Forrest.json"):
    #         var contentsOfForrestJson = readFile("./.Forrest/serialized/Forrest.json")
    #         contentsOfForrestJson.fromJson(Table[string, seq[string]])
    #     else:
    #         initTable[string, seq[string]]()
    # )
    var objectMap: Table[system.string, seq[string]] = return_forrest_as_table()
    var changes: Table[system.string, seq[string]] = initTable[string, seq[string]]()
    for files in walkDirRec(Path(directory)):
        #split out the directory for easier ignore
        let sFiles = $files #only do the string conversion once
        if is_clearing_ignored(sFiles, false):
            continue
        let oid = data.hash_object(sFiles)
        if not objectMap.hasKey(sFiles):
            objectMap[sFiles] = @[oid]
            changes[sFiles] = @[oid]
        elif objectMap.hasKey(sFiles) and objectMap[sFiles].contains(oid):
            continue
        else:
            objectMap[sFiles].add(oid)
            if not changes.hasKey(sFiles):
                changes[sFiles] = @[]
            changes[sFiles].add(oid)
    # try:
    #     let f = open("./.Forrest/serialized/Forrest.json", fmWrite)
    #     defer: f.close
    #     f.writeLine(objectMap.toJson())
    # except Exception as e:
    #     echo "unable to write serialized Forrest.json file"
    #     echo ""
    #     echo e.msg
    serialize_and_write_forrest(objectMap)
    return (objectMap: objectMap, changes: changes)

proc empty_current_directory*()=
    #TODO: revisit. Was easiest way to clear non git directories as nims walk dir procs and remove dir procs 
    # don't work the same as python. would need a custom implementation to keep it in line with python
    let directory = "."
    #seq to hold all top level directories that don't contain git repos
    var nonGitDirs: seq[string] = @[]
    for files in walkDirRec(Path(directory)):
        let splitUpDir = string(files).split("/")
        let sFiles = $files
        if is_clearing_ignored(sFiles, false):
            continue
        nonGitDirs.add(splitUpDir[1]) # add actual directory from split ex: [".", ".Forrest"]
        try:
            removeFile(sfiles)
        except Exception as e:
            echo "unable to clear current directory"
            echo ""
            echo e.msg
    #remove now empty directories, leaving any directory that still holds an ignored file
    for nonGitDirectory in nonGitDirs:
        var stillHasFiles = false
        try:
            for _ in walkDirRec(Path(nonGitDirectory)):
                stillHasFiles = true
                break
        except CatchableError:
            stillHasFiles = false
        if not stillHasFiles:
            try:
                osdirs.removeDir(nonGitDirectory)
            except CatchableError:
                discard

proc read_tree*()= 
    # if fileExists("./.Forrest/serialized/Forrest.json"):
        # var contentsOfForrestJson = readFile("./.Forrest/serialized/Forrest.json")
        # let objectMap: Table[string, seq[string]] = contentsOfForrestJson.fromJson(Table[string, seq[string]])
    let objectMap: Table[system.string, seq[string]] = return_forrest_as_table()
    let deleted = return_deleted()
    if not objectMap.len() == 0:
        empty_current_directory()
        for k in objectMap.keys():
            if k in deleted:
                continue
            let l = len(objectMap[k]) - 1
            write_worktree_file(k, data.get_object(objectMap[k][l]))

# proc read_tree_commit(commitContent: Table[string, seq[string]])=
#     empty_current_directory()
#     for k in commitContent.keys():
#         let l = len(commitContent[k]) - 1
#         writeFile(k, data.get_object(commitContent[k][l]))

proc write_clone_file*(fileAndPathToClone: string)=
    # if fileExists("./.Forrest/serialized/Forrest.json"):
    #     var contentsOfForrestJson = readFile("./.Forrest/serialized/Forrest.json")
    #     let objectMap: Table[string, seq[string]] = contentsOfForrestJson.fromJson(Table[string, seq[string]])
    let objectMap: Table[system.string, seq[string]] = return_forrest_as_table()
    let deleted = return_deleted()
    let key = resolve_repo_path(objectMap, fileAndPathToClone)
    if key in deleted:
        return
    if objectMap.hasKey(key):
        let l = len(objectMap[key]) - 1
        write_worktree_file(key, data.get_object(objectMap[key][l]))
        
proc roll_back_file*(fileAndPath: string, oid: string)=
    # if fileExists("./.Forrest/serialized/Forrest.json"):
    #     var contentsOfForrestJson = readFile("./.Forrest/serialized/Forrest.json")
    #     let objectMap: Table[string, seq[string]] = contentsOfForrestJson.fromJson(Table[string, seq[string]])
    let objectMap: Table[system.string, seq[string]] = return_forrest_as_table()
    let key = resolve_repo_path(objectMap, fileAndPath)
    if objectMap.hasKey(key):
        let oidIndex = find(objectMap[key], oid)
        if oidIndex != -1:#find returns a -1 if the search item is not found    
            write_worktree_file(key, data.get_object(objectMap[key][oidIndex]))

proc show_oid_history*(fileAndPath: string)=
    # if fileExists("./.Forrest/serialized/Forrest.json"):
    #     var contentsOfForrestJson = readFile("./.Forrest/serialized/Forrest.json")
    #     let objectMap: Table[string, seq[string]] = contentsOfForrestJson.fromJson(Table[string, seq[string]])
    let objectMap: Table[system.string, seq[string]] = return_forrest_as_table()
    let key = resolve_repo_path(objectMap, fileAndPath)
    if objectMap.hasKey(key):
        echo objectMap[key]
    else:
        echo "file and path does not exist in repo"
    # else:
    #     echo "Forrest.json does not exist"

# proc commit*(message: string): string=
#     # let changes = write_tree()
#     # var c: seq[string] = @[]
#     # for k in changes.keys():
#     #     c.add(fmt"{k}: {changes[k]}")
#     # let commitContent = fmt"Changes: {c}" & "\n" & "\n" & fmt"{message}" & "\n"
    
#     #change to make it easier to manipulate and keep track of commits as a whole
#     let objectMapAtTimeOfCommit: tuple[objectMap: Table[string, seq[string]], changes: Table[string, seq[string]]] = write_tree()#.objectMap
#     let commitContent: tuple[commitMessage: string, commitContent: Table[string, seq[string]], changes: Table[string, seq[string]]] = (commitMessage: message, commitContent: objectMapAtTimeOfCommit.objectMap, changes: objectMapAtTimeOfCommit.changes)

#     return data.write_commit_objects(commitContent.toJson())

# proc get_commit*(oid: string): tuple[commitMessage: string, commitContent: Table[string, seq[string]], changes: Table[string, seq[string]]]=
#     return data.get_commit_objects(oid).fromJson(tuple[commitMessage: string, commitContent: Table[string, seq[string]], changes: Table[string, seq[string]]])

# proc checkout_commit*(oid: string)=
#     let objectMapAtTimeOfCommit = get_commit(oid)
#     read_tree_commit(objectMapAtTimeOfCommit.commitContent)
