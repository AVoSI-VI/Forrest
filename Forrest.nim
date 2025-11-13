# using cligen -> https://github.com/c-blake/cligen
# use jsony to serialize objects to then dump to disk -> https://github.com/treeform/jsony

# import os, strformat

import cli/[data, base]

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
    discard

proc commit()=
    discard

proc log()=
    discard

proc checkout()=
    discard

proc tag()=
    discard

proc roll_back_file()=
    discard

proc show_oid_history()=
    discard

proc set_remote()=
    discard

proc list_remotes()=
    discard

proc clone_repo()=
    discard

proc clone_file()=
    discard

when isMainModule:
  import cligen
  dispatchMulti(
    [init],
    [Forrest.hash_object, help={"filename": "requires a filename to hash"}],
    [Forrest.cat_file, help={"oid": "requires the oid of the file"}],
    [Forrest.write_tree]
    )