import std/[tables, os, strutils]

import jsony

import ../TYPEDEFS/indexObj

proc return_forrest_as_table*(): Table[string, seq[string]]=
    var objectMap: Table[system.string, seq[string]] = (
        if fileExists("./.Forrest/serialized/Forrest.json"):
            var contentsOfForrestJson = readFile("./.Forrest/serialized/Forrest.json")
            contentsOfForrestJson.fromJson(Table[string, seq[string]])
        else:
            initTable[string, seq[string]]()
    )

    return objectMap

proc return_remotes_as_table*(): Table[string, string]=
    var remoteMap: Table[string, string] = (
        if fileExists("./.Forrest/serialized/remotes.json"):
            var contentsOfForrestJson = readFile("./.Forrest/serialized/remotes.json")
            contentsOfForrestJson.fromJson(Table[string, string])
        else:
            initTable[string, string]()
    )
    return remoteMap

proc serialize_and_write_forrest*(objectMap: Table[string, seq[string]])=
    try:
        let f = open("./.Forrest/serialized/Forrest.json", fmWrite)
        defer: f.close
        f.writeLine(objectMap.toJson())
    except Exception as e:
        echo "unable to write serialized Forrest.json file"
        echo ""
        echo e.msg

proc serialize_and_write_remote*(remoteMap: Table[string, string])=
    try:
        let f = open("./.Forrest/serialized/remotes.json", fmWrite)
        defer: f.close
        f.writeLine(remoteMap.toJson())
    except Exception as e:
        echo "unable to write serialized remotes.json file"
        echo ""
        echo e.msg

proc return_index_as_table*(): Table[string, IndexEntry]=
    if fileExists("./.Forrest/serialized/index.json"):
        let contentsOfIndex = readFile("./.Forrest/serialized/index.json")
        if contentsOfIndex.len == 0:
            return initTable[string, IndexEntry]()
        return contentsOfIndex.fromJson(Table[string, IndexEntry])
    return initTable[string, IndexEntry]()

proc return_deleted*(): seq[string]=
    if fileExists("./.Forrest/serialized/deleted.json"):
        let contentsOfDeleted = readFile("./.Forrest/serialized/deleted.json")
        if contentsOfDeleted.len == 0:
            return @[]
        return contentsOfDeleted.fromJson(seq[string])
    return @[]

proc serialize_and_write_index*(index: Table[string, IndexEntry])=
    try:
        let f = open("./.Forrest/serialized/index.json", fmWrite)
        defer: f.close
        f.writeLine(index.toJson())
    except Exception as e:
        echo "unable to write serialized index.json file"
        echo ""
        echo e.msg

proc serialize_and_write_deleted*(deleted: seq[string])=
    try:
        let f = open("./.Forrest/serialized/deleted.json", fmWrite)
        defer: f.close
        f.writeLine(deleted.toJson())
    except Exception as e:
        echo "unable to write serialized deleted.json file"
        echo ""
        echo e.msg

proc ensure_staging_files*()=
    if not fileExists("./.Forrest/serialized/index.json"):
        serialize_and_write_index(initTable[string, IndexEntry]())
    if not fileExists("./.Forrest/serialized/deleted.json"):
        serialize_and_write_deleted(@[])

proc normalize_repo_path*(path: string): string=
    ## matches walkDirRec(".") keys, which look like ./relative/path
    if path.len == 0:
        return ""
    var p = path
    if os.isAbsolute(p):
        p = os.relativePath(p, os.getCurrentDir())
    p = os.normalizedPath(p)
    if p == ".":
        return "."
    if p.startsWith("./"):
        p = p[2 .. ^1]
    if p == ".." or p.startsWith("../"):
        return p
    return "./" & p

proc path_is_under*(dir, path: string): bool=
    if dir == ".":
        return true
    return path.startsWith(dir & "/")

proc resolve_repo_path*(objectMap: Table[string, seq[string]], raw: string): string=
    let norm = normalize_repo_path(raw)
    if objectMap.hasKey(norm):
        return norm
    if objectMap.hasKey(raw):
        return raw
    return norm

proc serialize_and_write_branch*(branchMap: Table[string, string])=
    try:
        let f = open("./.Forrest/branches/branches.json", fmWrite)
        defer: f.close
        f.writeLine(branchMap.toJson())
    except Exception as e:
        echo "unable to write serialized branches.json file"
        echo ""
        echo e.msg