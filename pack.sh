#!/bin/bash

IFS='
'
USAGE="$(printf "%s SOURCE DEST" "$(basename "$0")")"

die () {
	die_with_status 1 "$@"
}

die_with_status () {
	status="$1"
	shift
	printf >&2 '%s\n' "$*"
	exit "$status"
}

usage () {
	die "usage: $USAGE"
}

if [ $# -lt 2 ]
then
    usage
fi

if [ ! -d "$1" ]
then
    die "no such directory: $1"
fi

DEST=$(realpath "${2:-.}")
pushd "${1:-.}" >/dev/null

find . -path ./.git -prune -o -type f -exec sha1sum {} + | while read -r line
    do
        hash="${line:0:40}"
        from="${line:42}"
        to="$DEST/${hash:0:2}/${hash}"
        if [ ! -e "$to" ]
        then
            mkdir -p "$(dirname "$to")" && cp -a "$from" "$to" || exit 1
        fi
        echo "$line"
    done

popd >/dev/null
