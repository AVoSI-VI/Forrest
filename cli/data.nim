import std/dirs, std/paths, std/base64, os

import ../lib/[filehasher]

let forrestDir: string = ".Forrest/"
#data wish list
proc initialize_repo*()=
    createDir(Path(forrestDir))
    createDir(Path(forrestDir & "/objects"))
    createDir(Path(forrestDir & "/serialized")) # replace "pickle" directory from Forrest-python
    createDir(Path(forrestDir & "/commits"))

proc updat_ref*()=
    discard

proc get_ref*()=
    discard

proc hash_object*(data: string): string=
    let oid = hash_file_contents_for_OID(data)
    try:
        writeFile(forrestDir & "/" & "objects/" & oid, data)
        
    except CatchableError as e:
        echo e.msg
    return oid
    #obj = 


#python ref
# obj = type_.encode() + b'\x00' + data
#     oid = hashlib.sha1(obj).hexdigest()
#     with open(f'{GIT_DIR}/objects/{oid}', 'wb') as out:
#         out.write(obj)
#     return oid

proc get_object*()=
    discard

proc write_commit_objects*()=
    discard

proc get_commit_objects*()=
    discard