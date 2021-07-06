sfeedpath=~/.cache/sfeed/soft

feeds() {
	. ~/.config/sfeed/feeds/soft
}

filter() {
	# replace github commits with their plaintext patches
	sed 's:\(	.*github.*/commit/[A-z0-9]*\):\1.patch:'
}

order() {
	# only keep newest 10 entries
	sort -t '	' -k1rn,1 | sed 10q
}
