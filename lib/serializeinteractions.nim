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