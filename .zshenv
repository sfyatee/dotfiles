#!/bin/zsh

export PATH
typeset -U path PATH

# world
OS="`uname | tr '[:upper:]' '[:lower:]'`"
ARCH="`uname -m | sed 's/x86_64/amd64/'`"
PATH=/usr/local/bin:/usr/local/sbin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/X11R6/bin
BIN=$HOME/bin:$HOME/bin/$OS:$HOME/bin/$OS/$ARCH
PLAN9=/usr/local/plan9

# XDG
XDG_CACHE_HOME=$HOME/.cache
XDG_CONFIG_HOME=$HOME/.config # OSX is confused

export XDG_CACHE_HOME XDG_CONFIG_HOME

# XDG offenders...
# https://wiki.archlinux.org/title/XDG_Base_Directory#Partial
CARGO_HOME=$HOME/.local/share/cargo
CUDA_CACHE_PATH=$HOME/.cache/nv
RUSTUP_HOME=$HOME/.local/share/rustup

export CARGO_HOME CUDA_CACHE_PATH RUSTUP_HOME

# path
append=/usr/games:/usr/games/bin:$PLAN9/bin:$PLAN9/bin/upas
prepend=$BIN:$HOME/.local/bin:$HOME/go/bin:$CARGO_HOME/bin
PATH=$prepend:$PATH:$append:.

export OS ARCH PATH BIN PLAN9 append prepend

# Browser used by web(1) and thus plumber.
BROWSER=zen

# gameoftrees got(1)
GOT_AUTHOR="demian garcia <d@sfyatee.com>"

# Let gs find the plan9port document fonts.
GS_FONTPATH=$PLAN9/postscript/font

export GOT_AUTHOR GS_FONTPATH

# Unix means english and 24h clock. but do use UTF-8! and sort like a machine.
LANG=en_US.UTF-8
LC_CTYPE=$LANG
LC_COLLATE=C
LC_TIME=C

export LANG LC_CTYPE LC_COLLATE LC_TIME

# less: ok defaults
# https://github.com/jj-vcs/jj/commit/4967bd7
LESS=FRXi

# Google™
GOTELEMETRY=off
GOTOOLCHAIN=local

# When I was a child, I used to speak like a child, think like a child,
# reason like a child; when I became a man, I did away with childish
# things.
#
# -rob
NO_COLOR=1

# run0(1)
PACMAN_AUTH=run0

export LESS GOTELEMETRY GOTOOLCHAIN NO_COLOR PACMAN_AUTH

# The End of History?
HISTFILE=/dev/null
LESSHISTFILE=/dev/null
PYTHON_HISTORY=/dev/null

export HISTFILE LESSHISTFILE PYTHON_HISTORY

# Override $NAMESPACE; X is no more.
NAMESPACE=/tmp/ns.$USER.:0

# Prompt (is almost a no-op in bash).
H=`uname -n`
H=${H%%.*}

# Default font for Plan 9 programs.
font2="/mnt/font/IBMPlexSans/12a/font"
[ -n "$font2" ] && varfont="-f $font2"

font="/mnt/font/IBMPlexMono/12a/font" 
[ -n "$font" ] && fixfont="-F $font"

# Secstore considered harmful?
# https://9fans.topicbox.com/groups/9fans/T2e892f330bc0513b-M168e79b077a072dbe954da15
# https://lists.9front.org/9front/2024/April/1714325162.00
secstore=localhost

# Equivalent variables for rc(1).
home=$HOME
prompt="$H=; 	"
user=$USER

export NAMESPACE H font2 font secstore home prompt user

# Turn *off* vi line editing and
# turn *on* autoexport of environment variables (like in rc).
set +o vi
set -a	# autoexport

# OS specificities.
case "$OS" in
linux)
	BROWSER=nyxt
	NPROC=`nproc`
	;;
openbsd)
	CDPATH=/usr/ports:/usr/ports/mystuff
esac

# https://www.omarpolo.com/post/enjoying-cdpath.html
CDPATH=.:$CDPATH:/usr/local/plan9

if [ "$OS" != "linux" ]; then
	NPROC=`sysctl -n hw.ncpu`
	stty status '^T'
fi

# Set $NPROC for parallelism.
MAKEFLAGS=-j$NPROC
SAMUFLAGS=-j$NPROC

export BROWSER NPROC CDPATH MAKEFLAGS SAMUFLAGS

ulimit -c 0	# don't litter

# Site local config.
[[ -e ~/.zshenv.local ]] && . ~/.zshenv.local || :
