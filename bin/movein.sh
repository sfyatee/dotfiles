#!/bin/sh

OS=$(uname -s)
PLAN9=/usr/local/plan9
CARGO_HOME=$HOME/.local/share/cargo
GOTELEMETRY=off
GOTOOLCHAIN=local
RUSTUP_HOME=$HOME/.local/share/rustup

export OS PLAN9 CARGO_HOME GOTELEMETRY GOTOOLCHAIN RUSTUP_HOME

snarf() {
	git --git-dir=$HOME/lib/dotfiles --work-tree=$HOME "$@"
}

case $OS in
Linux)
	AUTH=run0
	export PACMAN_AUTH=$AUTH
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
	if [ ! -d "$PLAN9" ]; then
		$AUTH mkdir -p "$PLAN9"
		# set the correct owner group
		$AUTH chown $(id -un):$(id -gn) "$PLAN9"
		git clone https://github.com/9fans/plan9port "$PLAN9"
	else
		git pull -C "$PLAN9" pull --ff-only
	fi
	(
		cd "$PLAN9"
		./INSTALL
	) || exit
	$AUTH install -m 755 "$PLAN9/bin/rc" /bin/rc
}

utilis() {
	cargo install --git https://github.com/bergercookie/asm-lsp asm-lsp
	go install 9fans.net/acme-lsp/cmd/L@master
	go install 9fans.net/acme-lsp/cmd/acme-lsp@master
	go install 9fans.net/acme-lsp/cmd/acme-focused@master
	go install github.com/fzipp/ivy-prompt@latest
	go install github.com/hdonnay/wercsrv@master
	go install github.com/rjkroege/edwood/cmd/win@master
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


