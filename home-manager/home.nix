{ config, pkgs, lib, ... }:

{
  imports = [
    ./dwm.nix
    ./neovim.nix
    #./firefox.nix
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
    firefox 
    mullvad-browser
    brave

    # necessary packages
    unzip
    p7zip
    bc 
    neofetch
    libnotify
    glib
    toybox

    # video player
    mpv

    # image viewer
    feh
    sxiv

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

    
    # Fonts 
    nanum
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    (st.overrideAttrs (oldAttrs: rec {
      buildInputs = oldAttrs.buildInputs ++ [ harfbuzz ];
      src = builtins.fetchTarball {
      url = "https://github.com/seanoh1014/st/tarball/master";
      sha256 = "13djp8iaincqvj2nhily8vwfxn7aywi579w52lz305imif32gv69";
    };
  }))
    (dwmblocks.overrideAttrs (oldAttrs: rec {
      src = builtins.fetchTarball {
      url = "https://github.com/seanoh1014/dwmblocks/tarball/master";
      sha256 = "08py394s83jsg4sykp2683kljwld8kmzsy73zj8dbphwrr1pnjnr";
    };
  }))

  ];

  programs.git = {
    enable = true;
    userName  = "seanoh1014";
    userEmail = "ohsean1014@gmail.com";
  };

  services.picom.enable = true;
  services.dunst.enable = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    ".xinitrc".source = dotfiles/.xinitrc;
    ".Xresources".source = dotfiles/.Xresources;
    ".config/sxiv".source = dotfiles/sxiv;
    ".config/picom.conf".source = dotfiles/picom.conf;
    ".config/dunst".source = dotfiles/dunst;
    "./wallpaper".source = ./wallpaper;
    ".config/flameshot".source = dotfiles/flameshot;
    #".p10k.zsh".source = dotfiles/.p10k.zsh;

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

  # Zsh configuration
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; } # Simple plugin installation
	    { name = "zsh-users/zsh-syntax-highlighting"; }
        #{ name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } 
      ];
    };
  };

  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
