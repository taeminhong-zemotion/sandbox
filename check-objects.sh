#!/bin/bash

USAGE="check-objects.sh DIR"

. sh-setup.sh

if [ $# = 0 ]
then
    usage
fi

# compare the basenames of files and their sha1 checksums
# they must be the same.
find "$1" -type f -exec sha1sum {} + | awk '$1 != gensub(/\*.*\//, "", 1, $2) { print; err = 1 }; END { exit err }' 1>&2
