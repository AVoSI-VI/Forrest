import std/[tables]

import jsony

import ../lib/serializeinteractions

proc set_remote*(name: string, remote: string)=
    # var remoteMap: Table[system.string, string] = (
    #     if fileExists("./.Forrest/serialized/remotes.json"):
    #         var contentsOfForrestJson = readFile("./.Forrest/serialized/remotes.json")
    #         contentsOfForrestJson.fromJson(Table[string, string])
    #     else:
    #         initTable[string, string]()
    # )
    var remoteMap: Table[string, string] = return_remotes_as_table()
    remoteMap[name] = remote

    try:
        let f = open("./.Forrest/serialized/remotes.json", fmWrite)
        defer: f.close
        f.writeLine(remoteMap.toJson())
    except Exception as e:
        echo "unable to write serialized remotes.json file"
        echo ""
        echo e.msg

proc list_remotes*(): Table[string, string]=
    # var remoteMap: Table[system.string, string] = (
    #     if fileExists("./.Forrest/serialized/remotes.json"):
    #         var contentsOfForrestJson = readFile("./.Forrest/serialized/remotes.json")
    #         contentsOfForrestJson.fromJson(Table[string, string])
    #     else:
    #         initTable[string, string]()
    # )
    # echo remoteMap
    let remoteMap: Table[system.string, system.string] = return_remotes_as_table()
    return remoteMap