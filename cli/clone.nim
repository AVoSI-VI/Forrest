import std/dirs
import ./[remote, base]
# clone wish list

proc clone_repo(remoteRepoTag: string)=
    let remoteRepos = remote.list_remotes()
    let remoteToClone = remoteRepos[remoteRepoTag]
    let directoryForClone = ".Forrest"
    copyDir(remoteToClone, directoryForClone)
    base.read_tree()

proc clone_file()=
    discard