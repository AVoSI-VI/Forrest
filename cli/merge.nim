import std/[os, tables]

import data, base, branch, commitbase
import ../lib/serializeinteractions
import ../TYPEDEFS/indexObj

proc ancestors(oid: string): seq[string]=
    result = @[]
    var pending = @[oid]
    while pending.len > 0:
        let current = pending.pop()
        if current.len == 0 or current in result:
            continue
        result.add(current)
        for parent in commitbase.get_commit(current).parents:
            pending.add(parent)

proc is_ancestor(older, newer: string): bool=
    if older.len == 0:
        return true
    if newer.len == 0:
        return false
    return older in ancestors(newer)

proc merge_base(ours, theirs: string): string=
    let oursAncestors = ancestors(ours)
    var pending = @[theirs]
    var seen: seq[string] = @[]
    while pending.len > 0:
        let current = pending.pop()
        if current.len == 0 or current in seen:
            continue
        seen.add(current)
        if current in oursAncestors:
            return current
        for parent in commitbase.get_commit(current).parents:
            pending.add(parent)
    return ""

proc tip(snapshot: Table[string, seq[string]], path: string): string=
    if (not snapshot.hasKey(path)) or snapshot[path].len == 0:
        return ""
    return snapshot[path][^1]

proc collect_paths(paths: var seq[string], snapshot: Table[string, seq[string]])=
    for path in snapshot.keys():
        if path notin paths:
            paths.add(path)

proc conflict_text(ours, theirs, tag: string): string=
    result = "<<<<<<< HEAD\n"
    result.add(ours)
    if ours.len == 0 or ours[^1] != '\n':
        result.add('\n')
    result.add("=======\n")
    result.add(theirs)
    if theirs.len == 0 or theirs[^1] != '\n':
        result.add('\n')
    result.add(">>>>>>> " & tag & "\n")

proc side_text(oid: string): string=
    if oid.len == 0:
        return ""
    return data.get_object(oid)

proc take_add(index: var Table[string, IndexEntry], path, oid: string)=
    base.write_worktree_file(path, data.get_object(oid))
    index[path] = IndexEntry(action: actionAdd, oid: oid)

proc take_delete(index: var Table[string, IndexEntry], path: string)=
    if fileExists(path):
        removeFile(path)
    index[path] = IndexEntry(action: actionDelete, oid: "")

proc merge_branch*(tag: string)=
    if not data.repo_exists():
        echo "not a Forrest repository"
        return
    let branches = return_branches_as_table()
    if not branches.hasKey(tag):
        echo "branch does not exist: " & tag
        return
    let theirOid = branches[tag]
    if theirOid.len == 0:
        echo "branch has no commits"
        return
    let blocked = branch.worktree_block()
    if blocked.len > 0:
        echo blocked
        return
    let ourOid = current_commit_oid()
    if is_ancestor(theirOid, ourOid):
        echo "already up to date"
        return
    if is_ancestor(ourOid, theirOid):
        branch.switch_to_commit(theirOid, ourOid)
        point_branch(read_head(), theirOid)
        echo "fast-forward"
        return
    let baseOid = merge_base(ourOid, theirOid)
    if baseOid.len == 0:
        echo "no common ancestor"
        return
    let baseSnap = commitbase.get_commit(baseOid).commitContent
    let ourSnap = commitbase.get_commit(ourOid).commitContent
    let theirSnap = commitbase.get_commit(theirOid).commitContent
    var paths: seq[string] = @[]
    collect_paths(paths, baseSnap)
    collect_paths(paths, ourSnap)
    collect_paths(paths, theirSnap)
    var index = return_index_as_table()
    var conflicts: seq[string] = @[]
    for path in paths:
        let baseTip = tip(baseSnap, path)
        let ourTip = tip(ourSnap, path)
        let theirTip = tip(theirSnap, path)
        if ourTip == theirTip:
            continue
        elif ourTip == baseTip:
            if theirTip.len == 0:
                take_delete(index, path)
            else:
                take_add(index, path, theirTip)
        elif theirTip == baseTip:
            continue
        else:
            let marked = conflict_text(side_text(ourTip), side_text(theirTip), tag)
            base.write_worktree_file(path, marked)
            conflicts.add(path)
    serialize_and_write_index(index)
    write_merge_head(theirOid)
    if conflicts.len > 0:
        write_merge_conflicts(conflicts)
        echo "conflicts:"
        for path in conflicts:
            echo "  " & path
        return
    echo "merge staged; commit to finish"
