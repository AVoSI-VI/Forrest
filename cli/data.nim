import std/dirs, std/paths

let forrestDir: Path = Path(".Forrest/")
#data wish list
proc initialize_repo*()=
    # TODO: look into this again, don't know if I want to do it this way or not
    createDir(forrestDir)
    createDir(Path(string(forrestDir) & "/objects"))
    createDir(Path(string(forrestDir) & "/serialized")) # replace "picle" directory from Forrest-python
    createDir(Path(string(forrestDir) & "/commits"))

proc updat_ref*()=
    discard

proc get_ref*()=
    discard

proc hash_object*()=
    discard

proc get_object*()=
    discard

proc write_commit_objects*()=
    discard

proc get_commit_objects*()=
    discard