{ pkgs, ... }:

{
  # Complete DWM user environment. Keep this module detached while using
  # Niri; re-enable its import in home.nix to restore the entire setup.
  imports = [
    ./dwm.nix
    ./suckless.nix
    # ./sxiv.nix
  ];

  home.packages = with pkgs; [
    acpilight
    arandr
    feh
    flameshot
    setxkbmap
    simplescreenrecorder
    xcape
    xclip
  ];

  services.picom.enable = true;
  services.dunst.enable = true;

  home.file = {
    ".xinitrc".source = dotfiles/.xinitrc;
    ".Xresources".source = dotfiles/.Xresources;
    # ".config/sxiv".source = dotfiles/sxiv;
    ".config/picom.conf".source = dotfiles/picom.conf;
    ".config/dunst".source = dotfiles/dunst;
    ".config/flameshot".source = dotfiles/flameshot;
  };
}
