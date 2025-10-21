import checksums/sha1

proc hash_file_contents_for_OID*(file: string): string=
    return $secureHashFile(file)