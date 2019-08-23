#!/usr/bin/bash

kite_func() {
    git config --global user.name "Kite Bot"
    git config --global user.email "kite-bot@heliostech.fr"
    git remote add authenticated-origin https://kite-bot:$GITHUB_API_KEY@github.com/${DRONE_REPO}
    git fetch authenticated-origin
}

scan_git() {
     if git log --oneline -n 1 HEAD | grep -qi 'patch'; then
         variable="patch"
     elif git log --oneline -n 1 HEAD | grep -qi 'minor'; then
         variable="minor"
     elif git log --oneline -n 1 HEAD | grep -qi 'major'; then
         variable="major"
     else comit_hash=`git rev-parse --short HEAD `
     fi
 }

scan_language() {
    if -n variable; then
        case "$1" in
            -r|--ruby)
                CMD="bump $variable"
                ;;
            -j|--js)
                CMD="yarn version --$variable"
                ;;
            -g|--go)
                FLAG=1
                CMD="gitsem $variable"
                ;;
            esac
    eval $CMD
    export V=$(cat VERSION)
    fi
}

scan_flag() {
    if -n variable; then
        git tag $(cat VERSION)
    elif FLAG != 1; then
        git tag $(comit_hash)
    fi
}

kite_func()
scan_git()
scan_language()
git add .
scan_flag()
git push authenticated-origin ${DRONE_BRANCH}
git push --tags authenticated-origin
git describe --tags $(git rev-list --tags --max-count=1) > .tags
