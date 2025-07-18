{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./dwm.nix
    ./dotfiles/neovim.nix
    ./sxiv.nix
    #./dotfiles/emacs.nix
    #./dotfiles/fonts.nix
    ./dotfiles/zsh.nix
    ./dotfiles/zathura.nix 
    # hyprland
    #./dotfiles/hyprland/hyprland.nix
    #./dotfiles/waybar/waybar.nix
    #./dotfiles/foot.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ohsean";
  home.homeDirectory = "/home/ohsean";
  home.sessionVariables = {
    EDITOR = "nvim";
    LESSCHARSET = "utf-8";
  };

  home.stateVersion = "22.11"; # Please read the comment before changing.

  
  home.packages = with pkgs; [

    # browsers
    (brave.override { commandLineArgs = [ "--enable-features=TouchpadOverscrollHistoryNavigation" ]; })
    #brave
    #mullvad-browser

    # tools
    unzip
    p7zip
    bc 
    nitch
    #zfxtop
    #uwufetch
    libnotify
    glib
    toybox
    pkg-config
    mlocate
    #docker
    #docker-compose
    #ghidra
    hugo

    # video player
    mpv
    #ytfzf
    #youtube-tui
    #yt-dlp-light

    # image viewer
    feh
    #betterlockscreen

    # screenshot
    flameshot

    # theme
    pkgs.adwaita-icon-theme
     
    # key binding
    xorg.setxkbmap
    xcape
    xclip

    # network
    wirelesstools

    # backlight
    acpilight

    # store password
    libsecret

    # emulator/non-emulator
    #wine
    #qemu

    # fonts 
    nanum
    #(nerdfonts.override { fonts = [ "FiraCode" ]; })

    # others
    #emacs
    #aseprite
    #tmux
    acpi
    pkgs.gnome-keyring
    filezilla
    arandr
    obsidian
    #teams-for-linux
    #zoom-us
    exfat
    parted
    gptfdisk
    alsa-utils
    doas-sudo-shim
    anki
    blueman
    #notion-app-enhanced
    syncthing
    #balatro
    #nur.repos.mic92.hello-nur
    #shattered-pixel-dungeon
    #crawlTiles
    #nextdns
    #git-remote-gcrypt
    #gnupg
    #pinentry-gtk2
    #distrobox
    #eza
    #opensnitch-ui

  ];

  programs.git = {
    enable = true;
    userName  = "seanoh1014";
    userEmail = "ohsean1014@gmail.com";
    extraConfig = {
      credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
      safe = { directory = "*"; };
    };
  };
  #services.kdeconnect.enable = false;

  services.picom.enable = true;
  services.dunst.enable = true;
  #services.emacs.enable = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # dwm
    ".xinitrc".source = dotfiles/.xinitrc;
    ".Xresources".source = dotfiles/.Xresources;
    ".config/sxiv".source = dotfiles/sxiv;
    ".config/picom.conf".source = dotfiles/picom.conf;
    ".config/dunst".source = dotfiles/dunst;
    # common
    "./wallpaper".source = ./wallpaper;
    ".config/flameshot".source = dotfiles/flameshot;
    ".p10k.zsh".source = dotfiles/.p10k.zsh;
    ".config/mpv/scripts/modern.lua".source = dotfiles/mpv/modern.lua;
    ".config/mpv/fonts/Material-Design-Iconic-Font.ttf".source = dotfiles/mpv/Material-Design-Iconic-Font.ttf;
    ".config/mpv/mpv.conf".source = dotfiles/mpv/mpv.conf;
    #"/etc/udev/rules.d/99-local.rules".source = dotfiles/99-batify.rules;

    #"/etc/static/systemd/resolved.conf".source = dotfiles/resolved.conf;
    # doom emacs
    #"./doom.d/config.el".source = dotfiles/doom/config.el;
    #"./doom.d/init.el".source = dotfiles/doom/init.el;
    #"./doom.d/packages.el".source = dotfiles/doom/packages.el;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ohsean/etc/profile.d/hm-session-vars.sh
  #

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
