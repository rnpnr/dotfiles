sfeedpath=~/.cache/sfeed/videos

feeds() {
	. ~/.config/sfeed/feeds/videos
}

order() {
	# only keep newest 6 entries
	sort -t '	' -k1rn,1 | sed 6q
}
