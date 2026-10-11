import std/[algorithm, dirs, os, paths, strutils, tables]

import jsony

import data
import ../lib/[filehasher, serializeinteractions]
import ../TYPEDEFS/[indexObj, commitObj]

proc is_outside_repo(path: string): bool=
    return path == ".." or path.startsWith("../")

proc is_ignored_path(path: string): bool=
    let parts = path.split("/")
    return parts.contains(".git") or parts.contains(".Forrest")

proc require_repo(): bool=
    if not data.repo_exists():
        echo "not a Forrest repository"
        return false
    return true

proc stage_add(index: var Table[string, IndexEntry], path: string)=
    let oid = data.hash_object(path)
    index[path] = IndexEntry(action: actionAdd, oid: oid)

proc stage_delete(index: var Table[string, IndexEntry], path: string)=
    index[path] = IndexEntry(action: actionDelete, oid: "")

proc stage_missing_tracked(index: var Table[string, IndexEntry], objectMap: Table[string, seq[string]], deleted: seq[string], dir: string)=
    for path in objectMap.keys():
        if path in deleted:
            continue
        if not path_is_under(dir, path):
            continue
        if fileExists(path):
            continue
        stage_delete(index, path)

proc stage_directory(index: var Table[string, IndexEntry], objectMap: Table[string, seq[string]], deleted: seq[string], dir: string)=
    let root = if dir == ".": "." else: dir
    for files in walkDirRec(Path(root)):
        let path = normalize_repo_path($files)
        if path.len == 0 or is_outside_repo(path) or is_ignored_path(path):
            continue
        stage_add(index, path)
    stage_missing_tracked(index, objectMap, deleted, dir)

proc add_one(index: var Table[string, IndexEntry], objectMap: Table[string, seq[string]], deleted: seq[string], raw: string)=
    let path = normalize_repo_path(raw)
    if path.len == 0 or is_outside_repo(path):
        echo "path is outside the repository: " & raw
        return
    if is_ignored_path(path):
        echo "path is ignored: " & path
        return
    if path == "." or dirExists(path):
        stage_directory(index, objectMap, deleted, path)
        return
    if fileExists(path):
        stage_add(index, path)
        return
    if objectMap.hasKey(path) and path notin deleted:
        stage_delete(index, path)
        return
    let before = index.len
    stage_missing_tracked(index, objectMap, deleted, path)
    if index.len == before:
        echo "path does not match a file: " & path

proc add_paths*(paths: seq[string])=
    ## stages files or directories for the next commit
    ##
    ## a missing tracked file is staged for deletion
    if not require_repo():
        return
    if paths.len == 0:
        echo "requires a path"
        return
    var index = return_index_as_table()
    let objectMap = return_forrest_as_table()
    let deleted = return_deleted()
    for raw in paths:
        add_one(index, objectMap, deleted, raw)
    serialize_and_write_index(index)

proc unstage_paths*(paths: seq[string])=
    ## removes paths from the index
    ##
    ## "." clears the index
    if not require_repo():
        return
    if paths.len == 0:
        echo "requires a path"
        return
    var index = return_index_as_table()
    for raw in paths:
        let path = normalize_repo_path(raw)
        if path.len == 0 or is_outside_repo(path):
            echo "path is outside the repository: " & raw
            continue
        if path == ".":
            index.clear()
            serialize_and_write_index(index)
            return
        if index.hasKey(path):
            index.del(path)
            continue
        var matched: seq[string] = @[]
        for key in index.keys():
            if path_is_under(path, key):
                matched.add(key)
        if matched.len == 0:
            echo "path is not staged: " & path
            continue
        for key in matched:
            index.del(key)
    serialize_and_write_index(index)

proc latest_oid(history: seq[string]): string=
    if history.len == 0:
        return ""
    return history[^1]

proc echo_kind(kind: string, paths: seq[string])=
    var ordered = paths
    ordered.sort()
    for path in ordered:
        echo "  " & kind & ": " & path

proc echo_plain(paths: seq[string])=
    var ordered = paths
    ordered.sort()
    for path in ordered:
        echo "  " & path

