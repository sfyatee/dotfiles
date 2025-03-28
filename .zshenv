#!/bin/zsh

# enviornment
export PATH
typeset -U path PATH

# pathadd [-P] [PATHS] [-- APPEND_PATHS] - prepend/append PATHS to path
# 08jan2018  +leah+
# 09jan2018  +leah+
# 11aug2021  +leah+  -P to not follow symlinks, useful for Nix
pathadd() {
	setopt localoptions extendedglob
	if [[ $1 == -P ]]; then shift; else set -- ${@//#%(#m)*~--/$MATCH:A}; fi
	path=(${^${@[1,$@[(i)--]-1]}:|path}(N-/) $path ${^${@[$@[(i)--]+1,-1]}:|path}(N-/))
}

# world
export OS=`uname | tr '[:upper:]' '[:lower:]'`
export ARCH=`uname -m`
export PLAN9=/usr/local/plan9
export CVS_RSH=/usr/bin/ssh # {Open,Net}BSD

# browser used by web(1) and thus plumber
export BROWSER=firefox

# got(1)
export GOT_AUTHOR="demian garcia <dag@sfyatee.com>"

# opts
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export GOTELEMETRY=off
export GOTOOLCHAIN=local
export HOMEBREW_NO_ANALYTICS=1
export LESS=-i
export LESSHISTFILE=/dev/null
export NO_COLOR=1
export POWERSHELL_TELEMETRY_OPTOUT=1
export PYTHON_HISTORY=/dev/null
export SHELL_SESSIONS_DISABLE=1 # Apple Terminal
export XDG_CONFIG_HOME=$HOME/.config # for Apple

# let gs find the plan9port document fonts
export GS_FONTPATH=$PLAN9/postscript/font

# xdg
export CARGO_HOME=$HOME/.local/share/cargo
export CUDA_CACHE_PATH=$HOME/.cache/nv
export JJ_CONFIG=$XDG_CONFIG_HOME/jj/config.toml # for Apple
export RUSTUP_HOME=$HOME/.local/share/rustup

# path
[[ -o login ]] && path=()
pathadd -P ~/.nix-profile/bin
pathadd -- /usr/{s,}bin /{s,}bin
pathadd /usr/local/{s,}bin
pathadd -- /usr/games /usr/games/bin
pathadd -P -- /nix/var/nix/profiles/default/bin
pathadd -P /run/wrappers/bin
pathadd -- $PLAN9/bin $PLAN9/bin/upas
pathadd ~/go/bin $CARGO_HOME/bin
pathadd ~/.local/bin
pathadd ~/bin ~/bin/$OS ~/bin/$OS/$ARCH

# UNIX means english and 24h clock. but do use UTF-8! and sort like a machine
export LANG=en_US.UTF-8
export LC_CTYPE=$LANG
export LC_COLLATE=C
export LC_TIME=C

# override $NAMESPACE; X is not running
export NAMESPACE=/tmp/ns.$USER.:0

# default font for Plan 9 programs
export font=/mnt/font/LucidaGrande/11a/font
export font1=/mnt/font/Hack-Regular/11a/font

# equivalent variables for rc(1)
export home=$HOME
export secstore=localhost
export user=$USER

# emulate rc shell
set -a
set +o vi

# os specificities
case "$OS" in
darwin)
	eval "$(/opt/homebrew/bin/brew shellenv)"
	;;
linux)
	export NPROC=`nproc`
	;;
openbsd)
	export CDPATH=.:/usr/ports:/usr/ports/mystuff
esac

if [ "$OS" != "linux" ]; then
	export NPROC=`sysctl -n hw.ncpu`
	stty status '^T'
fi

# use $NPROC jobs
export MAKEFLAGS=-j$NPROC
export SAMUFLAGS=-j$NPROC

ulimit -c 0	# don't litter

# site local config
[[ -e ~/.zshenv.local ]] && . ~/.zshenv.local || :
