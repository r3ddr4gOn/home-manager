# My Home Manager Configurations for various systems I use

## Installation

This installs the Nix package-manager, the home-manager module and all software defined in the flake for the current system.
This requires sudo rights to setup `/nix`.

It will also write all defined configuration files to your home directory.
In case of a conflict it aborts and lists conflicting files, but make a backup beforehand anyway :).

```sh
cd # Home
git clone https://github.com/r3ddr4gOn/home-manager.git .config/home-manager
.config/home-manager/setup.sh

# reboot to make sure the environment (e.g. PATH) is set up correctly.
```

## Post Install Steps

### Setup home-manager zsh as default shell

In most cases just using the distribution zsh binary should be fine.
If you want the nix version, you may need to add `${HOME}/.nix-profile/bin/zsh` (expanded) to the `/etc/shells` file.
Then run `chsh` to set the default shell to `${HOME}/.nix-profile/bin/zsh` on non-declarative systems.

### Setup local shell extensions

Just put your local stuff (not checked into git) into `~/.config/home-manager/<shell>/local.sh`.


## Applying Changes

To apply changes to nix files there is the alias `hmrs`.
Most of the time changes are applied instantly without requiring a reboot.

## Update Software

To update the package repository and flake.lock file simply run the alias `hmu`.
