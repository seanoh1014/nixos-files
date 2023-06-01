# Installation

- After installing nixos, clone this repository

    ```shell
    git clone https://seanoh1014/nixos-files.git
    ```

- In nixos/, replace hardware-configuration.nix to yours 

- Install 'home-manager' and add these channels

    ```shell
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
    nix-channel --add https://nixos.org/channels/nixos-unstable nixos
    nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs

    nix-channel --update

    nix-shell '<home-manager>' -A install   
    ```
- Replace ohsean and nixos to your username and your hostname in flake.nix, home.nix, and configuration.nix
   
   ```shell
   sudo nixos-rebuild switch --flake .#your_user_name
   home-manager switch --flake .#your_host_name
   ```
