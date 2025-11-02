# import checksums/sha1
import checksums/sha3

proc hash_file_contents_for_OID*(file: string): string=
    let passedInFileContents: string = readFile(file)
    var shaFileHasher: Sha3StateStatic[Sha3_256] = initSha3_256()
    shaFileHasher.update(passedInFileContents)
    shaFileHasher.update("i'malittleteapot") #salt for hash
    return $shaFileHasher.digest() # return string value of the sha3 hash
    # return $secureHashFile(file)