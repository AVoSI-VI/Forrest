# Forrest
New home of Forrest-python rewritten in nim language

Alternative to git focused on single files and file history being treated as objects as opposed to the entire repo being treated as one singular object

# Why:
git is great at what it does but I have run into many issues with needing to change singular files in very large repos and generally needing to treat those singular files as objects themselves as opposed to
the entire structure as they don't generally need to be in my use case - 25 million files becomes incredibly slow on commits and gets out of hand when there are lots of changes.

from testing in the original python repo commits after changes happen in < 30s on a 25 million file repo.

# Note:
Forrest doesn't preclude you from using git you can use both at the same time in the same repo. You would just need to add the .Forrest folder to your git ignore.

## TODO List:
- reimplement all features already created in Forrest-python -> creating file tree and objects, setting a remote repo, commits, logs, file rollback, clone from local repo, clone single file
- cloneing from a remote repo
- only saving diffs to save on storage space
- compressing file objects to save on space
- branching and merging
- automatically ignore .git repos
- gitignore equivalent
- documentation, documentation, documentation
- TBD
