# My Home Manager Configurations for various systems I use

## Installation

This installs the Nix package-manager, the home-manager module and all software defined in the flake for the current system.
This requires sudo rights to setup /nix.

It also will write all defined configuration files to your home directory. In case of a conflict it should abort, but make a backup anyway :).


```sh
cd # Home
git clone https://github.com/r3ddr4gOn/home-manager.git .config/home-manager
.config/home-manager/setup.sh
```

## Update Software

```sh
cd # Home
.config/home-manager/update.sh
```

## Applying Changes

```sh
# edit files in ~/.config/home-manager
# commit changes to git
home-manager switch
```
