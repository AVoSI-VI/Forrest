checksums/sha1

proc hash_file_contents_for_OID*(fileContents: string): string=
    return secureHash(fileContents)