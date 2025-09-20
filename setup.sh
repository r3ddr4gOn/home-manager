#!/bin/sh

set -e
set -u 

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

mkdir -p "${HOME}/.config/nix"
# Enable Nix Flakes
echo "experimental-features = nix-command flakes" > "${HOME}/.config/nix/nix.conf"

# install nix package manager in single user mode: https://nixos.org/download/
if [ -z "$(which nix)" ]
then
	INSTALLER="$(mktemp)"
	curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install > "${INSTALLER}"
	"${INSTALLER}" --no-daemon
	rm -f "${INSTALLER}"

	# load nix environment in current shell
	. "${HOME}/.nix-profile/etc/profile.d/nix.sh"
fi

# Fetch ${ID} and ${VERSION_ID}
. /etc/os-release

# generate local.nix
cat <<- EOF > "${SCRIPT_DIR}/local.nix"
	{
	  username = "$(id -un)";
	}
EOF

# install home-manager and switch to the selected flake
HOMEMANAGER_VERSION="master"
nix shell github:nix-community/home-manager:"${HOMEMANAGER_VERSION}" --command home-manager switch --flake "path:${SCRIPT_DIR}#${ID}-${VERSION_ID}" --show-trace "$@"

if [ "${ID}" = "ubuntu" ]
then
	cat <<- EOF | sudo tee /etc/apparmor.d/nix-electron > /dev/null
		abi <abi/4.0>,
		include <tunables/global>
		profile nix-electron /nix/store/*-electron-*/**/* flags=(unconfined) {
		  userns,
		}
	EOF
fi

echo "DONE!"
