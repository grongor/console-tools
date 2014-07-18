#!/bin/bash

function confirm() {
    whenInvalid="r u retarded?! Type y or n ..."
    if [[ $# -eq 1 ]]; then
        whenInvalid=$1
    elif [[ $# -eq 2 ]]; then
        question=$1
        whenInvalid=$2
    elif [[ $# -gt 2 ]]; then
        echo -e "\nYou may pass at most 2 arguments to confirm(), exiting" > /dev/tty
        exit 1
    fi

    [[ -n $question ]] && echo -e $question > /dev/tty
    while read answer
    do
        case $(echo $answer | tr '[:upper:]' '[:lower:]') in
            y) return 1 ;;
            n) return 0 ;;
            *) [[ -n $whenInvalid ]] && echo -e $whenInvalid > /dev/tty ;;
        esac
    done
}