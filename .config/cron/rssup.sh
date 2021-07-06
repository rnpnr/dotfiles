#!/bin/sh

# updates rss feeds with sfeed
# sends a notification when a new entry is found

[ ${#} -lt 1 ] && (
	echo 'Wrong number of arguments'
	exit 1
)

configdir=~/.config/sfeed

tmp=$(mktemp)
trap '[ -f "$tmp" ] && rm $tmp' EXIT HUP INT

update() {
	sfeed_update $configdir/${1}.sh
	wait
	html ${1}
}

html() {
	sfeed_html $sfeedpath/* >| $tmp
	compare ${1}
}

compare() {
	cmp -s $tmp $configdir/html/${1}.html || (
		mv $tmp $configdir/html/${1}.html &&
		notify -c "browser $configdir/html/${1}.html" 'New RSS Entries: '"${1}"
	)
}

for arg; do
	. $configdir/${arg}.sh
	[ -d "$sfeedpath" ] || mkdir -p "$sfeedpath"
	update $arg
done
