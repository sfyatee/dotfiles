#!/bin/zsh
umask 022

if [[ ! -o interactive ]]; then return; fi

unset HISTFILE
setopt globdots
setopt listtypes
setopt noclobber	# insurance
setopt extendedglob
setopt rcquotes	# à la rc(1)
setopt bashautolist

bindkey -e

# Enable auto completion and use XDG directories.
autoload -Uz compinit
[ -d "$HOME/.cache"/zsh ] || mkdir -p "$HOME/.cache"/zsh
zstyle ':completion:*' cache-path "$HOME/.cache"/zsh/zcompcache
compinit -C -d "$HOME/.cache"/zsh/zcompdump-$ZSH_VERSION

# gitpwd- print %~, limited to $NDIR segments, with inline (git|got|jj) branch
NDIRS=2
gitpwd() {
	local -a segs splitprefix gotdir jjdir; local gitprefix jjprefix branch
	segs=("${(Oas:/:)${(D)PWD}}")
	segs=("${(@)segs/(#b)(?(#c10))??*(?(#c5))/${(j:\u2026:)match}}")

	jjdir=( (../)#.jj(/N[-1]) )
	gotdir=( (../)#.got(/N[-1]) )
	if [[ $jjdir ]]; then
		jjdir=( "${(s:/:)jjdir}" )
		branch=$(jj prompt 2>/dev/null)
		if (( $#jjdir > NDIRS )); then
			print -n "${segs[$#jjdir]}*$branch "
		else
			segs[$#jjdir]+="*$branch"
		fi
	elif [[ $gotdir ]]; then
		gotdir=( "${(s:/:)gotdir}" )
		branch=$(got branch 2>/dev/null)
		if (( $#gotdir > NDIRS )); then
			print -n "${segs[$#gotdir]}!$branch "
		else
			segs[$#gotdir]+="!$branch"
		fi
	elif gitprefix=$(git rev-parse --show-prefix 2>/dev/null); then
		splitprefix=("${(s:/:)gitprefix}")
		if ! branch=$(git symbolic-ref -q --short HEAD); then
			branch=$(git name-rev --name-only HEAD 2>/dev/null)
			[[ $branch = *\~* ]] || branch+="~0"    # distinguish detached HEAD
		fi
		if (( $#splitprefix > NDIRS )); then
			print -n "${segs[$#splitprefix]}@$branch "
		else
			segs[$#splitprefix]+=@$branch
		fi
	fi

	(( $#segs == NDIRS+1 )) && [[ $segs[-1] == "" ]] && print -n /
	print "${(j:/:)${(@Oa)segs[1,NDIRS]}}"
}

nbsp=$'\u00A0'
sfprompt() {
	precmd_psvar() { psvar=( "$(gitpwd)" ) }
	PROMPT="%B$H${TDIR:+ [$TDIR:h:t]}%(?.. %??)%(1j. %j&.)%b %v%B%(!.%F{red}.%F{yellow})%#${SSH_CONNECTION:+%#}$nbsp%b%f"
	RPROMPT=''
}


sfprompt

# Remove prompt on line paste (cf. last printed char in sfprompt().
bindkey -s $nbsp '^u'

# Report current working directory at each prompt.
# https://codeberg.org/dnkl/foot/wiki#shell-integration
autoload -Uz add-zsh-hook
osc7e() {
	emulate -L zsh # also sets localoptions for us
	setopt extendedglob
	local LC_ALL=C p
	p=$'\e]7;file://'"$HOST"
	p+=${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}
	p+=$'\e\\'
	printf '%s' "$p"
	# set -g allow-passthrough needed
	# "...it’s required to pass OSC 7 message to vt explicitely"
	# https://wiki.9front.org/plumber-vt
	# "What I have in my ~/.tmux.conf is `set-option -s terminal-features[2]
	# *:osc7`. This is slightly wrong but does the job." - sigrid
	[[ -n "$TMUX" ]] && printf '%s' $'\ePtmux;\e'"$p"$'\e\\'
}
osc7(){((ZSH_SUBSHELL))||osc7e}

# Make osc7() execute before each prompt.
# Rc implementation: lib/profile:138:10
add-zsh-hook -Uz precmd osc7
add-zsh-hook precmd precmd_psvar

precmd() { print -Pn "\e]0;%m:%~$\a" }
preexec() { print -Pn "\e]0;%m:%~$ ${~1:gs/%/%%}\a" }

alias cp="cp -i"
alias gl="tog"
alias hg="chg"
alias ivy="ivy-prompt"
alias lc="lc -F"
alias ll="ls -AlF"
alias ls="ls -AF"
alias ltr="ls -AlFtr"
alias mg="mg -n"
alias mv="mv -i"
alias ph="ps auwwx | head"
alias publicip="curl -4 -w '\n' -s http://ifconfig.me"
alias snarf='git --git-dir $HOME/lib/dotfiles --work-tree $HOME'

if [ "$termprog" ] || [ "$winid" ]; then
	# Plumb files instead of starting new editor.
	EDITOR=editinacme
	# Get rid of backspace characters in Unix man output.
	PAGER=nobs
	# Disable the ZSH line editor
	unsetopt zle
	# No paging
	alias git="git --no-pager"
	alias ivy="ivy"
	alias jj="jj --no-pager"
	# Set the current window label using awd (see label(1))
	chpwd() { awd }
	awd
fi

case "$OS" in
linux)
	alias ls="ls -AFv"
	alias pQm="pacman -Qm"
	alias mup="makepkg -o"
	alias mupl="makepkg --printsrcinfo > .SRCINFO"
	alias pclean="makepkg -C"
	alias ph="ps auwwx | sort -rk 3,3 | head"
	alias superctl="systemctl --user"
	;;
openbsd)
	# https://github.com/omar-polo/dotsnew/blob/main/kshrc.lp#L178C2-L178C29
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

	[ $(sysctl -n hw.ncpuonline) -gt 1 ] && MP=".MP" || MP=""
	alias cdg='cd /usr/src/sys/arch/`machine`/compile/GENERIC${MP}'
	alias cvs="opencvs"
	alias mpldc="make port-lib-depends-check"
	alias mup="make update-patches"
	alias mupl="make update-plist"
	alias pclean='make clean="package plist"'
	alias rsync="openrsync"
esac

if command -v kak >/dev/null 2>&1; then
	alias vi="kak"
	alias view="kak -ro"
	EDITOR=kak
else
	EDITOR=/usr/bin/vi
fi

if [[ "$TERM" == "dumb" ]]; then
	unsetopt promptcr
	unfunction osc7 precmd preexec
	# Set prompt so middle-clicking whole line reruns line's command
	# Show last exit code if non-zero
	PROMPT=": %(?..{%?} )$H; "
	RPROMPT=""
fi

felloff() {
	# Override $NAMESPACE (see intro(4)) because $WSYS is not running yet.
	mkdir -p $NAMESPACE
	# Start factotum before secstore so it does not prompt for a password.
	[ -e "$NAMESPACE/font" ] || fontsrv &!
	[ -e "$NAMESPACE/factotum" ] || factotum &!
	[ -e "$NAMESPACE/plumb" ] || plumber &!
	# Plan 9 ssh-agent connects to factotum(4).
	# eval `9 ssh-agent -e`
}

if [ -d "$PLAN9" ]; then felloff; fi

[[ -e ~/.zshrc.local ]] && . ~/.zshrc.local || :
