set -C
set -o vi

UNAME="$(uname -s)"

#########################
# Environment Variables #
#########################
[ -f ~/.secrets ] && . ~/.secrets

PS1='$(tput bold)\W \$$(tput sgr0) '
if [ -n "$SSH_CONNECTION" ]; then
	PS1="$(hostname) $PS1"
fi
#MPD_HOST="$HOME/.config/mpd/socket"
MPD_HOST="localhost"
HISTFILE=$HOME/.history
HISTSIZE=10000
HISTCONTROL=ignoredups:ignorespace
EDITOR="vi"
VISUAL="vi"
export MPD_HOST HISTCONTROL HISTFILE HISTSIZE EDITOR VISUAL

if [ $UNAME == "OpenBSD" ]; then
	ulimit -c 0
fi

if [ $UNAME == "Linux" ]; then
	if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
		startx
	fi
fi

###########
# Aliases #
###########
alias c=clear
alias ll='ls -lh'
alias mkdir='mkdir -p'
alias ncmpcpp='tput smkx && ncmpcpp'
alias page='mupdf -C E6D0B3'
alias mvi='mpv --profile=image'

# git
alias ga='git apply'
alias gc='git checkout'
alias gd='git diff'

# youtube-dl
alias yt="youtube-dl"
alias yt720="yt -f 'bestvideo[height = 720]+bestaudio/best'"
alias ytbest="yt -f '(bestvideo+bestaudio)/best'"
alias yt-mus='mpv --shuffle "$YT_MUS"'

alias pwgen='pwgen -Cnsy'
pwclip() {
	spm show "${1}" | sed 1q | tr -d \\n |
	xclip -i -selection clipboard -loops 1 -quiet |2> /dev/null
}

rmimg() {
	for file; do
		echo "removing image metadata from: $file"
		case $file in
			*.flac)
				metaflac --remove --block-type=PICTURE "$file"
				;;
			*.mp3)
				eyeD3 --remove-all-images "$file"
				;;
		esac
	done
}

if [ $UNAME == "OpenBSD" ]; then
	alias dhclient='doas /sbin/dhclient'
	alias ifconfig='doas /sbin/ifconfig'

	alias cc='cc -O3 -pipe -Weverything -Werror -pedantic-errors -std=c99'
	alias c++='c++ -O3 -pipe -Weverything -Werror'
fi

if [ -f /etc/gentoo-release ]; then
	alias tcc='tcc -Wall -Werror'
	alias cc='cc -O3 -pipe -Wall -Werror -pedantic-errors -std=c99'
	alias c++='c++ -O3 -pipe -Wall -Werror'
	alias emerge='doas /usr/bin/emerge'
	alias ifconfig='doas /bin/ifconfig'
	alias -d mus=~/media/mus
	alias -d tag=~/media/mus/tag
	alias -d cu=~/media/pic/cute-stuff
	alias -d dn=~/downloads/normal
	alias -d dt=~/downloads/torrents
fi

###############
# Completions #
###############
#if [ -d ~/.spm ]; then
#        SPM_LIST=$(
#                cd ~/.spm
#                find . -type f -name \*.gpg | sed 's:^\./::; s:\.gpg$::g'
#        )
#        set -A complete_spm -- $SPM_LIST
#fi

set -A complete_ifconfig_1 -- $(ifconfig | sed -n '/^[a-z]/s,:.*,,p')

if [ $UNAME == "OpenBSD" ]; then
	PKG_LIST=$(ls /var/db/pkg)
	set -A complete_pkg_delete -- $PKG_LIST
	set -A complete_pkg_info -- $PKG_LIST

	set -A complete_mixerctl -- $(mixerctl | sed 's:=.*$::')
	set -A complete_sysctl -- $(sysctl | sed 's:=.*$::')
	set -A complete_rcctl_2 -- $(rcctl ls all)
fi

unset UNAME SPM_LIST PKG_LIST
