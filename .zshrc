#!/bin/zsh
umask 022

# speed things up
if [[ ! -o interactive ]]; then return; fi

# zsh settings
unset HISTFILE	# no
setopt globdots	# hidden files in completion
setopt listtypes	# ls -F in completion
setopt noclobber	# prevent accidents
setopt promptsubst	# make `prompt` work
setopt rcquotes	# plan9-like quoting

# this needs to run before compinit installs keybindings.
# 12mar2013  +chris+
bindkey -e	# emacs binds

# completion files: use xdg dirs
autoload -Uz compinit	# unfortunate
[ -d "$HOME/.cache"/zsh ] || mkdir -p "$HOME/.cache"/zsh
zstyle ':completion:*' cache-path "$HOME/.cache"/zsh/zcompcache
compinit -C -d "$HOME/.cache"/zsh/zcompdump-$ZSH_VERSION

# OSC 7
autoload -Uz add-zsh-hook
osc71() {
	emulate -L zsh # also sets localoptions for us
	setopt extendedglob
	local LC_ALL=C p
	p=`printf '\e]7;file://%s%s\e\' $HOST \
	    ${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}`
	# 9front's plumber + vt
	if [[ -n "$TMUX" ]]; then
		# required to pass OSC 7 message to vt explicitely
		print -nr -- "$p" >`tmux display -p '#{client_tty}'`
	else
		print -nr -- "$p"
	fi
}
osc7(){((ZSH_SUBSHELL))||osc71}
add-zsh-hook -Uz chpwd osc7

# prompt - [00:00:00] ~/bin/prompt2.ha %
PROMPT='`prompt2` %# '
precmd() { print -Pn "\e]0;%m:%~%%\a" }
preexec() { print -Pn "\e]0;%m:%~%% $1\a" }

# See: http://man.9front.org/1/emacs
alias 9term="SHELL=hack 9term"
alias acme="SHELL=hack acme -a $varfont $fixfont"
alias edwood="SHELL=hack edwood -a $varfont $fixfont"
alias sam="SHELL=hack sam -a"

# fns
alias cp="cp -i"
alias ck="cmake"
alias hg="chg"
alias ivy="ivy-prompt"
alias jk="just"
alias lc="lc -F"
alias ll="ls -AlF"
alias ls="ls -AF"
alias ltr="ls -AlFtr"
alias m="make"
alias mg="mg -n"
alias me="muon"
alias mv="mv -i"
alias ph="ps auwwx | head"

# For 9term and acme's win.
if [ "$termprog" ] || [ "$winid" ]; then
	# plumb files instead of starting new editor
	export EDITOR=editinacme
	# get rid of backspace characters in Unix man output
	export PAGER=nobs
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
	alias orphrem='run0 pacman -R $(pacman -Qdtq)'
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

# When I say vi I mean kakoune (if it's installed).
if command -v kak >/dev/null 2>&1; then
	alias vi="kak"
	alias view="kak -ro"
	export EDITOR=kak
else
	export EDITOR=/usr/bin/vi
fi

# No fancy zsh prompt in dumb terminals.
if [[ "$TERM" == "dumb" ]]; then
	# disable
	unsetopt promptcr	# carriage return before prompt in zle
	unfunction osc7 precmd preexec
	# set prompt so middle-clicking whole line reruns line's command
	# show last exit code if non-zero
	PROMPT=": %(?..{%?} )%m; "
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
