#!/bin/zsh
umask 022

# speed things up
if [[ ! -o interactive ]]; then return; fi

# options
unset HISTFILE	# no
setopt globdots	# hidden files in completion
setopt listtypes	# ls -F in completion
setopt noclobber	# prevent accidents
setopt promptsubst	# make `prompt` work
setopt rcquotes	# plan9-like quoting
PROMPT="$H:%~%(!.#.$) "

# this needs to run before compinit installs keybindings.
# 12mar2013  +chris+
bindkey -e	# emacs binds

# completion files: use xdg dirs
autoload -Uz compinit	# unfortunate
[ -d "$HOME/.cache"/zsh ] || mkdir -p "$HOME/.cache"/zsh
zstyle ':completion:*' cache-path "$HOME/.cache"/zsh/zcompcache
compinit -C -d "$HOME/.cache"/zsh/zcompdump-$ZSH_VERSION

# Change Working Directory (OSC 7)
# See: https://codeberg.org/dnkl/foot/wiki#shell-integration
autoload -Uz add-zsh-hook
osc71() {
	emulate -L zsh # also sets localoptions for us
	setopt extendedglob
	local LC_ALL=C p
	p=$'\e]7;file://'"$HOST"
	p+=${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}
	p+=$'\e\\'
	# Needs set -g allow-passthrough on to work.
	# See: https://github.com/tmux/tmux/wiki/FAQ
	# "...it’s required to pass OSC 7 message to vt explicitely"
	# See: https://wiki.9front.org/plumber-vt
	if [[ -n "$TMUX" ]]; then
		printf '%s' $'\ePtmux;\e'"$p"$'\e\\'
	else
		printf '%s' "$p"
	fi
}
osc7(){((ZSH_SUBSHELL))||osc71}
add-zsh-hook -Uz chpwd osc7

# Sets the label of the current X terminal window.
precmd() { print -Pn "\e]0;$H:%~$\a" }
preexec() { print -Pn "\e]0;$H:%~$ ${~1:gs/%/%%}\a" }

alias cp="cp -i"
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
alias snarf='git --git-dir="$DOTS" --work-tree="$HOME"'

gl() {
	got log "$@" | less
}

# http://man.9front.org/1/emacs
alias 9term="SHELL=hack $PLAN9/bin/9term"
alias acme="SHELL=hack $PLAN9/bin/acme -a $varfont $fixfont"
alias edwood="SHELL=hack edwood -a $varfont $fixfont"
alias sam="SHELL=hack $PLAN9/bin/sam -a"

# For 9term and acme's win.
if [ "$termprog" ] || [ "$winid" ]; then
	# plumb files instead of starting new editor
	EDITOR=editinacme
	# get rid of backspace characters in Unix man output
	PAGER=nobs
	# disable
	unsetopt zle	# zsh line editor
	# no paging
	alias git="git --no-pager"
	alias ivy="ivy"
	alias jj="jj --no-pager"
	# sets the current window label using awd (see label(1))
	chpwd() { awd }
	awd
fi

# revpatch - reverse a patch
# 24may2020  +leah+
revpatch() { interdiff -q $1 /dev/null }

# OS specificities.
case "$OS" in
linux)
	alias ls="ls -AFv"
	alias pQm="pacman -Qm"
	alias ph="ps auwwx | sort -rk 3,3 | head"
	;;
openbsd)
	# check shared libs version
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
	alias cvs="opencvs"
	alias mpldc="make port-lib-depends-check"
	alias mup="make update-patches"
	alias mupl="make update-plist"
	alias pclean='make clean="package plist"'
	alias rsync="openrsync"
esac

# When I say vi I mean kakoune (if it's installed).
if command -v kak >/dev/null 2>&1; then
	alias vi="kak"
	alias view="kak -ro"
	EDITOR=kak
else
	EDITOR=/usr/bin/vi
fi

# No fancy zsh prompt in dumb terminals.
if [[ "$TERM" == "dumb" ]]; then
	# disable
	unsetopt promptcr	# carriage return before prompt in zle
	unfunction osc7 precmd preexec
	# set prompt so middle-clicking whole line reruns line's command
	# show last exit code if non-zero
	PROMPT="%(?..{%?} )%m:$ "
	RPROMPT=""
fi

# Make sure these are running.
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

# Site local config.
[[ -e ~/.zshrc.local ]] && . ~/.zshrc.local || :
