#!/bin/zsh
umask 022

# launch posix aliases and variables
[ -f ~/.config/sh/profile ] && . ~/.config/sh/profile
[ -f ~/.config/sh/aliasrc ] && . ~/.config/sh/aliasrc

# speed things up
if [[ ! -o interactive ]]; then
	return
fi

# insane that they haven't fixed this...
__git_other_files() {
	if [[ "$PWD" = "$HOME" ]]; then
		local -a expl
		_wanted files expl 'other file' _files
	fi
}

# completion files: use xdg dirs
autoload -Uz compinit	# sinful completion
[ -d "$HOME/.cache"/zsh ] || mkdir -p "$HOME/.cache"/zsh
zstyle ':completion:*' cache-path "$HOME/.cache"/zsh/zcompcache
compinit -d "$HOME/.cache"/zsh/zcompdump-$ZSH_VERSION

# osc7 hook
autoload -Uz add-zsh-hook
function _osc7() {
	emulate -L zsh # also sets localoptions for us
	setopt extendedglob
	local LC_ALL=C
	printf '\e]7;file://%s%s\e\' $HOST \
		${PWD//(#m)([^@-Za-z&-;_~])/%${(l:2::0:)$(([##16]#MATCH))}}
}
function osc7() { (( ZSH_SUBSHELL )) || _osc7 }
add-zsh-hook -Uz chpwd osc7

# prompt configuration
PROMPT='`prompt` %% ' # ls ~/bin/$OS/prompt.go
precmd() { print -Pn "\e]0;%m:%~%%\a" }
preexec() { print -Pn "\e]0;%m:%~%% $1\a" }

# plan9 settings
bindkey -e		# emacs binds
setopt globdots	# hidden files in completion
setopt listtypes	# ls -F in completion
setopt noclobber	# prevent accidents
setopt promptsubst	# allows function in PROMPT
setopt rcquotes	# plan9-like quoting

# no fancy zsh prompt when using dumb terminals
if [[ "$TERM" == "dumb" ]]; then
	unsetopt zle
	unsetopt promptcr
	unsetopt promptsubst
	if whence -w osc7 >/dev/null; then
		unfunction osc7
	fi
	if whence -w precmd >/dev/null; then
		unfunction precmd
	fi
	if whence -w preexec >/dev/null; then
		unfunction preexec
	fi
	# set prompt so middle-clicking whole line reruns line's command
	# show last exit code if non-zero
	PROMPT=": %(?..{%?} )%m; "
	RPROMPT=""
fi

if [[ -x `command -v jj` ]]; then
	source <(COMPLETE=zsh jj)
fi
