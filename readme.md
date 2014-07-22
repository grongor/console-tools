git-tools
=========

This package contains some usefull scripts which I use to simplify my daily tasks. If you like them then feel free to use them. Any suggestions for improvements and new scripts are welcome - please send a pull request :-)

pull-rebase-push - prp
----------------------

**Recommended alias:** git config --global git.prp "!/path/to/git-pull-rebase-push.sh "  
For usage information use **git prp -h**

This script will basically perform a pull on master branch (only fast-forward, no merge commits will be created), rebases the current branch with the master, performs a merge with the rebased branch and finally pushes the changes.