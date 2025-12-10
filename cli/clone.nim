import std/[dirs, tables, os]

import jsony

import ./[remote, base]
# clone wish list

proc clone_repo*(remoteRepoTag: string)=
    let remoteRepos = remote.list_remotes()
    let remoteToClone = remoteRepos[remoteRepoTag]
    let directoryForClone = ".Forrest"
    copyDir(remoteToClone, directoryForClone)
    base.read_tree()

proc clone_file_full*(remoteRepoTag: string, fileAndPath: string)=
    ##does a full clone of a remote file system base repo

    let remoteRepos = remote.list_remotes()
    let remoteToClone = remoteRepos[remoteRepoTag]
    let directoryForClone = ".Forrest"
    copyDir(remoteToClone, directoryForClone)
    var objectMap: Table[system.string, seq[string]] = (
        if fileExists("./.Forrest/serialized/Forrest.json"):
            var contentsOfForrestJson = readFile("./.Forrest/serialized/Forrest.json")
            contentsOfForrestJson.fromJson(Table[string, seq[string]])
        else:
            initTable[string, seq[string]]()
    )
    
    base.write_clone_file(fileAndPath)
    remote.set_remote("parent", remoteToClone)

#!!TODO
# proc clone_file_sparse*(remoteRepoTag: string, fileAndPath: string)=
#    ##only clones the base folders and only the oid files of the specified file and path
#    ## does not include commit history only the oids of the specified file
#    ## used for quick clones of only needed files without the overhead of pulling the entire repo
#     let remoteRepos = remote.list_remotes()
#     let remoteToClone = remoteRepos[remoteRepoTag]
#     let directoryForClone = ".Forrest"
#
#     var objectMap: Table[system.string, seq[string]] = (
#         if fileExists("./.Forrest/serialized/Forrest.json"):
#             var contentsOfForrestJson = readFile("./.Forrest/serialized/Forrest.json")
#             contentsOfForrestJson.fromJson(Table[string, seq[string]])
#         else:
#             initTable[string, seq[string]]()
#     )
#     let filesToCopy = objectMap[fileAndPath]
#     for oid in filesToCopy:
#       copyFileToDir(remoteToClone)