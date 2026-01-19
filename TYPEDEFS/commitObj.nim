import std/tables

type
    COMMIT* = object
        commitMessage*: string
        commitContent*: Table[string, seq[string]]
        changes*: Table[string, seq[string]]
