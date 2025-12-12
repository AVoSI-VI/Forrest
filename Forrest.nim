# using cligen -> https://github.com/c-blake/cligen
# use jsony to serialize objects to then dump to disk -> https://github.com/treeform/jsony

# import os, strformat
import std/tables

import cli/[data, base, remote, clone]

#starting with the wish list
proc init()=
    ## initiallizes an empty Forrest repository under .Forrest/
    data.initialize_repo()
    echo "Initalized empty Forrest repository"

proc hash_object(filename: string)=
    ## hashes and writes a file into the .Forrest objects directory
    ## 
    ## the generated hash is the file name it is saved under
    echo data.hash_object(filename)

proc cat_file(oid: string)=
    ## gets and prints and object files contents to the console
    echo data.get_object(oid)

proc write_tree()=
    ## iterates through the current directory and generates objects for all files
    ## 
    ## under the current directory, and writes a json serialized object map of where
    ## 
    ## the files are located within the directory - under the .Forrest serialized directory
    echo base.write_tree().changes

proc read_tree()=
    ## gets the object map from the .Forrest serialized and writes all
    ## 
    ## newest oid objects tracked within
    ##
    ## this is a destructive action
    base.read_tree()

proc commit(message: string)=
    ## writes tree of current directory with a provided message
    echo base.commit(message)

proc log(oid: string)=
    ## writes to the console the changes made in a provided commit along with the commit message
    let commit: tuple[commitMessage: string, commitContent: Table[system.string, seq[string]], changes: Table[system.string, seq[string]]] = base.get_commit(oid)
    echo commit.changes
    echo ""
    echo commit.commitMessage

proc checkout(branchTag: string)=
    discard

proc checkout_commit(oid: string)=
    ## gets the object map for the provided oid and writes all to the current directory
    ##
    ## this is a destructive action
    base.checkout_commit(oid)

proc tag()=
    discard

proc roll_back_file(fileandpath: string, oid: string)=
    ## writes provided object file 
    ##
    ## this is a destructive action
    base.roll_back_file(fileandpath, oid)

proc show_oid_history(fileandpath: string)=
    ## list object history for a provided file
    base.show_oid_history(fileandpath)

proc set_remote(remotename: string, remoteorigin: string)=
    ## set a remote location to clone from
    ## 
    ## currently only works for local file system
    remote.set_remote(remotename, remoteorigin)

proc list_remotes()=
    ## lists all set remotes
    echo remote.list_remotes()

proc clone_repo(remoterepotag: string)=
    ## copies .Forrest repo from a set remote to the current directory
    ## 
    ## and reads the tree from the foreign repo
    ##
    ## this is a destructive action
    clone.clone_repo(remoterepotag)

proc clone_file_full(remoterepotag: string, fileandpath: string)=
    ## copies .Forrest repo from a set remote to the current directory
    ## 
    ## and writes the provided file to the current location
    ##
    ## this is a destructive action
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
    [Forrest.log, help={"oid": "requires an oid of the commit to print out the log"}],
    [Forrest.checkout_commit, help={"oid": "requires an oid of the commit to checkout"}],
    [Forrest.roll_back_file, help={"fileandpath": "requires full path of file including filename", "oid": "requires the oid of the file"}],
    [Forrest.show_oid_history, help={"fileandpath": "requires full path of file including filename"}],
    [Forrest.set_remote, help={"remotename": "requires a short hand name for the set remote", "remoteorigin": "this is a repo you are setting as the origin, it will either be a file path or a url"}],
    [Forrest.list_remotes],
    [Forrest.clone_repo, help={"remoterepotag": "requires a short hand name for the set remote"}],
    [Forrest.clone_file_full, help={"remoterepotag": "requires a short hand name for the set remote", "fileandpath": "requires full path of file including filename"}]
    )