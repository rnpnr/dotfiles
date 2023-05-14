sfeedpath=~/.cache/sfeed/blogs

feeds() {
	. ~/.config/sfeed/feeds/blogs
}

order() {
	# only keep newest 30 entries
	sort -t '	' -k1rn,1 | sed 30q
}
