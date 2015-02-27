#!/bin/bash

branch=$1;

# if you pass only the number as branch name then we
# asume that you are looking for a Jira task
if [[ $branch =~ ^[0-9]+$ ]]; then
    branch=$(git b | grep -Ee "-$branch\b" | sed s/*// | xargs | cut -d' ' -f1)
fi

if [[ $branch == "" ]]; then
    git checkout $1
else
    git checkout $branch
fi

