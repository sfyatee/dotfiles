#!/bin/zsh
typeset -U path PATH

# world
BOX=`uname -snm`
OS=`printf '%s\n' "${BOX%% *}" | tr '[:upper:]' '[:lower:]'`
ARCH=`printf '%s\n' "${BOX##* }" | sed 's/x86_64/amd64/'`
PATH=/usr/local/bin:/usr/local/sbin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/X11R6/bin
BIN=$HOME/bin:$HOME/bin/$OS:$HOME/bin/$OS/$ARCH
PLAN9=/usr/local/plan9

# XDG
XDG_CACHE_HOME="$HOME/.cache"
XDG_CONFIG_HOME="$HOME/.config"
XDG_DATA_HOME="$HOME/.local/share"

export XDG_CACHE_HOME XDG_CONFIG_HOME XDG_DATA_HOME

# XDG offenders...
# See: https://wiki.archlinux.org/title/XDG_Base_Directory#Partial
CARGO_HOME=$XDG_DATA_HOME/cargo
CUDA_CACHE_PATH=$HOME/.cache/nv
RUSTUP_HOME=$XDG_DATA_HOME/rustup

export CARGO_HOME CUDA_CACHE_PATH RUSTUP_HOME

# path
append=/usr/games:/usr/games/bin:$PLAN9/bin:$PLAN9/bin/upas
prepend=$BIN:$HOME/.local/bin:$HOME/go/bin:$CARGO_HOME/bin
PATH=$prepend:$PATH:$append:.

# Browser used by web(1) and thus plumber.
BROWSER=firefox

# less: ok defaults
# https://github.com/jj-vcs/jj/commit/4967bd7
LESS=FRXi

# gameoftrees got(1)
GOT_AUTHOR="demian garcia <d@sfyatee.com>"

# Let gs find the plan9port document fonts.
GS_FONTPATH=$PLAN9/postscript/font

# When I was a child, I used to speak like a child, think like a child,
# reason like a child; when I became a man, I did away with childish
# things.
#
# -rob
NO_COLOR=1

# Team Fortress 2
TF2="$HOME/.local/share/Steam/steamapps/common/Team Fortress 2/tf/custom"

# Unix means english and 24h clock. but do use UTF-8! and sort like a machine.
LANG=en_US.UTF-8
LC_CTYPE=$LANG
LC_COLLATE=C
LC_TIME=C

# TheFuture™
# "You MUST have an account, or else..."
# GitHub CLI
DO_NOT_TRACK=true
# Google
GOTELEMETRY=off
GOTOOLCHAIN=local
# LLM Garbage
CLAUDE_CONFIG_DIR=$XDG_CONFIG_HOME/claude
CODEX_HOME=$XDG_CONFIG_HOME/codex
COPILOT_HOME=$XDG_CONFIG_HOME/copilot
OLLAMA_MODELS=$XDG_DATA_HOME/ollama/models

# run0(1)
PACMAN_AUTH=run0
SYSTEMD_RUN_SHELL_PROMPT_PREFIX=": "

# The End of History?
HISTFILE=/dev/null
HISTSIZE=5000
PYTHON_HISTORY=/dev/null

export PYTHON_HISTORY

# Override $NAMESPACE (see intro(4)) because the default on MacOS is too long.
# See: https://github.com/rsc/tmp/blob/master/ssh-namespace-agent/main.go#L446
# This matches the default on other Unices when $WSYS is running.
# See: /usr/local/plan9/src/lib9/getns.c:43
NAMESPACE=/tmp/ns.$LOGNAME.:0

# `hostname -s` is not POSIX!
H=${BOX#* }
H=${H% *}
H=${H%%.*}

# Default font for Plan 9 programs.
font2="/mnt/font/GoRegular/11a/font"
varfont="-f $font2"
font="/mnt/font/GoMono/11a/font"
fixfont="-F $font"

# Secstore considered harmful?
# See: https://9fans.topicbox.com/groups/9fans/T2e892f330bc0513b-M168e79b077a072dbe954da15
# See: https://lists.9front.org/9front/2024/April/1714325162.00
secstore=localhost

# Equivalent variables for rc(1).
home=$HOME
prompt="$H=; 	"
user=$LOGNAME

# Turn *off* vi line editing and
# turn *on* autoexport of environment variables (like in rc).
set +o vi
set -a	# autoexport

# OS specificities.
case "$OS" in
linux)
	NPROC=`nproc`
	;;
openbsd)
	# See: https://www.omarpolo.com/post/enjoying-cdpath.html
	CDPATH=/usr/ports:/usr/ports/mystuff
esac

if [ "$OS" != "linux" ]; then
	NPROC=`sysctl -n hw.ncpu`
	stty status '^T'
fi

# Use $NPROC for parallelism.
MAKEFLAGS=-j$NPROC
SAMUFLAGS=-j$NPROC

export\
	BROWSER\
	DO_NOT_TRACK\
	GOT_AUTHOR\
	GOTELEMETRY\
	GOTOOLCHAIN\
	GS_FONT_PATH\
	HISTFILE\
	LANG\
	LC_CTYPE\
	LC_COLLATE\
	LC_TIME\
	LESS\
	PATH\
	PLAN9\
	PS1\
	NAMESPACE\
	NO_COLOR\
	NPROC\
	MAKEFLAGS\
	SAMUFLAGS\
	TF2\
	CLAUDE_CONFIG_DIR\
	CODEX_HOME\
	COPILOT_HOME\
	OLLAMA_MODELS\
	PACMAN_AUTH\
	SYSTEMD_RUN_SHELL_PROMPT_PREFIX\
	font\
	font2\
	secstore\
	home\
	prompt\
	user\

ulimit -c 0	# don't litter

# Site local config.
[[ -e ~/.zshenv.local ]] && . ~/.zshenv.local || :
