#!/bin/zsh
umask 022

# speed things up
if [[ ! -o interactive ]]; then return; fi

# plan9 settings
unset HISTFILE	# no
setopt globdots	# hidden files in completion
setopt listtypes	# ls -F in completion
setopt noclobber	# prevent accidents
setopt rcquotes	# plan9-like quoting

# this needs to run before compinit installs keybindings.
# 12mar2013  +chris+
bindkey -e	# emacs binds

# completion files: use xdg dirs
autoload -Uz compinit	# sinful completion
[ -d "$HOME/.cache"/zsh ] || mkdir -p "$HOME/.cache"/zsh
zstyle ':completion:*' cache-path "$HOME/.cache"/zsh/zcompcache
compinit -d "$HOME/.cache"/zsh/zcompdump-$ZSH_VERSION

# OSC 7
autoload -Uz add-zsh-hook
_osc7() {
	emulate -L zsh # also sets localoptions for us
	setopt extendedglob
	local LC_ALL p

	LC_ALL=C
	p=$(printf '\e]7;file://%s%s\e\' $HOST ${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}})
	# 9front's plumber + vt
	if [[ -n "$TMUX" ]]; then
		# required to pass OSC 7 message to vt explicitely
		printf $p > $(tmux display-message -p '#{client_tty}')
	else
		printf $p
	fi
}
osc7(){((ZSH_SUBSHELL))||_osc7}
add-zsh-hook -Uz chpwd osc7

# prompt configuration
precmd() { print -Pn "\e]0;%m:%~%%\a" }
preexec() { print -Pn "\e]0;%m:%~%% $1\a" }

# nice things to have
alias acme="acme -a -f $font -F $font2"
alias cp="cp -i"
alias edwood="edwood -a -f $font -F $font2"
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
	alias hg="chg --pager=no"
	alias jj="jj --no-pager"
	# sets the current window label using awd (see label(1))
	chpwd() { awd }
	awd
fi

# up [|N|@|pat] -- go up 1, N or until basename matches pat many directories
#   just output directory when not used interactively, e.g. in backticks
# 06sep2013  +chris+
# 11oct2017  +leah+  add completion
# 13jul2021  +leah+  add @ for git root
# 12oct2023  +leah+  fix @ when in git root already
up() {
	local op=print
	[[ -t 1 ]] && op=cd
	case "$1" in
	'') up 1;;
	-*|+*) $op ~$1;;
	<->) $op $(printf '../%.0s' {1..$1});;
	@) local cdup; cdup=./$(git rev-parse --show-cdup) && $op $cdup;;
	*) local -a seg; seg=(${(s:/:)PWD%/*})
	local n=${(j:/:)seg[1,(I)$1*]}
	if [[ -n $n ]]; then
		$op /$n
	else
		print -u2 up: could not find prefix $1 in $PWD
		return 1
	fi
	esac
}
_up() { (( $#words > 2 )) || compadd -V segments -- ${(Oas:/:)PWD} }
compdef _up up
alias @='up @'

# revpatch - reverse a patch
# 24may2020  +leah+
revpatch() { interdiff -q $1 /dev/null }

# os specificities
case "$OS" in
linux)
	alias ls="ls -AFv"
	alias orphrem='sudo pacman -R $(pacman -Qdtq)'
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
	PROMPT=": %(?..{%?} )%m; "
	RPROMPT=""
fi

# making sure these are running
felloff() {
	mkdir -p $NAMESPACE
	9p stat plumb 2>/dev/null 1>&2 || plumber
}

if [ -d "$PLAN9" ]; then felloff; fi

# site local config
[[ -e ~/.zshrc.local ]] && . ~/.zshrc.local || :
