#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

. $DIR/colors.sh
. $DIR/functions.sh

to=master
while true; do
    case "$1" in
        -i | --interactive ) interactive="-i"; shift ;;
        --onto )
            onto="--onto master";
            to=$2
            shift 2
            ;;
        -h | --help )
            echo -e "Usage: $(basename $0) [-i|--interactive] [--onto branch_name] [-h|--help]\n"
            echo -e "\t-i | --interactive:\tGit rebase will be in interactive mode"
            echo -e "\t--onto branch_name:\tGit will perform rebase against 'branch_name' branch instead of master"
            echo -e "\t\t\t\tRebase will still be performed on the master branch."
            echo -e "\t\t\t\tFor further info see git rebase --help"
            echo -e "\t-h | --help:\t\tShows this help"
            exit 0
            ;;
        -- ) shift; break ;;
        * ) break ;;
    esac
done

git update-index -q --refresh
git diff-index --quiet --cached HEAD
staggedChanges=$?
git diff-files --quiet
notStaggedChanges=$?

if [[ $staggedChanges == 1 || $notStaggedChanges == 1 ]]; then
    echo -e "\n${White}${On_Red}You have some not commited changes or unstagged changes in your repository.${Color_Off}\n"
    echo -e "Please commit or stash them and then run this command again if you wish."
    exit 1
fi

branch=$(git rev-parse --abbrev-ref HEAD)
if [[ $branch == 'master' ]]; then
    echo -e "\n${White}${On_Red}You are on the master branch - please checkout to branch you want to push${Color_Off}"
    exit 1
fi

if [[ -n $onto ]]; then
    echo -e "I am going to rebase current branch '${Yellow}${branch}${Color_Off}', originating from branch '${Yellow}${to}${Color_Off}' onto the ${Yellow}master${Color_Off} branch."
    echo -e "Is that what you wanted? ${Green}git rebase $onto ${to} ${branch}${Color_Off} Type y/n:"
    confirm
    [[ $? -eq 0 ]] && exit
fi

echo -e "${Yellow}Going to pull the ${Green}master${Yellow}, fast-forward only${Color_Off}"
git checkout master
git pull --ff-only

if [[ $? -ne 0 ]]; then
    echo -e "\n${White}${On_Red}Some conflicts appeared after we pulled the master branch.${Color_Off}\n\n"
    echo -e "Please fix them and then run this command again if you wish.\n"
    exit 1
fi

echo -e "${Yellow}Going to rebase branch ${Green}${branch}${Yellow} to the ${Green}master${Color_Off}"

git rebase $interactive $onto ${to} ${branch}

if [[ $? -ne 0 ]]; then
    echo -e "\n${White}${On_Red}Some conflicts appeared after the we did the rebase.${Color_Off}\n\n"
    echo -e "Please fix them and then run this command again if you wish."
    echo -e "To do so, please ${Green}follow the git instructions above the error message.${Color_Off}\n"
    exit 1
fi

echo -e "${Yellow}Going to merge rebased branch ${Green}${branch}${Yellow} with the ${Green}master${Color_Off}"

git checkout master
git merge $branch

changes=$(git log --oneline --color origin/master..master)

if [[ -z $changes ]]; then
    echo -e "${Yellow}There were no changes -> nothing to push${Color_Off}"
else
    echo -e "${Yellow}Merging done, here are the commits with the changes:${Color_Off}\n"
    echo -e "${changes}"

    echo -e "\n${Yellow}Do you want to push the changes? Type ${Green}y${Yellow}/${Green}n${Yellow}:${Color_Off}"
    confirm
    [[ $? -eq 0 ]] && exit

    git push

    if [[ $? == 1 ]]; then
        echo -e "\n${White}${On_Red}Failed to push your changes.${Color_Off}\n"
        echo -e "There are probably new commits on the origin - please pull them and then push the changes manualy."
    fi
fi
