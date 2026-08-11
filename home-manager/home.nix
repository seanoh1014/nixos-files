{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./doom.nix
    ./tmux.nix
    ./dotfiles/neovim.nix
    ./vscode.nix
    ./niri # Comment out this line to remove all Niri user configuration.
    # ./dwm-session.nix # Uncomment this line to restore all DWM user configuration.
    # ./dotfiles/fonts.nix
    ./dotfiles/zsh.nix
    ./dotfiles/zathura.nix

    # Hyprland
    # ./dotfiles/hyprland/hyprland.nix
    # ./dotfiles/waybar/waybar.nix
    # ./dotfiles/foot.nix
  ];

  home.username = "ohsean";
  home.homeDirectory = "/home/ohsean";
  home.sessionVariables = {
    EDITOR = "nvim";
    LESSCHARSET = "utf-8";
  };

  home.stateVersion = "22.11"; # Keep unchanged after initial setup.

  home.packages = with pkgs; [
    # Browsers
    firefox
    (brave.overrideAttrs (old: {
      preFixup = (old.preFixup or "") + ''
        gappsWrapperArgs+=(
          --add-flags "--enable-features=TouchpadOverscrollHistoryNavigation"
        )
      '';
    }))
    # mullvad-browser

    # Command-line and system tools
    unzip
    p7zip
    gh
    bc
    nitch
    btop
    libnotify
    glib
    pkg-config
    mlocate
    acpi
    # zfxtop
    # uwufetch
    # eza

    # Media
    mpv
    # ytfzf
    # youtube-tui
    # yt-dlp-light
    # maim
    # satty
    # kdePackages.spectacle

    # Desktop and X11
    pkgs.adwaita-icon-theme
    networkmanagerapplet
    # betterlockscreen
    # networkmanager_dmenu
    # connman_dmenu

    # Networking and connected devices
    wirelesstools
    libimobiledevice
    ifuse
    usbmuxd2
    filezilla
    syncthing
    scrcpy
    android-tools
    # nextdns
    # opensnitch-ui

    # Power and hardware
    alsa-utils
    blueman

    # Containers and virtualization
    distrobox
    docker
    qemu
    virt-manager
    # podman
    # podman-compose
    # docker-compose
    # fuse
    # flatpak
    # waydroid
    # spice-gtk
    # quickemu
    # winboat

    # Compatibility and remote access
    wine
    gnome-software
    # wine-staging
    # wine64
    # freerdp
    # bottles

    # Development
    codex
    hugo
    nodejs
    libgcc
    gdb
    (python3.withPackages (ps: with ps; [
      # requests
      # numpy
      # pandas
      python-dotenv
      pip
    ]))
    # ghidra
    # python3
    # vscode-fhs
    # vscode
    # doas-sudo-shim
    # git-remote-gcrypt

    # Documents and productivity
    texliveFull
    texstudio
    sioyek
    tradingview
    obsidian
    anki
    # bitwarden-desktop
    # teams-for-linux
    # zoom-us
    # notion-app-enhanced
    # koreader

    # File management
    yazi
    ueberzugpp
    # zellij # tmux alternative
    # nautilus
    # kdePackages.dolphin

    # Storage and filesystems
    exfat
    parted
    gptfdisk

    # Gaming
    prismlauncher
    # factorio-demo
    # tetrio-desktop
    # shattered-pixel-dungeon
    # crawlTiles
    # aseprite

    # Fonts
    nanum
    # (nerdfonts.override { fonts = [ "FiraCode" ]; })

    # Security and credentials
    pkgs.gnome-keyring
    # gnupg
    # pinentry-gtk2

    # Nix ecosystem
    # nur.repos.mic92.hello-nur
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "seanoh1014";
      user.email = "ohsean1014@gmail.com";
      credential = {
        helper = "${
            pkgs.git.override { withLibsecret = true; }
          }/bin/git-credential-libsecret";
        "https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
        "https://gist.github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
      };
      safe = { directory = "*"; };
    };
    signing.format = null;
    # userName = "seanoh1014";
    # userEmail = "ohsean1014@gmail.com";
    # extraConfig = {
    #   credential.helper = "${
    #      pkgs.git.override { withLibsecret = true; }
    #    }/bin/git-credential-libsecret";
    #   safe = { directory = "*"; };
    # };
  };

  programs.neovim.withRuby = true;
  programs.neovim.withPython3 = true;

  # services.kdeconnect.enable = false;

  home.file = {
    # Common
    "./wallpaper".source = ./wallpaper;
    ".p10k.zsh".source = dotfiles/.p10k.zsh;
    ".config/mpv/scripts/modern.lua".source = dotfiles/mpv/modern.lua;
    ".config/mpv/fonts/Material-Design-Iconic-Font.ttf".source = dotfiles/mpv/Material-Design-Iconic-Font.ttf;
    ".config/mpv/mpv.conf".source = dotfiles/mpv/mpv.conf;
    # "/etc/udev/rules.d/99-local.rules".source = dotfiles/99-batify.rules;

    # "/etc/static/systemd/resolved.conf".source = dotfiles/resolved.conf;
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  programs.home-manager.enable = true;
}
