import std/[dirs, paths, os]

import ../lib/[filehasher, serializeinteractions]

let forrestDir: string = ".Forrest/"

proc repo_exists*(): bool=
    return dirExists(".Forrest")

proc initialize_repo*()=
    createDir(Path(forrestDir))
    createDir(Path(forrestDir & "objects"))
    createDir(Path(forrestDir & "serialized")) # replace "pickle" directory from Forrest-python
    createDir(Path(forrestDir & "commits"))
    createDir(Path(forrestDir & "branches"))
    ensure_staging_files()
    ensure_head_and_main()

proc update_ref*()=
    discard

proc get_ref*()=
    discard

proc hash_object*(filename: string): string=
    let contents = readFile(filename)
    let oid = hash_contents_for_OID(contents)
    if not fileExists(forrestDir & "objects/" & oid):
        try:
            writeFile(forrestDir & "objects/" & oid, contents)
        except CatchableError as e:
            echo e.msg
    return oid

proc get_object*(oid: string): string=
    return readFile(forrestDir & "objects/" & oid)

proc write_commit_objects*(data: string): string=
    let oid = hash_contents_for_OID(data)
    try:
        writeFile(forrestDir & "commits/" & oid, data)
        
    except CatchableError as e:
        echo e.msg
    return oid

proc get_commit_objects*(oid: string): string=
    return readFile(forrestDir & "commits/" & oid)