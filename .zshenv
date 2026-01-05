#!/bin/zsh

# world
export OS=$(uname | tr '[:upper:]' '[:lower:]')
export ARCH=$(uname -m | sed 's/x86_64/amd64/')
export PATH=/usr/local/bin:/usr/local/sbin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/X11R6/bin
export BIN=$HOME/bin:$HOME/bin/$OS:$HOME/bin/$OS/$ARCH
export PLAN9=/usr/local/plan9

# XDG
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config # OSX is confused

# XDG offenders...
# https://wiki.archlinux.org/title/XDG_Base_Directory#Partial
export CARGO_HOME=$HOME/.local/share/cargo
export CUDA_CACHE_PATH=$HOME/.cache/nv
export RUSTUP_HOME=$HOME/.local/share/rustup

# path
export append=/usr/games:/usr/games/bin:$PLAN9/bin:$PLAN9/bin/upas
export prepend=$BIN:$HOME/.local/bin:$HOME/go/bin:$CARGO_HOME/bin
export PATH=$prepend:$PATH:$append

# Browser used by web(1) and thus plumber.
export BROWSER=zen

# gameoftrees got(1)
export GOT_AUTHOR="demian garcia <d@sfyatee.com>"

# Let gs find the plan9port document fonts.
export GS_FONTPATH=$PLAN9/postscript/font

# Unix means english and 24h clock. but do use UTF-8! and sort like a machine.
export LANG=en_US.UTF-8
export LC_CTYPE=$LANG
export LC_COLLATE=C
export LC_TIME=C

# less: ok defaults
# https://github.com/jj-vcs/jj/commit/4967bd7
export LESS=-FRXi

# Google™
export GOTELEMETRY=off
export GOTOOLCHAIN=local

# When I was a child, I used to speak like a child, think like a child,
# reason like a child; when I became a man, I did away with childish
# things.
#
# -rob
export NO_COLOR=1

# run0(1)
export PACMAN_AUTH=run0

# The End of History?
export LESSHISTFILE=/dev/null
export PYTHON_HISTORY=/dev/null

# Override $NAMESPACE; X is no more.
export NAMESPACE=/tmp/ns.$USER.:0

# Prompt (is almost a no-op in bash).
export H=`uname -n | sed 's/\..*//'`

# Default font for Plan 9 programs.
typeset -gA _FONTSET
_FONTSET=()

# Populate once
while IFS= read -r line; do
	_FONTSET[$line]=1
done < <(fontsrv -p . 2>/dev/null)

hasfont() {
	(( ${+_FONTSET["$1/"]} ))
}

lookforfont() {
	local family
	for family in "$@"; do
		if hasfont "$family"; then
			print -r -- "/mnt/font/$family/11a/font"
			return 0
		fi
	done
	return 1
}

# sans-serif
font2="$(lookforfont LucidaGrande Geneva GoRegular IBMPlexSans)" && export font2
varfont=(); [[ -n $font2 ]] && varfont=(-f $font2)

# monospace
font="$(lookforfont LucidaGrandeMonoDK Monaco GoMono IBMPlexMono)" && export font
fixfont=(); [[ -n $font  ]] && fixfont=(-F $font)

# Secstore considered harmful?
# https://9fans.topicbox.com/groups/9fans/T2e892f330bc0513b-M168e79b077a072dbe954da15
# https://lists.9front.org/9front/2024/April/1714325162.00
secstore=localhost

# Equivalent variables for rc(1).
export home=$HOME
export prompt="$H=; 	"
export user=$USER

# Add dot to path.
export PATH=$PATH:.

# Turn *off* vi line editing and
# turn *on* autoexport of environment variables (like in rc).
set +o vi
set -a	# autoexport

# OS specificities.
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

# Use $NPROC jobs.
export MAKEFLAGS=-j$NPROC
export SAMUFLAGS=-j$NPROC

ulimit -c 0	# don't litter

# Site local config.
[[ -e ~/.zshenv.local ]] && . ~/.zshenv.local || :
