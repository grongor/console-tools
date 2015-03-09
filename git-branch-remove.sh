#!/bin/bash

branches=`git branch --merged | grep -v '*' | xargs -n 1`
count=`echo "$branches" | wc -w`

if [[ $count -ne 0 ]]; then
    git branch -d $branches
else
    echo "There aren't any merged branches to remove"
fi

