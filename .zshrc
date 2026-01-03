#!/bin/zsh
umask 022

# speed things up
if [[ ! -o interactive ]]; then return; fi

# plan9 settings
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
autoload -Uz compinit	# sinful completion
[ -d "$HOME/.cache"/zsh ] || mkdir -p "$HOME/.cache"/zsh
zstyle ':completion:*' cache-path "$HOME/.cache"/zsh/zcompcache
compinit -d "$HOME/.cache"/zsh/zcompdump-$ZSH_VERSION

# osc7
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

# prompt - "[%s] %s ", uptime(y, mo, d, h, mi, s), host
# bin/openbsd/prompt2.go
prompt='`prompt2` %v%B%(!.%F{red}.%F{yellow})%# %b%f'
precmd() { print -Pn "\e]0;%m:%~%%\a" }
preexec() { print -Pn "\e]0;%m:%~%% $1\a" }

# fns
alias acme="SHELL=hack acme -a -f $font2 -F $font"
alias cp="cp -i"
alias edwood="SHELL=hack edwood -a -f $font2 -F $font"
alias hg="chg"
alias ivy="ivy-prompt"
alias jk="just"
alias lc="lc -F"
alias ll="ls -AlF"
alias ls="ls -AF"
alias ltr="ls -AlFtr"
alias m="make"
alias mg="mg -n"
alias mu="muon"
alias mv="mv -i"
alias ph="ps auwwx | head"
alias sam="sam -a"

# when i say vi i mean helix (if it's installed)
if [ -x "`which hx`" ]; then
	alias vi="hx"
	export EDITOR=`which hx`
else
	export EDITOR=/usr/bin/vi
fi

# 9term and acme's win
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

# specificities
case "$OS" in
linux)
	alias ls="ls -AFv"
	alias orphrem='doas pacman -R $(pacman -Qdtq)'
	alias pQm="pacman -Qm"
	alias ph="ps auwwx | sort -rk 3,3 | head"
	alias rcctl="systemctl"
	;;
openbsd)
	alias cvs="opencvs"
	alias mpldc="make port-lib-depends-check"
	alias mup="make update-patches"
	alias mupl="make update-plist"
	alias pclean='make clean="package plist"'
	alias rsync="openrsync"
esac

# no fancy zsh prompt in dumb terminals
if [[ "$TERM" == "dumb" ]]; then
	# disable
	unsetopt promptcr	# carriage return before prompt in zle
	unfunction osc7 precmd preexec
	# set prompt so middle-clicking whole line reruns line's command
	# show last exit code if non-zero
	prompt=": %(?..{%?} )%m; "
	RPROMPT=""
fi

# make sure these are running
felloff() {
	mkdir -p $NAMESPACE
	# pal's go port does not fork
	# https://github.com/paul-lalonde/plumber/blob/main/plumber/fsys.go#L148
	9p stat plumb 2>/dev/null 1>&2 || plumber &!
	# fontsrv(4) on OSX and the go port does not fork
	9p stat font 2>/dev/null 1>&2 || fontsrv &!
}

if [ -d "$PLAN9" ]; then felloff; fi

# site local config
[[ -e ~/.zshrc.local ]] && . ~/.zshrc.local || :
