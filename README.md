# Version:
Officially on version - 0.1.2
Most of the basic functionality has been implemented but the project is still
very much in flux.

Working on V:0.2.0 includes branching and merging.

# Forrest
New home of Forrest-python rewritten in nim language

Alternative to git focused on single files and file history being treated as objects as opposed to the entire repo being treated as one singular object

# CLI Options
```
  init [optional-params] 
    initiallizes an empty Forrest repository under .Forrest/
  Options:
  hash_object [REQUIRED,optional-params] 
    hashes and writes a file into the .Forrest objects directory
    
    the generated hash is the file name it is saved under
  Options:
      -f=, --filename=  string  REQUIRED  requires a filename to hash
  cat_file [REQUIRED,optional-params] 
    gets and prints and object files contents to the console
  Options:
      -o=, --oid=  string  REQUIRED  requires the oid of the file
  write_tree [optional-params] 
    iterates through the current directory and generates objects for all files
    
    under the current directory, and writes a json serialized object map of where
    
    the files are located within the directory - under the .Forrest serialized directory
    
    does not read or update the staging index
  Options:
  read_tree [optional-params] 
    gets the object map from the .Forrest serialized and writes all
    
    newest oid objects tracked within
    
    this is a destructive action
  Options:
  log [REQUIRED,optional-params] 
    writes to the console the changes made in a provided commit along with the commit message and parents
  Options:
      -o=, --oid=  string  REQUIRED  requires an oid of the commit to print out the log
  checkout [REQUIRED,optional-params] 
    switches to a branch and writes that branch's files
    
    refuses when the index or tracked files do not match the current commit
    
    pass --create to create the branch at the current commit
  Options:
      -t=, --tag=  string  REQUIRED  required tagged name of branch to checkout
      -c, --create bool    false     add this switch to create a branch with the passed in tag name
  branch [optional-params] 
    lists branches and marks the current one
  Options:
  merge [REQUIRED,optional-params] 
    merges a branch into the current branch
    
    a fast-forward moves the branch pointer
    
    other merges are finished by commit
    
    when both sides change the same file, conflict markers are written into it
  Options:
      -t=, --tag=  string  REQUIRED  branch to merge into the current branch
  checkout_commit [REQUIRED,optional-params] 
    gets the object map for the provided oid and writes all to the current directory
    
    this is a destructive action
    
    does not move the current branch
  Options:
      -o=, --oid=  string  REQUIRED  requires an oid of the commit to checkout
  roll_back_file [REQUIRED,optional-params] 
    writes provided object file
    
    this is a destructive action
  Options:
      -f=, --fileandpath=  string  REQUIRED  requires full path of file including filename
      -o=, --oid=          string  REQUIRED  requires the oid of the file
  show_oid_history [REQUIRED,optional-params] 
    list object history for a provided file
  Options:
      -f=, --fileandpath=  string  REQUIRED  requires full path of file including filename
  set_remote [REQUIRED,optional-params] 
    set a remote location to clone from
    
    currently only works for local file system
  Options:
      -r=, --remotename=  string  REQUIRED  requires a short hand name for the set remote
      --remoteorigin=     string  REQUIRED  this is a repo you are setting as the origin, it will either be a file path or a url
  list_remotes [optional-params] 
    lists all set remotes
  Options:
  clone_repo [REQUIRED,optional-params] 
    copies .Forrest repo from a set remote to the current directory
    
    and reads the tree from the foreign repo
    
    this is a destructive action
  Options:
      -r=, --remoterepotag=  string  REQUIRED  requires a short hand name for the set remote
  clone_file_full [REQUIRED,optional-params] 
    copies .Forrest repo from a set remote to the current directory
    
    and writes the provided file to the current location
    
    this is a destructive action
  Options:
      -r=, --remoterepotag=  string  REQUIRED  requires a short hand name for the set remote
      -f=, --fileandpath=    string  REQUIRED  requires full path of file including filename
  clone_file_multi [REQUIRED,optional-params] 
    copies .Forrest repo from a set remote to the current directory
    
    and writes the provided comma seperated list of files to the current location
    
    this is a destructive action
  Options:
      -r=, --remoterepotag=  string  REQUIRED  requires a short hand name for the set remote
      -f=, --filesandpaths=  string  REQUIRED  requires a comma separated list of full path of file including filename
  add [optional-params] 
    stages files or directories for the next commit
    
    a missing tracked file is staged for deletion
    
    pass one or more paths after the command; "." stages the worktree
  Options:
  unstage [optional-params] 
    removes paths from the index without changing the worktree
    
    "." clears the index; a directory removes staged paths under it
  Options:
  status [optional-params] 
    shows staged, unstaged, and untracked paths
  Options:
  commit [REQUIRED,optional-params] 
    writes a commit from the staged index with a provided message
    
    an empty index does not create a commit
  Options:
      -m=, --message=  string  REQUIRED  requires a commit message
```

# .clearing
A `.clearing` file in the repo root uses gitignore rules: comments, globs, `dir/`, `**`, and `!` to un-ignore. `add`, `status`, and `write_tree` skip untracked paths that match. Files already tracked stay tracked. `.git` and `.Forrest` are always skipped. `read_tree` and `checkout_commit` leave ignored files on disk.

# Why:
git is great at what it does but I have run into many issues with needing to change singular files in very large repos and generally needing to treat those singular files as objects themselves as opposed to
the entire structure as they don't generally need to be in my use case - 25 million files becomes incredibly slow on commits and gets out of hand when there are lots of changes.

from testing in the original python repo commits after changes happen in < 30s on a 25 million file repo.

# Note:
Forrest doesn't preclude you from using git you can use both at the same time in the same repo. You would just need to add the .Forrest folder to your git ignore.

# Contributing:
- if you want to contribute to the project please open an issue to discuss what you intend to change first before submitting a pull request. Yes even if it is just correcting a spelling mistake.

## TODO List:
- ~~reimplement all features already created in Forrest-python -> creating file tree and objects, setting a remote repo, commits, logs, file rollback, clone from local repo, clone single file~~
- ~~staging additions for commit - ie: git add ...~~
- cloneing from a remote repo
- ~~clone a list of files~~
- split up object directories for performance
- only saving diffs to save on storage space
- compressing file objects to save on space
- ~~branching and merging~~
- ~~automatically ignore .git repos~~
- ~~gitignore equivalent~~
- documentation, documentation, documentation
- TBD
