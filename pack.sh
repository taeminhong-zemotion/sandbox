#!/bin/bash

USAGE="$(printf "%s SOURCE DEST" "$(basename "$0")")"

. sh-setup.sh

if [ $# -lt 2 ]
then
    usage
fi

find_opts=()

while [ $# != 0 ]
do
    case "$1" in
    --* | -*)
        find_opts+=("$1")
        shift
        ;;
    *)
        break
        ;;
    esac
done

if [ ! -d "$1" ]
then
    die "no such directory: $1"
fi

DEST=$(realpath "${2:-.}")
pushd "${1:-.}" >/dev/null

find "${find_opts[@]}" . -path ./.git -prune -o -type f -exec sha1sum {} + | while read -r line
    do
        hash="${line:0:40}"
        from="${line:42}"
        to="$DEST/${hash:0:2}/${hash}"
        if [ ! -e "$to" ]
        then
            mkdir -p "$(dirname "$to")" && cp "$from" "$to" || exit 1
        fi
        echo "$line"
    done

popd >/dev/null
