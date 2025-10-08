# using cligen -> https://github.com/c-blake/cligen
# use jsony to serialize objects to then dump to disk -> https://github.com/treeform/jsony

import os

import cli/data

#starting with the wish list
proc init()=
    data.initialize_repo()
    echo "Initalized empty Forrest repository"

proc hash_object()=
    discard

proc cat_file()=
    discard

proc write_tree()=
    discard

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

# when isMainModule:
#   import cligen
#   dispatchMulti([foo, help={"myRequired": "Need it!"}], [bar])