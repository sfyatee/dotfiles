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
`#comlink` \
curl \
darktable \
firefox \
`#fnott` \
foot \
`#fuzzel` \
gimp \
git \
github-cli \
go \
gopls \
go-tools \
graphviz \
imagemagick \
patchutils \
jq \
jujutsu \
lilypond \
llvm \
lynx \
meson \
mpv \
neovim \
`#niri` \
racket-minimal \
rust-analyzer \
spin \
swayidle \
swaylock \
syncthing \
tailscale \
typst \
unrar \
wev \
`#wlsunset` \
wpa_supplicant \
yt-dlp \
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
	# main $PKGS
	sudo pacman -S --needed --noconfirm $PKGS blueman clang devtools \
	    fastfetch fnott fuzzel gcc-m2 glab libreoffice-fresh mandoc niri openbsd-netcat \
	    pacman-contrib prusa-slicer qemu-full rsync rustup sequoia-sq \
	    sshfs steam tmux ttf-hack wayvnc wlsunset xwayland-satellite

	# aur helper
	if ! command -v paru >/dev/null 2>&1; then
		cd /tmp || exit 1
		if [ ! -d paru ]; then
			git clone https://aur.archlinux.org/paru
		fi
		cd paru || exit 1
		makepkg -fsi --noconfirm
	fi

	# aur $PKGS
	paru -S --needed --noconfirm gameoftrees minivmac tmux-mem-cpu-load \
	    ttf-{apple-emoji,mac-fonts,ms-fonts} yambar-git zig-nightly-bin
	;;
OpenBSD)
	# main $PKGS
	doas pkg_add $PKGS gawk gitlab-cli go-fonts got hack-fonts hare \
	    libreoffice minivmac prusaslicer qemu repology rust sshfs-fuse \
	    syncterm tmux-mem-cpu-load zig
	;;
esac

case "$OS" in
Darwin)
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	;;
Linux)
	systemctl enable --now {mandoc,paccache}.timer
	systemctl --user enable --now {fnott,foot-server,syncthing,xwayland-satellite}.service
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
