#!/bin/sh

if [ -f ~/.xsession.local ]; then
	. ~/.xsession.local
fi

cleanup() {
	echo "cleaning up"
	pkill ssh-agent-card-prompt dbus-daemon redshift picom
	pkill -f "ruby.*sdorfehs-bar"
	rm -f ~/.Xauthority
	rm -f ~/audacious.core
	rm -rf ~/.local/share/Trash
}
trap cleanup INT TERM QUIT

if [ X`uname -s` != X"Linux" ]; then
	MACHINE="`sysctl -n hw.vendor` `sysctl -n hw.product`"
fi

export LANG=en_US.UTF-8

# better two-finger touchpad scrolling
export MOZ_USE_XINPUT2=1
# opengl acceleration
export MOZ_ACCELERATED=1
# force webrender to enable
export MOZ_WEBRENDER=1

xrdb ~/.config/X11/Xresources

xbanish &
tpadnav &
xdimmer -kn -t 10 -s 1 -K &

# run after any icc profile loading
redshift -l 34.10:-118.60 -t 5000:3500 -m randr &

if [ -x /usr/local/bin/progman ]; then
	/usr/local/bin/progman
elif [ -x /usr/local/plan9/bin/rio ]; then
	/usr/local/plan9/bin/rio
elif [ -x /usr/X11R6/bin/fvwm ]; then
	/usr/X11R6/bin/fvwm
else
	/usr/X11R6/bin/xterm
fi

cleanup
