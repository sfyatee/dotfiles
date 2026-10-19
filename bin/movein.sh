#!/bin/sh

OS=$(uname -s)

CARGO_HOME=$HOME/.local/share/cargo
DOTFILES=$HOME/lib/dotfiles
GOTELEMETRY=off
GOTOOLCHAIN=local
RUSTUP_HOME=$HOME/.local/share/rustup

export OS CARGO_HOME DOTFILES GOTELEMETRY GOTOOLCHAIN PACMAN_AUTH RUSTUP_HOME

snarf() {
	git --git-dir $HOME/lib/dotfiles --work-tree $HOME "$@"
}

case $OS in
Linux)
	AUTH=run0
	PACMAN_AUTH=$AUTH
	;;
OpenBSD)
	AUTH=doas
	;;
esac

slop() {
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

felloff(){
}

utilis() {
	cargo install --git https://github.com/bergercookie/asm-lsp asm-lsp
	go install github.com/fzipp/ivy-prompt@latest
	go install github.com/hdonnay/wercsrv@master
	go install github.com/thimc/walk@latest
	go install robpike.io/ivy@master
	go install rsc.io/cmd/jj-sink@latest
	go install rsc.io/grepdiff@master
	go install git.sr.ht/~gzj/werc-quickstart@latest
	go install git.sr.ht/~mkhl/xplor@master
}

case ${1-} in
felloff)
	felloff
	;;
utilis)
	utilis
	;;
'')
	case $OS in
	Linux)
		slop
		;;
	OpenBSD)
		$AUTH pkg_add git
		rm -f \
			"$HOME/.cshrc" \
			"$HOME/.login" \
			"$HOME/.mailrc" \
			"$HOME/.profile" \
			"$HOME/.Xdefaults" \
			"$HOME/.cvsrc"
		;;
	esac

	if [ -d "$DOTFILES" ]; then
		snarf remote set-url origin git@github.com:sfyatee/dotfiles.git
		snarf fetch --prune origin
	else
		mkdir -p "$HOME/lib"
		git clone --bare \
			https://github.com/sfyatee/dotfiles \
			"$DOTFILES"
	fi

	snarf config status.showUntrackedFiles no
	snarf checkout -f master

	felloff
	utilis
	;;
*)
	echo "usage: $0 [felloff|utilis]" >&2
	exit 1
	;;
esac

games() {
	TF2="$HOME/.local/share/Steam/steamapps/common/Team Fortress 2/tf/custom"
	if [ -d "TF2" ]; then
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
}
