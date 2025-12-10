# using cligen -> https://github.com/c-blake/cligen
# use jsony to serialize objects to then dump to disk -> https://github.com/treeform/jsony

# import os, strformat

import cli/[data, base, remote, clone]

#starting with the wish list
proc init()=
    data.initialize_repo()
    echo "Initalized empty Forrest repository"

proc hash_object(filename: string)=
    echo data.hash_object(filename)

proc cat_file(oid: string)=
    echo data.get_object(oid)

proc write_tree()=
    echo base.write_tree()

proc read_tree()=
    base.read_tree()

proc commit()=
    discard

proc log()=
    discard

proc checkout()=
    discard

proc tag()=
    discard

proc roll_back_file(fileandpath: string, oid: string)=
    base.roll_back_file(fileandpath, oid)

proc show_oid_history(fileandpath: string)=
    base.show_oid_history(fileandpath)

proc set_remote(remotename: string, remoteorigin: string)=
    remote.set_remote(remotename, remoteorigin)

proc list_remotes()=
    discard remote.list_remotes()

proc clone_repo(remoterepotag: string)=
    clone.clone_repo(remoterepotag)

proc clone_file_full(remoterepotag: string, fileandpath: string)=
    clone.clone_file_full(remoterepotag, fileandpath)

proc clone_file_sparse(remoterepotag: string, fileandpath: string)=
    discard

when isMainModule:
  import cligen
  dispatchMulti(
    [init],
    [Forrest.hash_object, help={"filename": "requires a filename to hash"}],
    [Forrest.cat_file, help={"oid": "requires the oid of the file"}],
    [Forrest.write_tree],
    [Forrest.read_tree],
    [Forrest.roll_back_file, help={"fileandpath": "requires full path of file including filename", "oid": "requires the oid of the file"}],
    [Forrest.show_oid_history, help={"fileandpath": "requires full path of file including filename"}],
    [Forrest.set_remote, help={"remotename": "requires a short hand name for the set remote", "remoteorigin": "this is a repo you are setting as the origin, it will either be a file path or a url"}],
    [Forrest.list_remotes],
    [Forrest.clone_repo, help={"remotename": "requires a short hand name for the set remote"}],
    [Forrest.clone_file_full, help={"remotename": "requires a short hand name for the set remote", "fileandpath": "requires full path of file including filename"}]
    )