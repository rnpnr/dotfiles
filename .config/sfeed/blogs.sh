sfeedpath=~/.cache/sfeed/blogs

feeds() {
	. ~/.config/sfeed/feeds/blogs
}

order() {
	# only keep newest 10 entries
	sort -t '	' -k1rn,1 | sed 10q
}
