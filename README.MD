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

    `x1c` is my hostname. So if you want to change it, don't forget to replace it three places:

    - 1  in `nixos/configuration.nix`
    - 2  in `flake.nix`
    - 3  when invoking `nixos-install`

- After installation, install `home-manager` and then give it this flake to copy dotfiles.

    ```shell
    nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz
    nix-channel --update
    nix-shell '<home-manager>' -A install
    home-manager switch --flake github:Awan/nix#ak
    ```

- replace ohsean and nixos to your username and your hostname in flake.nix, home.nix, and configuration.nix
   
   ```shell
   sudo nixos-rebuild switch --flake .#your_user_name
   home-manager switch --flake .#your_host_name
   ```
