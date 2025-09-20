e() {
	if [ $# -eq 1 ] && [ -f "$1" ] && ! [ -w "$1" ]
	then
		sudo hx "$1"
	else
		hx "$@"
	fi
}

alias u="cd .."
alias uu="cd ../.."

alias ls='eza'
alias ll='eza -la'

alias lg='lazygit'
alias bb='bitbake'

alias g='git'

alias cdgr='cd $(git rev-parse --show-toplevel || echo '.')'

# initialize a workspace in the current directory for use with other cd and zoxide aliases below
ws_init(){
	if [ $# != 1 ]
	then
		echo "Error: Please provide the WORKSPACE_TAG for this workspace as argument."
		return 1
	fi

	# Note: Make sure to globally git ignore .envrc to avoid untracked files.
	#       Globally ignoring does not work if there already is a staged .envrc, but ok for now.
	cat <-- EOF >> .envrc
		export WORKSPACE_ROOT="${PWD}"
		export WORKSPACE_TAG="$1"
	EOF
}

# cd to workspace
# TODO: Use global database instead of simple directory layout
cdtw() {
	local SELECTION="$(fd -d 1 --format '{/}' . "${WORKSPACES_ROOT}" | sk -1)"
	cd "${WORKSPACES_ROOT}/${SELECTION}"
	WORKSPACE_ROOT="${PWD}"
}

# cd anywhere inside workspace
cdw() {
	if [ -z "${WORKSPACE_ROOT}" ]
	then
		echo "Error: Not in a workspace! cd to a workspace first (when using direnv) or set WORKSPACE_ROOT manually!"
		return 1
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
		# re-generate local.nix file for the current user
		cat <<- EOF > local.nix
		{
		  username = "$(id -un)";
		}
		EOF

		# Fetch ${ID} and ${VERSION_ID}
		. /etc/os-release
		home-manager switch --flake "path:.#${ID}-${VERSION_ID}" --show-trace "$@"
	)
}
alias hme='(builtin cd ${HOME}/.config/home-manager; hx .)'
alias hmu='(builtin cd ${HOME}/.config/home-manager; nix-env --install --file "<nixpkgs>" --attr nix cacert -I nixpkgs=channel:nixpkgs-unstable && nix flake update --flake "path:.") && hmrs'

# zoxide
cd() {
	local TARGET_DIR="$1"
	if [ $# = 0 ]
	then
		builtin cd
	elif [ -z "${WORKSPACE_ROOT}" ] || [ -z "${WORKSPACE_TAG}" ]
	then
		zoxide add "${TARGET_DIR}" > /dev/null 2>&1 # I'm no fan of the default _zoxide_z function
		builtin cd "${TARGET_DIR}"
	else
		# Note: not yet supported by zoxide
		zoxide add --relative-to "${WORKSPACE_ROOT}" "${TARGET_DIR}" > /dev/null 2>&1
		builtin cd "${TARGET_DIR}"
	fi
}
alias z="__zoxide_zi"
alias z.='__zoxide_zi --base-directory "${PWD}"'
# Note: not yet supported by zoxide
alias zw='__zoxide_zi --relative-from "${WORKSPACE_ROOT}"'