proc show_status*()=
    ## shows staged, unstaged, and untracked paths
    if not require_repo():
        return
    let index = return_index_as_table()
    let objectMap = return_forrest_as_table()
    let deleted = return_deleted()

    var stagedNew: seq[string] = @[]
    var stagedModified: seq[string] = @[]
    var stagedDeleted: seq[string] = @[]
    for path, entry in index.pairs:
        if entry.action == actionDelete:
            stagedDeleted.add(path)
        elif (not objectMap.hasKey(path)) or (path in deleted):
            stagedNew.add(path)
        elif latest_oid(objectMap[path]) != entry.oid:
            stagedModified.add(path)

    var unstagedModified: seq[string] = @[]
    var untracked: seq[string] = @[]
    for files in walkDirRec(Path(".")):
        let path = normalize_repo_path($files)
        if path.len == 0 or is_outside_repo(path) or is_ignored_path(path):
            continue
        let workOid = hash_file_contents_for_OID(path)
        if index.hasKey(path):
            let entry = index[path]
            if entry.action == actionDelete or entry.oid != workOid:
                unstagedModified.add(path)
        elif objectMap.hasKey(path) and path notin deleted:
            if latest_oid(objectMap[path]) != workOid:
                unstagedModified.add(path)
        else:
            untracked.add(path)

    var unstagedDeleted: seq[string] = @[]
    for path in objectMap.keys():
        if path in deleted or fileExists(path):
            continue
        if index.hasKey(path) and index[path].action == actionDelete:
            continue
        unstagedDeleted.add(path)
    for path, entry in index.pairs:
        if entry.action == actionAdd and (not fileExists(path)) and (path notin objectMap):
            unstagedDeleted.add(path)

    echo "Staged:"
    echo_kind("new", stagedNew)
    echo_kind("modified", stagedModified)
    echo_kind("deleted", stagedDeleted)
    echo "Unstaged:"
    echo_kind("modified", unstagedModified)
    echo_kind("deleted", unstagedDeleted)
    echo "Untracked:"
    echo_plain(untracked)

proc copy_snapshot(source: Table[string, seq[string]]): Table[string, seq[string]]=
    result = initTable[string, seq[string]]()
    for path, history in source.pairs:
        result[path] = history

proc commit_staged*(message: string, parents: seq[string], baseSnapshot: Table[string, seq[string]]): string=
    let index = return_index_as_table()
    if index.len == 0 and parents.len < 2:
        return "nothing to commit"
    var objectMap = return_forrest_as_table()
    var snapshot = copy_snapshot(baseSnapshot)
    var changes: Table[string, seq[string]] = initTable[string, seq[string]]()

    for path, entry in index.pairs:
        if entry.action == actionDelete:
            if snapshot.hasKey(path):
                snapshot.del(path)
                changes[path] = @[]
        elif entry.action == actionAdd:
            var history = if snapshot.hasKey(path): snapshot[path] else: @[]
            let wasAbsent = not snapshot.hasKey(path)
            if history.len == 0 or history[^1] != entry.oid:
                history.add(entry.oid)
                snapshot[path] = history
                changes[path] = @[entry.oid]
            elif wasAbsent:
                snapshot[path] = history
                changes[path] = @[entry.oid]
            if not objectMap.hasKey(path):
                objectMap[path] = @[entry.oid]
            elif objectMap[path][^1] != entry.oid:
                objectMap[path].add(entry.oid)

    if parents.len >= 2:
        for path, entry in index.pairs:
            if path in changes:
                continue
            if entry.action == actionDelete:
                changes[path] = @[]
            elif entry.action == actionAdd:
                changes[path] = @[entry.oid]
    if changes.len == 0 and parents.len < 2:
        return "nothing to commit"

    var deleted: seq[string] = @[]
    for path in objectMap.keys():
        if path notin snapshot:
            deleted.add(path)

    serialize_and_write_forrest(objectMap)
    serialize_and_write_deleted(deleted)
    let commitRecord = COMMIT(commitMessage: message, commitContent: snapshot, changes: changes, parents: parents)
    let oid = data.write_commit_objects(commitRecord.toJson())
    point_branch(read_head(), oid)
    serialize_and_write_index(initTable[string, IndexEntry]())
    return oid
