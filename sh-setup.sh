IFS='
'

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
