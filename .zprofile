#!/bin/sh

export PATH
typeset -U path PATH

# pathadd [-P] [PATHS] [-- APPEND_PATHS] - prepend/append PATHS to path
# 08jan2018  +leah+
# 09jan2018  +leah+
# 11aug2021  +leah+  -P to not follow symlinks, useful for Nix
pathadd() {
  setopt LOCAL_OPTIONS EXTENDED_GLOB
  if [[ $1 == -P ]]; then shift; else set -- ${@//#%(#m)*~--/$MATCH:A}; fi
  path=( ${^${@[1,$@[(i)--]-1]}:|path}(N-/)
         $path
         ${^${@[$@[(i)--]+1,-1]}:|path}(N-/) )
}

# paths
export OS=`uname | tr '[:upper:]' '[:lower:]'`
export PLAN9=/usr/local/plan9

[[ -o login ]] && path=()
pathadd -- /usr/{s,}bin /{s,}bin
pathadd /usr/local/{s,}bin
pathadd -- /usr/games /usr/games/bin
pathadd -- $PLAN9/bin $PLAN9/bin/upas
pathadd ~/bin

# personal variables
if [ -x "`command -v emacsclient`" ]; then
	export EDITOR="emacsclient"
else
	export EDITOR=/usr/bin/mg
fi
export BASH_SILENCE_DEPRECATION_WARNING=1
export BROWSER=firefox
export CARGO_HOME=$HOME/.local/share/cargo
export CUDA_CACHE_PATH=$HOME/.cache/nv
export GOT_AUTHOR="demian garcia <d@sfyatee.com>"
export GOTELEMETRY=off
export GOTOOLCHAIN=local
export GS_FONTPATH=$PLAN9/postscript/font
export HISTFILE=/dev/null
export HISTSIZE=500
export LESS=-i
export LESSHISTFILE=/dev/null
export NAMESPACE=/tmp/ns.$USER.:0
export NO_COLOR=1
export PYTHON_HISTORY=/dev/null
export RUSTUP_HOME=$HOME/.local/share/rustup
export SHELL_SESSIONS_DISABLE=1 # Apple Terminal
export XDG_CONFIG_HOME=$HOME/.config

# prepare path enviornment
export PATH=$CARGO_HOME/bin:$PATH:$PLAN9/bin/upas

# plan9
export font=/mnt/font/LucidaGrande/11a/font
export font1=/mnt/font/Hack-Regular/11a/font
export home=$HOME
export secstore=localhost
export user=$USER

# emulate rc shell
set -a	# autoexport
set +o vi	# turn it off

# for use in 9term and acme's win
if [ "$termprog" ] || [ "$winid" ]; then
	export EDITOR=editinacme
	export GH_PROMPT_DISABLED=1
	export PAGER=nobs
fi

# os specific settings
if [ "$OS" = "darwin" ]; then
	export PATH=/usr/local/go/bin:$PATH
	export JJ_CONFIG=$HOME/.config/jj/config.toml
	export font=/mnt/font/LucidaGrande/14a/font
	export font1=/mnt/font/Hack-Regular/14a/font
fi

if [ "$OS" = "darwin" ] || [ "$OS" = "*bsd" ]; then
	export NPROC=`sysctl -n hw.ncpu`
	stty status '^T'
fi

if [ "$OS" = "linux" ]; then
	NPROC=`nproc`
fi

# use $NPROC jobs
MAKEFLAGS=-j$NPROC

if [ "$OS" = "openbsd" ]; then
	export CDPATH=.:/usr/ports:/usr/ports/mystuff
fi

ulimit -c 0	# don't litter
