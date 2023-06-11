{ config, pkgs, lib, ... }:

{
  imports = [
    ./dwm.nix
    ./dotfiles/neovim.nix
    ./sxiv.nix
    ./dotfiles/fonts.nix
    ./dotfiles/zsh.nix
    ./dotfiles/zathura.nix 
    # hyprland
    ./dotfiles/hyprland/hyprland.nix
    ./dotfiles/waybar/waybar.nix
    ./dotfiles/foot.nix
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
    # Browsers
    brave

    # necessary packages
    unzip
    p7zip
    bc 
    neofetch
    libnotify
    glib
    toybox
    pkg-config
    mlocate

    # video player
    mpv
    ytfzf

    # image viewer
    feh
    betterlockscreen

    # screenshot
    flameshot

    # theme
    gnome.adwaita-icon-theme
     
    # key binding
    xorg.setxkbmap
    xcape

    # Network
    wirelesstools

    # backlight
    acpilight

    # store password
    libsecret

    # archiving tool
    wine

    # Fonts 
    nanum
    (nerdfonts.override { fonts = [ "FiraCode" ]; })

  ];

  programs.git = {
    enable = true;
    userName  = "seanoh1014";
    userEmail = "ohsean1014@gmail.com";
    extraConfig = {
      credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
    };
  };

  services.picom.enable = true;
  services.dunst.enable = true;
  #services.emacs.enable = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".xinitrc".source = dotfiles/.xinitrc;
    ".Xresources".source = dotfiles/.Xresources;
    ".config/sxiv".source = dotfiles/sxiv;
    ".config/picom.conf".source = dotfiles/picom.conf;
    ".config/dunst".source = dotfiles/dunst;
    "./wallpaper".source = ./wallpaper;
    ".config/flameshot".source = dotfiles/flameshot;
    ".p10k.zsh".source = dotfiles/.p10k.zsh;
    ".config/mpv/scripts/modern.lua".source = dotfiles/mpv/modern.lua;
    ".config/mpv/fonts/Material-Design-Iconic-Font.ttf".source = dotfiles/mpv/Material-Design-Iconic-Font.ttf;
    ".config/mpv/mpv.conf".source = dotfiles/mpv/mpv.conf;
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
