import std/[tables, os, strutils]

import ./[remote, base, data]

proc clone_repo*(remoteRepoTag: string)=
    let remoteRepos = remote.list_remotes()
    let remoteToClone = remoteRepos[remoteRepoTag]
    let directoryForClone = ".Forrest"
    copyDir(remoteToClone, directoryForClone)
    base.read_tree()

proc clone_file_full*(remoteRepoTag: string, fileAndPath: string)=
    ##does a full clone of a remote file system base repo
    ## and writes the specified file

    let remoteRepos = remote.list_remotes()
    let remoteToClone = remoteRepos[remoteRepoTag]
    let directoryForClone = ".Forrest"
    copyDir(remoteToClone, directoryForClone)
    
    base.write_clone_file(fileAndPath)
    remote.set_remote("parent", remoteToClone)

#!!TODO
proc clone_file_sparse*(remoteRepoTag: string, fileAndPath: string)=
    ##only clones the base folders and only the oid files of the specified file and path
    ## does not include commit history only the oids of the specified file
    ## used for quick clones of only needed files without the overhead of pulling the entire repo
    let remoteRepos = remote.list_remotes()
    let remoteToClone = remoteRepos[remoteRepoTag]
    let directoryForClone = "."
    data.initialize_repo()
    # copyFileToDir(fmt"{remoteToClone}/", ".")
    

proc clone_file_multi*(remoteRepoTag: string, filesAndPaths: string)=
    ##does a full clone of a remote file system base repo
    ## and writes the specified files
    let splitUpFiles = filesAndPaths.split(",")
    let remoteRepos = remote.list_remotes()
    let remoteToClone = remoteRepos[remoteRepoTag]
    let directoryForClone = ".Forrest"
    copyDir(remoteToClone, directoryForClone)
    
    for fileandpath in splitUpFiles:
        base.write_clone_file(fileAndPath)
    remote.set_remote("parent", remoteToClone)