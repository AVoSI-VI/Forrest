import std/dirs, std/paths#, std/base64, os

import ../lib/[filehasher]

let forrestDir: string = ".Forrest/"
#data wish list
proc initialize_repo*()=
    createDir(Path(forrestDir))
    createDir(Path(forrestDir & "objects"))
    createDir(Path(forrestDir & "serialized")) # replace "pickle" directory from Forrest-python
    createDir(Path(forrestDir & "commits"))

proc update_ref*()=
    discard

proc get_ref*()=
    discard

proc hash_object*(data: string): string=
    let oid = hash_file_contents_for_OID(data)
    try:
        writeFile(forrestDir & "objects/" & oid, data)
        
    except CatchableError as e:
        echo e.msg
    return oid

proc get_object*(oid: string): string=
    return readFile(forrestDir & "objects/" & oid)

proc write_commit_objects*(data: string): string=
    let oid = hash_file_contents_for_OID(data)
    try:
        writeFile(forrestDir & "commits/" & oid, data)
        
    except CatchableError as e:
        echo e.msg
    return oid

proc get_commit_objects*(oid: string): string=
    return readFile(forrestDir & "commits/" & oid)