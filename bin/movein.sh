#!/bin/sh
# simple setup script for Linux/OpenBSD

export OS=$(uname)

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
foot \
fzf \
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
mblaze \
mercurial \
meson \
mpv \
notmuch \
racket-minimal \
restic \
ripgrep \
rust-analyzer \
shellcheck \
spin \
sshfs \
swaybg \
swayidle \
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
		openbsd-netcat \
		pacman-contrib \
		prusa-slicer \
		qemu-full \
		rsync \
		rustup \
		sequoia-sq \
		steam \
		tmux \
		ttf-hack \
		wayvnc
	if ! command -v paru >/dev/null 2>&1; then
		cd /tmp || exit 1
		if [ ! -d paru ]; then
			git clone https://aur.archlinux.org/paru
		fi
		cd paru || exit 1
		makepkg -fsi --noconfirm
	fi
	paru -S --needed --noconfirm \
		comlink \
		drawterm-9front-wl-git \
		gameoftrees \
		google-chrome \
		knfmt \
		minivmac \
		ttf-apple-emoji \
		ttf-mac-fonts \
		ttf-ms-fonts \
		yambar-git
	;;
OpenBSD)
	doas pkg_add $PKGS \
		drawterm \
		firefox \
		gawk \
		gdb \
		gitlab-cli \
		gmake \
		go-fonts \
		got \
		hack-fonts \
		hare \
		hsetroot \
		knfmt \
		libreoffice \
		minivmac \
		prusaslicer \
		qemu \
		repology \
		rust \
		sway \
		xbanish \
		xnotify
	;;
esac

if [ ! -d ~/.git ]; then
	cd ~
	git init
	git remote add origin https://github.com/sfyatee/dotfiles
	git fetch
	git checkout -f master
fi

case "$OS" in
Linux)
	systemctl enable --now {mandoc,paccache}.timer
	systemctl --user enable --now {fnott,foot-server,gammastep,yambar}.service
	;;
esac

u() {
	go install 9fans.net/go/acme/Watch@master
	go install 9fans.net/go/acme/editinacme@master
	go install github.com/anacrolix/torrent/cmd/...@latest
	go install github.com/fzipp/ivy-prompt@latest
	go install github.com/rjkroege/edwood/cmd/win@master
	go install golang.org/x/tools/cmd/bisect@master
	go install robpike.io/ivy@master
	go install upspin.io/cmd/{upspin,cacheserver,upspin-audit,upspinfs}@latest
	rustup update
}
