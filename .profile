# à la rc
set -a	# autoexport
set +o vi

# The undiscovered country from whose bourn No traveler returns, puzzles the will
OS=`uname -s | tr '[:upper:]' '[:lower:]'`
ARCH=`uname -m | sed 's/x86_64/amd64/'`
PATH=/usr/local/bin:/usr/local/sbin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/X11R6/bin
BIN=$HOME/bin:$HOME/bin/$OS:$HOME/bin/$OS/$ARCH

XDG_CACHE_HOME="$HOME/.cache"
XDG_CONFIG_HOME="$HOME/.config"
XDG_DATA_HOME="$HOME/.local/share"

# offenders
CARGO_HOME=$XDG_DATA_HOME/cargo
CUDA_CACHE_PATH=$XDG_CACHE_HOME/nv
RUFF_CACHE_DIR=$XDG_CACHE_HOME/ruff
RUSTUP_HOME=$XDG_DATA_HOME/rustup

append=/usr/games:/usr/games/bin
prepend=$BIN:$HOME/.local/bin:$HOME/go/bin:$CARGO_HOME/bin
PATH=$prepend:$PATH:$append:.

# Browser used by web(1) and thus plumber.
BROWSER=firefox

LESS=FRXi

CVS_RSH=/usr/bin/ssh

GOT_AUTHOR="demian garcia <dag@demians.org>"

# When I was a child, I used to speak like a child, think like a child,
# reason like a child; when I became a man, I did away with childish
# things.
#
# -rob
NO_COLOR=1
CMAKE_COLOR_MAKEFILE=OFF
AV_LOG_FORCE_NOCOLOR=1

TOG_COLORS=yes
TOG_COLOR_DIFF_MINUS=magenta
TOG_COLOR_DIFF_PLUS=blue
TOG_COLOR_DIFF_CHUNK_HEADER=green
TOG_COLOR_DIFF_META=default
TOG_COLOR_COMMIT=default
TOG_COLOR_AUTHOR=default
TOG_COLOR_DATE=default
TOG_COLOR_REFS_REMOTES=red

TF2="$HOME/.local/share/Steam/steamapps/common/Team Fortress 2/tf/custom"

# Unix means english and 24h clock. but do use UTF-8! and sort like a machine.
LANG=en_US.UTF-8
LC_CTYPE=$LANG
LC_COLLATE=C
LC_TIME=C

DO_NOT_TRACK=true
GOTELEMETRY=off
GOTOOLCHAIN=local
MOZ_USE_XINPUT2=1
_JAVA_AWT_WM_NONREPARENTING=1
PACMAN_AUTH=run0
SYSTEMD_RUN_SHELL_PROMPT_PREFIX=": "

# 福山
LESSHISTFILE=/dev/null
PYTHON_HISTORY=/dev/null

# Prompt
H=`uname -n`
sys=$H
H=${H%%.*}
H=${H%%-*}
PS1=$H'=; '

# Equivalent variables for rc(1).
home=$HOME
prompt="$H=; 	"
user=$LOGNAME

CDPATH=.

case "$OS" in
linux)
	NPROC=`nproc`
	;;
openbsd)
	CDPATH=$CDPATH:/usr/ports:/usr/ports/mystuff
esac

if [ "$OS" != "linux" ]; then
	NPROC=`sysctl -n hw.ncpu`
	stty status '^T'
fi

MAKEFLAGS=-j$NPROC
SAMUFLAGS=-j$NPROC

ulimit -c 0

[ -e ~/.profile.local ] && . ~/.profile.local || :

ENV="$HOME/.kshrc"
