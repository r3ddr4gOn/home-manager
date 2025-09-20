#!/bin/sh

set -e
set -u 

CMD="$1"
shift

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# Fetch ${ID} and ${VERSION_ID}
. /etc/os-release

if [ "${CMD}" = "--apply" ]
then
	echo "Applying changes to Software and Configs"
	home-manager switch --flake "path:${SCRIPT_DIR}#${ID}-${VERSION_ID}" "$@"
elif [ "${CMD}" = "--refresh" ]
then
	echo "Refreshing Nix, Home-Manager and Software"
	nix-env --install --file '<nixpkgs>' --attr nix cacert -I nixpkgs=channel:nixpkgs-unstable
	nix flake update --flake "${SCRIPT_DIR}"
	home-manager switch --flake "${SCRIPT_DIR}#${ID}-${VERSION_ID}" "$@"

	# post setup steps
	helix -g fetch
	helix -g build
else
	echo "Installing Nix, Home-Manager and Software"
	# Enable Nix Flakes
	mkdir -p "${HOME}/.config/nix"
	echo "experimental-features = nix-command flakes" > "${HOME}/.config/nix/nix.conf"

	# generate local.nix
	cat <<- EOF > "${SCRIPT_DIR}/local.nix"
		{
		  username = "${USER}";
		}
	EOF

	# install nix package manager in single user mode: https://nixos.org/download/
	installer="$(mktemp)"
	curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install > "${INSTALLER}"
	"${INSTALLER}" --no-daemon
	rm -f "${INSTALLER}"

	# load nix environment in current shell
	. "${HOME}/.nix-profile/etc/profile.d/nix.sh"

	# install home-manager and switch to the selected flake
	nix shell github:nix-community/home-manager:"${HOMEMANAGER_VERSION}" --command home-manager switch --flake "path:${SCRIPT_DIR}#${ID}-${VERSION_ID}" "$@"

	# register hyprland in login managers
	cat <<- EOF > /usr/share/wayland-sessions/hyprland.desktop
		[Desktop Entry]
		Name=Hyprland
		Comment=An intelligent dynamic tiling Wayland compositor
		Exec=/home/antonfr/.nix-profile/bin/Hyprland
		Type=Application
	EOF

	# allow hyprlock to authenticate
	cat <<- EOF > /etc/pam.d/hyprlock
		auth include login
	EOF

	# add hyprpolkitagent systemd service + dbus service
	cat <<- EOF > /usr/share/dbus-1/services/org.hyprland.hyprpolkitagent.service
		[D-BUS Service]
		Name=org.hyprland.hyprpolkitagent
		Exec=${HOME}/.nix-profile/libexec/hyprpolkitagent
		SystemdService=hyprpolkitagent.service
	EOF

	cat <<- EOF > ${HOME}/.config/systemd/user/hyprpolkitagent.service
		[D-BUS Service]
		Name=org.hyprland.hyprpolkitagent
		Exec=${HOME}/.nix-profile/libexec/hyprpolkitagent
		SystemdService=hyprpolkitagent.service
	EOF
fi
