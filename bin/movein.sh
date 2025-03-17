#!/bin/sh
# simple setup script for Linux/OpenBSD

export OS=`uname`

rm -f ~/.cshrc \
	~/.login \
	~/.mailrc \
	~/.profile \
	~/.Xdefaults \
	~/.cvsrc

export PKGS=" \
aerc \
blender \
cmake \
curl \
darktable \
firefox \
fnott \
foot \
fuzzel \
gimp \
git \
github-cli \
go \
gopls \
go-tools \
graphviz \
imagemagick \
jq \
jujutsu \
lilypond \
llvm \
lynx \
meson \
mpv \
neovim \
niri \
racket-minimal \
restic \
rust-analyzer \
spin \
swayidle \
swaylock \
syncthing \
tailscale \
typst \
unrar \
wev \
wlsunset \
wpa_supplicant \
yt-dlp \
zig \
zsh \
"

if [ ! -d ~/.git ]; then
        cd ~
        git init
        git remote add origin https://github.com/sfyatee/dotfiles
        git fetch
        git checkout -f master
fi

case "$OS" in
Linux)
	sudo pacman -S --needed --noconfirm $PKGS
	sudo pacman -S --needed --noconfirm - < ~/bin/linux/prog.txt
	if ! command -v paru >/dev/null 2>&1; then
		cd /tmp || exit 1
		if [ ! -d paru ]; then
			git clone https://aur.archlinux.org/paru
		fi
		cd paru || exit 1
		makepkg -fsi --noconfirm
	fi
	paru -S --needed --noconfirm \
		comlink-git \
		gameoftrees \
		minivmac \
		tmux-mem-cpu-load \
		ttf-apple-emoji \
		ttf-mac-fonts \
		ttf-ms-fonts \
		yambar-git
	;;
OpenBSD)
	doas pkg_add $PKGS
	doas pkg_add -l ~/bin/openbsd/prog.txt
	;;
esac

case "$OS" in
Darwin)
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	;;
Linux)
	systemctl enable --now {mandoc,paccache}.timer
	systemctl --user enable --now {foot-server,gammastep,syncthing,xwayland-satellite}.service
	;;
esac

u() {
	go install 9fans.net/go/acme/Watch@master
	go install 9fans.net/go/acme/editinacme@master
	go install github.com/anacrolix/torrent/cmd/...@latest
	go install github.com/rjkroege/edwood/cmd/win@master
	go install golang.org/x/tools/cmd/bisect@master
	go install robpike.io/ivy@master
}
