#!/bin/bash

IFS='
'
USAGE="$(printf "%s [--prefix|-p=<dir>]" "$(basename "$0")")"
PREFIX=

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

while [ $# != 0 ]
do
	case "$1" in
    --prefix|-p)
        shift
        PREFIX="$1"
        ;;
    --prefix=*|-p=*)
        PREFIX="${1#*=}"
        ;;
    --)
        shift
        break
        ;;
    -*)
        usage
        ;;
    esac
    shift
done

find . -path ./.git -prune -o -type f -exec sha1sum {} + | while read -r line
    do
        hash="${line:0:40}"
        source="${line:42}"
        ( [ -z "$hash" ] || [ -z "$source" ] ) && die "invalid input: $line"
        target="${PREFIX:+"$PREFIX/"}${hash:0:2}/${hash}"
        if [ ! -e "$target" ]
        then
            mkdir -p "$(dirname "$target")" && cp -a "$source" "$target"
        fi
    done
