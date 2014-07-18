#!/bin/bash

. colors.sh
. functions.sh

branch=$(git rev-parse --abbrev-ref HEAD)
#branch=source_test # test source branch
if [[ $branch == 'master' ]]; then
    echo -e "\nYou are on the master branch - please checkout to branch you want to push"
    exit 1
fi

to=master
if [[ $# -eq 1 ]]; then
    onto="--onto master"
    to=$1
    echo -e "I am going to rebase current branch '${Yellow}${branch}${Color_Off}', originating from branch '${Yellow}${to}${Color_Off}' onto the ${Yellow}master${Color_Off} branch."
    echo -e "Is that what you wanted? ${Green}git rebase $onto ${to} ${branch}${Color_Off} Type y/n:"
    confirm
    [[ $? -eq 0 ]] && exit
fi

exit

git checkout master
git pull

#mkdir /if/this/folder/exists/then/you/are/insane 2> /dev/null # test pull conflicts

if [[ $? -eq 1 ]]; then
    echo -e "\n${White}${On_Red}Some conflicts appeared after we pulled the master branch.${Color_Off}\n\n"
    echo -e "Please fix them and then run this command again if you wish.\n"
    exit 1
fi

git rebase $onto ${to} ${branch}

#mkdir /if/this/folder/exists/then/you/are/insane 2> /dev/null # test rebase conflicts

if [[ $? -eq 1 ]]; then
    echo -e "\n${White}${On_Red}Some conflicts appeared after the we did the rebase.${Color_Off}\n\n"
    echo -e "Please fix them and then run this command again if you wish."
    echo -e "To do so, please ${Green}follow the git instructions above the error message.${Color_Off}\n"
    exit 1
fi

git checkout master
git merge $branch

git log --oneline master..origin/master

echo -e "\nMerging completed. Do you want to push the changes? Type y/n:"
confirm
[[ $? -eq 0 ]] && exit

git push
