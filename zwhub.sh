#!/bin/bash

shopt -s nullglob

IFS='
'
USAGE="zwhub [list|install|uninstall|run]"
prefix=

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

unpack () {
    dir="$2"
    while read -r line
    do
        hash="${line:0:40}"
        file="${line:42}"
        if [ $(expr length "$hash") != 40 ] || [ -z "$file" ]
        then
            echo "invalid input: $line" 1>&2
            return 1
        fi
        from="$ZWHUB_HOME/objects/${hash:0:2}/$hash"
        to="$dir/$file"
        mkdir -p "$(dirname "$file")" && cp "$from" "$to" || return 1
    done < "$1"
}

cmd_install () {
    err=0
    force=

    while [ $# != 0 ]
    do
        case "$1" in
        --force | -f)
            force=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            break
            ;;
        esac
    done

    for version in "$@"
    do
        checksums="$ZWHUB_HOME/checksums/$version.txt"
        if [ -f "$checksums" ]
        then
            if [ -d "$ZWHUB_EDITORS/$version" ] && [ -z "$force" ]
            then
                echo "$version already installed"
            elif unpack "$checksums" "$ZWHUB_EDITORS/$version.tmp" && \
                rm -rf "$ZWHUB_EDITORS/$version" && \
                mv "$ZWHUB_EDITORS/$version.tmp" "$ZWHUB_EDITORS/$version"
            then
                echo "$version installed"
            else
                rm -rf "$ZWHUB_EDITORS/$version.tmp"
                echo "$version installation failed!" 1>&2
                err=1
            fi
        else
            echo "$version is not available!" 1>&2
            err=1
        fi
    done
    return $err
}

cmd_uninstall () {
    for version in "$@"
    do
        rm -r "$ZWHUB_EDITORS/$version"
    done
}

cmd_list () {
    for c in "$ZWHUB_HOME"/checksums/*.txt
    do
        version="$(basename "${c%.*}")"
        printf "$version"
        if [ -d "$ZWHUB_EDITORS/$version" ]
        then
            printf "\tinstalled\n"
        else
            printf "\n"
        fi
    done | sort -V
}

cmd_run () {
    for version in "$@"
    do
        rm -r "$ZWHUB_EDITORS/$version"
}

while [ $# != 0 ] && [ -z "$command" ]
do
	case "$1" in
	list | install | uninstall | run)
		command=$1
        ;;
    --)
        shift
        break
        ;;
    *)
        usage
        ;;
    esac
    shift
done

[ -n "$command" ] || usage
[ -n "$ZWHUB_HOME" ] || die "\$ZWHUB_HOME is not defined!"
[ -n "$ZWHUB_EDITORS" ] || die "\$ZWHUB_EDITOR is not defined!"

cmd_"$command" "$@"
