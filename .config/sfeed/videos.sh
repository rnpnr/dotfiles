sfeedpath=~/.cache/sfeed/videos

feeds() {
	. ~/.config/sfeed/feeds/videos
}

filter() {
	# replace lbry links with odysee links
	sed '/lbry:\/\//s;lbry://;https://odysee.com/;'
}

order() {
	# only keep newest 30 entries
	sort -t '	' -k1rn,1 | sed 30q
}
