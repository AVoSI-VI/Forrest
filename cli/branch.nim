
#wishlist

proc create_branch*(tag: string)=
    discard

proc merge_branch*()=
    discard

proc get_current_branch()=
    discard

proc checkout_branch*(tag: string, create: bool = false)=
    if create:
        create_branch(tag)
    else:
        echo "b"