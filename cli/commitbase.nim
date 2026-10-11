import std/[strutils, tables]

import jsony

import data, base, stage
import ../lib/serializeinteractions
import ../TYPEDEFS/commitObj

proc read_tree_commit(commitContent: Table[string, seq[string]])=
    base.empty_current_directory()
    for k in commitContent.keys():
        let l = len(commitContent[k]) - 1
        base.write_worktree_file(k, data.get_object(commitContent[k][l]))

proc looks_like_oid(value: string): bool=
    if value.len != 64:
        return false
    for c in value:
        if c notin {'0'..'9', 'a'..'f'}:
            return false
    return true

proc unresolved_conflicts(): bool=
    let index = return_index_as_table()
    for path in read_merge_conflicts():
        if path notin index:
            return true
    return false

proc parents_for_next_commit(): seq[string]=
    let headOid = current_commit_oid()
    let merging = read_merge_head()
    if merging.len > 0:
        if headOid.len > 0:
            result.add(headOid)
        result.add(merging)
        return
    if headOid.len > 0:
        result.add(headOid)

proc get_commit*(oid: string): COMMIT=
    let raw = data.get_commit_objects(oid).strip()
    if raw.len > 0 and raw[0] == '[':
        let old = raw.fromJson(tuple[commitMessage: string, commitContent: Table[string, seq[string]], changes: Table[string, seq[string]]])
        return COMMIT(commitMessage: old.commitMessage, commitContent: old.commitContent, changes: old.changes, parents: @[])
    return raw.fromJson(COMMIT)

proc commit*(message: string): string=
    if not data.repo_exists():
        return "not a Forrest repository"
    if unresolved_conflicts():
        return "resolve merge conflicts and add them before committing"
    let headOid = current_commit_oid()
    var baseSnapshot = initTable[string, seq[string]]()
    if headOid.len > 0:
        baseSnapshot = get_commit(headOid).commitContent
    let oid = stage.commit_staged(message, parents_for_next_commit(), baseSnapshot)
    if looks_like_oid(oid):
        clear_merge_state()
    return oid

proc checkout_commit*(oid: string)=
    let objectMapAtTimeOfCommit = get_commit(oid)
    read_tree_commit(objectMapAtTimeOfCommit.commitContent)