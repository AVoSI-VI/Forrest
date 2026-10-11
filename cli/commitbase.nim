import std/[tables]

import jsony

import data, base, stage

proc read_tree_commit(commitContent: Table[string, seq[string]])=
    base.empty_current_directory()
    for k in commitContent.keys():
        let l = len(commitContent[k]) - 1
        base.write_worktree_file(k, data.get_object(commitContent[k][l]))

proc commit*(message: string): string=
    if not data.repo_exists():
        return "not a Forrest repository"
    return stage.commit_staged(message)

proc get_commit*(oid: string): tuple[commitMessage: string, commitContent: Table[string, seq[string]], changes: Table[string, seq[string]]]=
    return data.get_commit_objects(oid).fromJson(tuple[commitMessage: string, commitContent: Table[string, seq[string]], changes: Table[string, seq[string]]])

proc checkout_commit*(oid: string)=
    let objectMapAtTimeOfCommit = get_commit(oid)
    read_tree_commit(objectMapAtTimeOfCommit.commitContent)