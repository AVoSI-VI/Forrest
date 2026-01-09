import std/[tables, os]

import jsony

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