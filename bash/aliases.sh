function e() {
	if [ $# -eq 1 ] && [ -f "$1" ] && ! [ -w "$1" ]
	then
		sudo hx "$1"
	else
		hx "$@"
	fi
}

alias ls='eza'
alias ll='eza -la'

alias lg='lazygit'
alias bb='bitbake'

alias g='git'

alias cdgr='cd $(git rev-parse --show-toplevel || echo '.')'

# cd to workspace
cdw() {
	local SELECTION="$(fd -d 1 --format '{/}' . "${WORKSPACES_ROOT}" | sk -1)"
	cd "${WORKSPACES_ROOT}/${SELECTION}"
	WORKSPACE_ROOT="${PWD}"
}

# cd anywhere inside workspace
cdf() {
	# Update workspace if changed by not using cdw
	if [[ "$(realpath --relative-base="${WORKSPACE_ROOT}" "${PWD}")" = /* ]]
	then
		local CURRENT_DIR_REL_WSR="$(realpath --relative-base="${WORKSPACES_ROOT}" "${PWD}")"
		if [[ "${CURRENT_DIR_REL_WSR}" = /* ]]
		then
			unset WORKSPACE_ROOT
		else
			WORKSPACE_ROOT="${WORKSPACES_ROOT}/$(echo "${CURRENT_DIR_REL_WSR}" | sed -r 's|^([^/]*)/.*$|\1|')"
		fi
	fi

	if [ -z "${WORKSPACE_ROOT}" ]
	then
		echo "Error: Not in a workspace! Use cdw first!"
	fi

	local TARGET_DIR="$(cd "${WORKSPACE_ROOT}"; fd -u -t d . | sk)"
	cd "${TARGET_DIR}"
}

# cd anywhere from cwd downwards
cd.() {
	local TARGET_DIR="$(fd -u -t d . | sk)"
	cd "${TARGET_DIR}"
}

# cd to any parent from cwd
cd..() {
	local TARGET_DIR="$(_cd.. | sk)"
	cd "${TARGET_DIR}"
}

_cd..() {
	CUR_PATH="$(dirname "${PWD}")"
	while [ "${CUR_PATH}" != "/" ]
	do
		echo "${CUR_PATH}"
		CUR_PATH="$(dirname "${CUR_PATH}")"
	done
	echo "/"
}

# Yocto
ycb() {
    bitbake -c cleansstate "$1" && bitbake "$@"
}

# home-manager
hmrs() {
	(
		cd ${HOME}/.config/home-manager
		home-manager switch --flake "path:.#nixos-25.05" --show-trace "$@"
	)
}
alias hme="(cd ${HOME}/.config/home-manager; hx .)"

