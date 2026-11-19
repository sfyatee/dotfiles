if [[ ! -o interactive ]]; then return; fi

unset HISTFILE
HISTCONTROL=ignoredups:ignorespace
HISTSIZE=5000

set -o emacs
set -o csh-history

PS1=':; '

# Report current working directory at each prompt.
osc7() {
	command cd "$@" || return

	typeset tmp=$PWD enc= cut c p
	while [[ -n $tmp ]]; do
		cut=${tmp#?}
		c=${tmp%"$cut"}
		case $c in
		[-/:_.!\'\(\)~[:alnum:]]) enc=$enc$c ;;
		*) enc=$enc$(printf '%%%02X' "'$c")  ;;
		esac
		tmp=$cut
	done

	p=$(printf "\033]7;file://%s%s\033\\" "$sys" "$enc")
	printf '%s' "$p"
	if [ -n "$TMUX" ]; then
		printf '%s' "$p" >$(tmux display-message -p '#{client_tty}')
	fi
}

alias cp='cp -i'
alias ll='ls -AlF'
alias ls='ls -AF'
alias ltr='ls -AlFtr'
alias mv='mv -i'
alias publicip="curl -4 -w '\n' -s http://ifconfig.me"
alias snarf='git --git-dir $HOME/lib/dotfiles --work-tree $HOME'

lc() { ls -1AF "$@" | mc; }

osc7 $PWD
alias cd=osc7

case "$OS" in
linux)
	alias ls='ls -AFv'
	alias pclean="makepkg -C"
	alias pstree="ps -e f -ww -o pid,args"
	;;
openbsd)
	# check shared libs version
	cshlib() {
		local cnt=0
		local f

		for f in $(make show=SHARED_LIBS); do
			[ "$((cnt++ % 2))" -eq 1 ] && continue
			echo '===>' $f
			/usr/src/lib/check_sym /usr/local/lib/lib$f.so* \
				$(make show=WRKINST)/usr/local/lib/lib$f.so*
		done
	}
	alias cvs=opencvs
	alias mpldc="make port-lib-depends-check"
	alias mup="make update-patches"
	alias mupl="make update-plist"
	alias pclean='make clean="package plist"'
	alias pstree="ps -Aww -f -o pid,command"
	alias rsync="openrsync"
esac

if command -v hx >/dev/null 2>&1; then
	alias vi="hx"
	alias view="hx"
	EDITOR=hx
else
	EDITOR=/usr/bin/vi
fi

if [[ "$TERM" == "dumb" ]]; then
	PS1=': $(s=$?; ((s == 0)) || print -rn "{$s} ")$H; '
fi

[ -e ~/.kshrc.local ] && . ~/.kshrc.local || :
