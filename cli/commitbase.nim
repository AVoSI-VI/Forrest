import std/[tables]

import jsony

import data, base

proc read_tree_commit(commitContent: Table[string, seq[string]])=
    base.empty_current_directory()
    for k in commitContent.keys():
        let l = len(commitContent[k]) - 1
        writeFile(k, data.get_object(commitContent[k][l]))

proc commit*(message: string): string=
    # let changes = write_tree()
    # var c: seq[string] = @[]
    # for k in changes.keys():
    #     c.add(fmt"{k}: {changes[k]}")
    # let commitContent = fmt"Changes: {c}" & "\n" & "\n" & fmt"{message}" & "\n"
    
    #change to make it easier to manipulate and keep track of commits as a whole
    let objectMapAtTimeOfCommit: tuple[objectMap: Table[string, seq[string]], changes: Table[string, seq[string]]] = base.write_tree()#.objectMap
    let commitContent: tuple[commitMessage: string, commitContent: Table[string, seq[string]], changes: Table[string, seq[string]]] = (commitMessage: message, commitContent: objectMapAtTimeOfCommit.objectMap, changes: objectMapAtTimeOfCommit.changes)

    return data.write_commit_objects(commitContent.toJson())

proc get_commit*(oid: string): tuple[commitMessage: string, commitContent: Table[string, seq[string]], changes: Table[string, seq[string]]]=
    return data.get_commit_objects(oid).fromJson(tuple[commitMessage: string, commitContent: Table[string, seq[string]], changes: Table[string, seq[string]]])

proc checkout_commit*(oid: string)=
    let objectMapAtTimeOfCommit = get_commit(oid)
    read_tree_commit(objectMapAtTimeOfCommit.commitContent)