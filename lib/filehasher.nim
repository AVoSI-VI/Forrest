# import checksums/sha1
import checksums/sha3

proc hash_contents_for_OID*(contents: string): string=
    ## hashes bytes without reading or writing a file
    var shaFileHasher: Sha3StateStatic[Sha3_256] = initSha3_256()
    shaFileHasher.update(contents)
    shaFileHasher.update("i'malittleteapot") #salt for hash
    return $shaFileHasher.digest()

proc hash_file_contents_for_OID*(file: string): string=
    ## hashes a file without writing an object
    return hash_contents_for_OID(readFile(file))
