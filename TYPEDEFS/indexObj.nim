type
    IndexEntry* = object
        action*: string
        oid*: string

const
    actionAdd* = "add"
    actionDelete* = "delete"
