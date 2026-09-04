#!/bin/sh

# remove cruft installed by default in openbsd
rm -f ~/.cshrc \
	~/.login \
	~/.mailrc \
	~/.profile \
	~/.Xdefaults \
	~/.cvsrc

slop() {
	RUSTUP_HOME=$HOME/.local/share/rustup; export RUSTUP_HOME
	if [ -z "$(rustup toolchain list | grep -v 'default')" ]; then
		rustup toolchain install stable
	else
		rustup update
	fi
	if ! lsmod | grep -q 9p; then
		$AUTH mkdir -p /etc/modules-load.d/
		echo 9p | $AUTH tee -a /etc/modules-load.d/9p.conf > /dev/null
	fi
	if ! command -v yay >/dev/null 2>&1; then
		git clone https://aur.archlinux.org/yay /tmp/yay
		cd /tmp/yay || exit 1; makepkg -fsi --noconfirm
	fi
}

snarf() {
	git --git-dir=$HOME/lib/dotfiles --work-tree=$HOME "$@"
}

if [ -d $DOTFILES ]; then
	snarf remote set-url origin git@github.com:sfyatee/dotfiles.git
	snarf fetch --prune origin
else
	mkdir -p ~/lib
	git clone --bare https://github.com/sfyatee/dotfiles $HOME/lib/dotfiles
fi
snarf config status.showUntrackedFiles no
snarf checkout -f master

case "$(uname)" in
Linux)
	PACMAN_AUTH=run0; export PACMAN_AUTH
	AUTH="run0"
	slop
	# yay --noconfirm -S --needed - < ~/bin/linux/movein.txt
	;;
OpenBSD)
	AUTH="doas"
	$AUTH pkg_add -l ~/bin/openbsd/movein.txt
	;;
esac

# Plan 9 userspace ported to Unix.
# See: https://9fans.github.io/plan9port/
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
$AUTH install -m 755 /usr/local/plan9/bin/rc /bin/rc

# utilis
CARGO_HOME=$HOME/.local/share/cargo; export CARGO_HOME
cargo install --git https://github.com/bergercookie/asm-lsp asm-lsp

GOTELEMETRY=off; export GOTELEMETRY
GOTOOLCHAIN=local; export GOTOOLCHAIN
go install 9fans.net/acme-lsp/cmd/L@master
go install 9fans.net/acme-lsp/cmd/acme-lsp@master
go install 9fans.net/acme-lsp/cmd/acmefocused@master
go install github.com/fzipp/ivy-prompt@latest
go install github.com/hdonnay/wercsrv@master
go install github.com/rjkroege/edwood/cmd/win@master
go install robpike.io/ivy@master
go install rsc.io/cmd/jj-sink@latest
go install rsc.io/grepdiff@master
go install git.sr.ht/~gzj/werc-quickstart@latest
go install git.sr.ht/~mkhl/xplor@master

# 2007
TF2="$HOME/.local/share/Steam/steamapps/common/Team Fortress 2/tf/custom"
if [ -d "$TF2" ]; then
	cd "$TF2"

	# hud
	if [ ! -d "budhud" ]; then
		git clone https://github.com/rbjaxter/budhud.git
	else
		git -C pull budhud
	fi

	budopts='budhud/#customization'
	enabled="$budopts/_enabled"
	# misc.
	# cp -r "$budopts"/bh_player_uicentered/ "$enabled"
	cp "$budopts"/bh_chat_lowerleft.res "$enabled"
	cp "$budopts"/bh_tournamentpanels_lowered.res "$enabled"
	cp "$budopts"/bh_menu_hide{news,stats}.res "$enabled"
	# cross
	cp "$budopts"/bh_player_healthcross.res "$enabled"
	cp -r "$budopts"/bh_targetid_healthcross/ "$enabled"
	cp "$budopts"/bh_animate_foreground.txt "$enabled"
	rm "$enabled"/bh_targetid_depleting.res
	# medic
	cp "$budopts"/bh_uber_percentagenearcrosshair.res "$enabled"
	cp "$budopts"/bh_medic_rainbowcharge.txt "$enabled"
fi


