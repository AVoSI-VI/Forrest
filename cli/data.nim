import std/dirs, std/paths, std/base64, checksums/sha1

let forrestDir: string = ".Forrest/"
#data wish list
proc initialize_repo*()=
    # TODO: look into this again, don't know if I want to do it this way or not
    createDir(Path(forrestDir))
    createDir(Path(forrestDir & "/objects"))
    createDir(Path(forrestDir & "/serialized")) # replace "pickle" directory from Forrest-python
    createDir(Path(forrestDir & "/commits"))

proc updat_ref*()=
    discard

proc get_ref*()=
    discard

proc hash_object*(data: string)=
    discard
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