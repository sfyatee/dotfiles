#!/bin/zsh

# enviornment
export PATH
typeset -U path PATH

# pathadd [-P] [PATHS] [-- APPEND_PATHS] - prepend/append PATHS to path
# 08jan2018  +leah+
# 09jan2018  +leah+
# 11aug2021  +leah+  -P to not follow symlinks, useful for Nix
# 24aug2025  +fe!n+  arithmetic with $(( ... ))
pathadd() {
	setopt localoptions extendedglob
	if [[ $1 == -P ]]; then shift; else set -- ${@//#%(#m)*~--/$MATCH:A}; fi
	path=(${^${@[1,$(($@[(i)--]-1))]}:|path}(N-/)
	    $path ${^${@[$(($@[(i)--]+1)),-1]}:|path}(N-/))
}

# world
export OS=$(uname | tr '[:upper:]' '[:lower:]')
export ARCH=$(uname -m | sed 's/x86_64/amd64/')
export PLAN9=/usr/local/plan9

# XDG
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
export CARGO_HOME=$HOME/.local/share/cargo

# path
[[ -o login ]] && path=()
pathadd -- /usr/{s,}bin /{s,}bin
pathadd -- /usr/X11R{6,7}/bin /usr/pkg/{s,}bin
pathadd /usr/local/{s,}bin
pathadd -- /usr/games /usr/games/bin
pathadd -- $PLAN9/bin $PLAN9/bin/upas
pathadd ~/go/bin $CARGO_HOME/bin
pathadd ~/.local/bin
pathadd ~/bin ~/bin/$OS ~/bin/$OS/$ARCH

# browser used by web(1) and thus plumber
export BROWSER=zen

# gameoftrees got(1)
export GOT_AUTHOR="demian garcia <d@sfyatee.com>"

# let gs find the plan9port document fonts
export GS_FONTPATH=$PLAN9/postscript/font

# UNIX means english and 24h clock. but do use UTF-8! and sort like a machine
export LANG=en_US.UTF-8
export LC_CTYPE=$LANG
export LC_COLLATE=C
export LC_TIME=C

# opts
export CUDA_CACHE_PATH=$HOME/.cache/nv
export GOTELEMETRY=off
export GOTOOLCHAIN=local
export LESS=-FRXi
export LESSHISTFILE=/dev/null
export NO_COLOR=1
export PACMAN_AUTH=run0
export PYTHON_HISTORY=/dev/null
export RUSTUP_HOME=$HOME/.local/share/rustup

# override $NAMESPACE; X is no more
export NAMESPACE=/tmp/ns.$USER.:0

# default font for Plan 9 programs
lookforfont() {
	for family in "$@"; do
		font="$(fontsrv -p .)"
		case "$font" in
		*"$family/"*)
			echo "/mnt/font/$family/11a/font"
			return 0
		;;
		esac
	done
	return 1
}

# sans-serif
varfont=""
export font2="$(lookforfont LucidaGrande Geneva GoRegular IBMPlexSans)"
[ -n "$font2" ] && varfont="-f $font2"

# monospace
fixfont=""
export font="$(lookforfont LucidaGrandeMonoDK Monaco GoMono IBMPlexMono)"
[ -n "$font" ] && fixfont="-F $font"

# equivalent variables for rc(1)
export home=$HOME
export secstore=localhost
export user=$USER

# add dot to path
export PATH=$PATH:.

# emulate rc shell
set -a
set +o vi

# os specificities
case "$OS" in
linux)
	export BROWSER=nyxt
	export NPROC=$(nproc)
	;;
openbsd)
	export cdpath=(. /usr/ports /usr/ports/mystuff)
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
