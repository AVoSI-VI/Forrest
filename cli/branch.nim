import std/[algorithm, os, tables]

import data, base, commitbase
import ../lib/[filehasher, serializeinteractions]

proc require_repo(): bool=
    if not data.repo_exists():
        echo "not a Forrest repository"
        return false
    return true

proc worktree_block*(): string=
    ## empty string when checkout or merge may change the worktree
    if return_index_as_table().len != 0:
        return "index is not empty"
    let oid = current_commit_oid()
    if oid.len == 0:
        return ""
    let snapshot = commitbase.get_commit(oid).commitContent
    for path, history in snapshot.pairs:
        if history.len == 0:
            continue
        if not fileExists(path):
            return "worktree does not match the current commit"
        if hash_file_contents_for_OID(path) != history[^1]:
            return "worktree does not match the current commit"
    return ""

proc deleted_for_snapshot(snapshot: Table[string, seq[string]]): seq[string]=
    result = @[]
    let objectMap = return_forrest_as_table()
    for path in objectMap.keys():
        if path notin snapshot:
            result.add(path)

proc switch_to_commit*(oid, previousOid: string)=
    var previous = initTable[string, seq[string]]()
    if previousOid.len > 0:
        previous = commitbase.get_commit(previousOid).commitContent
    let target = commitbase.get_commit(oid).commitContent
    for path, history in target.pairs:
        if history.len == 0:
            continue
        base.write_worktree_file(path, data.get_object(history[^1]))
    for path in previous.keys():
        if path notin target and fileExists(path):
            removeFile(path)
    serialize_and_write_deleted(deleted_for_snapshot(target))

proc list_branches*()=
    if not require_repo():
        return
    let current = read_head()
    var names: seq[string] = @[]
    for name in return_branches_as_table().keys():
        names.add(name)
    if current notin names:
        names.add(current)
    names.sort()
    for name in names:
        if name == current:
            echo "* " & name
        else:
            echo "  " & name

proc checkout_branch*(tag: string, create: bool = false)=
    if not require_repo():
        return
    var branches = return_branches_as_table()
    if (not create) and branches.hasKey(tag) and read_head() == tag:
        echo "already on " & tag
        return
    let blocked = worktree_block()
    if blocked.len > 0:
        echo blocked
        return
    if create:
        if branches.hasKey(tag):
            echo "branch already exists: " & tag
            return
        branches[tag] = current_commit_oid()
        serialize_and_write_branch(branches)
        write_head(tag)
        echo "switched to new branch " & tag
        return
    if not branches.hasKey(tag):
        echo "branch does not exist: " & tag
        return
    let previous = current_commit_oid()
    let target = branches[tag]
    write_head(tag)
    if target.len == 0:
        echo "switched to " & tag
        return
    switch_to_commit(target, previous)
    echo "switched to " & tag
