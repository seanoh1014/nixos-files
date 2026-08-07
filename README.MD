# Sean's NixOS Configuration

Personal NixOS configuration built with flakes and Home Manager.

> [!WARNING]
> This repository contains settings specific to my user account, hardware, and
> network. Review the files listed below instead of applying it unchanged.

## Installation

### 1. Clone the repository

Clone it into your home directory so the paths used by the configuration remain
consistent:

```sh
git clone https://github.com/seanoh1014/nixos-files.git
cd nixos-files
```

### 2. Use your hardware configuration

Replace the included hardware configuration with the one generated for your
machine:

```sh
cp /etc/nixos/hardware-configuration.nix nixos/hardware-configuration.nix
```

### 3. Customize the configuration

Replace my username (`ohsean`) and hostname (`nixos`) in:

- `flake.nix`
- `nixos/configuration.nix`
- `home-manager/home.nix`

Also review the following machine-specific settings before continuing:

- Boot loader and EFI mount point
- Filesystem mounts, especially `/disk`
- Timezone
- DNS and networking
- Audio hardware options
- Installed packages

If you rename the `nixosConfigurations.nixos` or
`homeConfigurations.ohsean` outputs in `flake.nix`, use those new names in the
commands below.

### 4. Validate the configuration

```sh
nix flake check --impure --no-build
```

### 5. Apply the NixOS configuration

```sh
sudo nixos-rebuild switch --flake .#nixos
```

### 6. Apply the Home Manager configuration

```sh
nix run github:nix-community/home-manager -- \
  switch --impure --flake .#ohsean
```

Log out or reboot after the first installation so the new shell, desktop
session, environment variables, and input method are loaded.
