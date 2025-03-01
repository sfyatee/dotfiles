#!/bin/zsh
umask 022

# speed things up
if [[ ! -o interactive ]]; then return; fi

# completion files: use xdg dirs
autoload -Uz compinit	# sinful completion
[ -d "$HOME/.cache"/zsh ] || mkdir -p "$HOME/.cache"/zsh
zstyle ':completion:*' cache-path "$HOME/.cache"/zsh/zcompcache
compinit -d "$HOME/.cache"/zsh/zcompdump-$ZSH_VERSION

# prompt configuration
precmd() { print -Pn "\e]0;%m:%~%%\a" }
preexec() { print -Pn "\e]0;%m:%~%% $1\a" }

# plan9 settings
bindkey -e	# emacs binds
unset HISTFILE	# no
setopt globdots	# hidden files in completion
setopt listtypes	# ls -F in completion
setopt noclobber	# prevent accidents
setopt rcquotes	# plan9-like quoting

# nice things to have
alias acme="acme -a -f $font -F $font1"
alias cp="cp -i"
alias edwood="edwood -a -f $font -F $font1"
alias hg="chg"
alias lc="lc -F"
alias ll="ls -AlF"
alias ls="ls -AF"
alias ltr="ls -AlFtr"
alias m="make"
alias mg="mg -n"
alias mv="mv -i"
alias ph="ps auwwx | head"
alias sam="sam -a"

# for use in 9term and acme's win
if [ "$termprog" ] || [ "$winid" ]; then
	# plumb files instead of starting new editor
	export EDITOR=editinacme

	# disable prompting
	export GH_PROMPT_DISABLED=1

	# turn off zsh line editing
	setopt nozle

	alias git="git --no-pager"
	alias hg="chg --pager=no"
	alias jj="jj --no-pager"

	# sets the current window label using awd (see label(1))
	awd
	chpwd() { awd }
fi

case "$OS" in
linux)
	alias ls="ls -Afv"
	alias pQm="pacman -Qm"
	alias ph="ps auwwx | sort -rk 3,3 | head"
	;;
openbsd)
	alias cvs="opencvs"
	alias mpldc="make port-lib-depends-check"
	alias mup="make update-patches"
	alias mupl="make update-plist"
	alias pclean='make clean="package plist"'
	alias rsync="openrsync"
esac

# no fancy zsh prompt when using dumb terminals
if [[ "$TERM" == "dumb" ]]; then
	# get rid of backspace characters in Unix man output
	export PAGER=nobs

	setopt nopromptcr
	unfunction precmd
	unfunction preexec
	# set prompt so middle-clicking whole line reruns line's command
	# show last exit code if non-zero
	PROMPT=": %(?..{%?} )%m; "
	RPROMPT=""
fi

if [[ -x `command -v jj` ]]; then
	source <(COMPLETE=zsh jj)
fi

# making sure these are running
felloff() {
	mkdir -p $NAMESPACE
	9p stat plumb 2>/dev/null 1>&2 || plumber
}

if [ -d "$PLAN9" ]; then
	felloff
fi
