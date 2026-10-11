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

proc return_branches_as_table*(): Table[string, string]=
    if fileExists("./.Forrest/branches/branches.json"):
        let contents = readFile("./.Forrest/branches/branches.json")
        if contents.len == 0:
            return initTable[string, string]()
        return contents.fromJson(Table[string, string])
    return initTable[string, string]()

proc serialize_and_write_branch*(branchMap: Table[string, string])=
    try:
        let f = open("./.Forrest/branches/branches.json", fmWrite)
        defer: f.close
        f.writeLine(branchMap.toJson())
    except Exception as e:
        echo "unable to write serialized branches.json file"
        echo ""
        echo e.msg

proc read_head*(): string=
    if fileExists("./.Forrest/HEAD"):
        let name = readFile("./.Forrest/HEAD").strip()
        if name.len > 0:
            return name
    return "main"

proc write_head*(name: string)=
    writeFile("./.Forrest/HEAD", name & "\n")

proc ensure_head_and_main*()=
    if not fileExists("./.Forrest/HEAD"):
        write_head("main")
    if not fileExists("./.Forrest/branches/branches.json"):
        var branches = initTable[string, string]()
        branches["main"] = ""
        serialize_and_write_branch(branches)

proc current_commit_oid*(): string=
    let branches = return_branches_as_table()
    let name = read_head()
    if branches.hasKey(name):
        return branches[name]
    return ""

proc point_branch*(name, oid: string)=
    var branches = return_branches_as_table()
    branches[name] = oid
    serialize_and_write_branch(branches)

proc read_merge_head*(): string=
    if fileExists("./.Forrest/MERGE_HEAD"):
        return readFile("./.Forrest/MERGE_HEAD").strip()
    return ""

proc write_merge_head*(oid: string)=
    writeFile("./.Forrest/MERGE_HEAD", oid & "\n")

proc read_merge_conflicts*(): seq[string]=
    if fileExists("./.Forrest/MERGE_CONFLICTS"):
        let contents = readFile("./.Forrest/MERGE_CONFLICTS")
        if contents.len == 0:
            return @[]
        return contents.fromJson(seq[string])
    return @[]

proc write_merge_conflicts*(paths: seq[string])=
    writeFile("./.Forrest/MERGE_CONFLICTS", paths.toJson() & "\n")

proc clear_merge_state*()=
    if fileExists("./.Forrest/MERGE_HEAD"):
        removeFile("./.Forrest/MERGE_HEAD")
    if fileExists("./.Forrest/MERGE_CONFLICTS"):
        removeFile("./.Forrest/MERGE_CONFLICTS")