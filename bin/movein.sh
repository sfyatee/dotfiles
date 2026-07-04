#!/bin/sh

export OS=$(uname)
export CARGO_HOME=~/.local/share/cargo
export GOTELEMETRY=off
export GOTOOLCHAIN=local
export RUSTUP_HOME=~/.local/share/rustup

# remove cruft installed by default in openbsd
rm -f ~/.cshrc \
	~/.login \
	~/.mailrc \
	~/.profile \
	~/.Xdefaults \
	~/.cvsrc

case "$OS" in
Linux)
	AUTH="run0"
	unfortunate
	;;
OpenBSD)
	AUTH="doas"
	doas pkg_add -l $HOME/bin/openbsd/movein.txt
	;;
esac

# https://9fans.github.io/plan9port/
if [ ! -d /usr/local/plan9 ]; then
	$AUTH mkdir -p /usr/local/plan9
	$AUTH chgrp $(id -gn) /usr/local/plan9
	$AUTH chmod g+rwx /usr/local/plan9
	$AUTH chown $(id -un):$(id -gn) /usr/local/plan9
	git clone https://github.com/9fans/plan9port.git /usr/local/plan9
	cd /usr/local/plan9; ./INSTALL
else
	cd /usr/local/plan9; git pull; ./INSTALL
fi

unfortunate() {
	if [ -z "$(rustup toolchain list | grep -v 'default')" ]; then
		rustup toolchain install stable
	else
		rustup update
	fi
	if ! lsmod | grep -q 9p; then
		run0 mkdir -p /etc/modules-load.d/
		echo 9p | run0 tee -a /etc/modules-load.d/9p.conf > /dev/null
	fi
	if ! command -v yay >/dev/null 2>&1; then
		git clone https://aur.archlinux.org/yay /tmp/yay
		cd /tmp/yay || exit 1; makepkg -fsi --noconfirm
	fi
}

cd ~

cargo install --git https://github.com/bergercookie/asm-lsp asm-lsp
go install github.com/fzipp/ivy-prompt@latest
go install github.com/hdonnay/wercsrv@master
go install github.com/rjkroege/edwood/cmd/win@master
go install robpike.io/ivy@master
go install git.sr.ht/~gzj/werc-quickstart@latest
