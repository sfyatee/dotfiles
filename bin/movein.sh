#!/bin/sh
# simple setup script for Linux/OpenBSD

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
foot \
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
mblaze \
meson \
mpv \
notmuch \
restic \
rust-analyzer \
spin \
swayidle \
swaylock \
syncthing \
tailscale \
typst \
unrar \
vim \
wev \
wpa_supplicant \
yt-dlp \
zig \
zsh \
"
export OS=`uname`
case "$OS" in
Linux)
	sudo pacman -S --needed --noconfirm $PKGS \
		blueman \
		clang \
		fastfetch \
		fnott \
		fuzzel \
		gammastep \
		gcc-m2 \
		glab \
		libreoffice-fresh \
		mandoc \
		niri \
		nyxt \
		openbsd-netcat \
		pacman-contrib \
		prusa-slicer \
		qemu-full \
		rsync \
		rustup \
		sequoia-sq \
		sshfs \
		steam \
		tmux \
		ttf-hack \
		wayvnc \
  		xwayland-satellite
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
		drawterm-9front-wl-git \
		knfmt \
		minivmac \
		#tlsclient-git \
		ttf-apple-emoji \
		ttf-mac-fonts \
		ttf-ms-fonts \
		w3m-rkta-git \
		yambar-git
	;;
OpenBSD)
	doas pkg_add $PKGS \
		drawterm \
		gawk \
		gitlab-cli \
		go-fonts \
		got \
		hack-fonts \
		hare \
		knfmt \
		libreoffice \
		minivmac \
		prusaslicer \
		qemu \
		repology \
		rust \
		rxvt-unicode \
		sshfs-fuse \
		syncterm \
		tpadnav \
		w3m \
		xbanish \
		xdimmer \
		xdotool \
		xfe \
		xnotify \
		xosd
	;;
esac
export RUSTUP_HOME=$HOME/.local/share/rustup
if [ "$OS" = "Darwin" ] && [ ! -d $RUSTUP_HOME ]; then
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
if [ ! -d ~/.jj ]; then
	cd ~
	jj git init
	jj git remote add origin https://github.com/sfyatee/dotfiles
	jj git fetch
	jj new master@origin
fi
case "$OS" in
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
