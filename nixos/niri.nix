{ ... }:

{
  # Niri stays independent from the existing X11/DWM configuration. Removing
  # this module disables the compositor and its only system service, keyd.
  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  # Match the DWM session's setxkbmap + xcape behavior without X11 tools:
  # Caps Lock and Left Ctrl act as Control immediately, emit Escape when
  # tapped alone within 500 ms, and emit nothing after a longer solo hold.
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        global.overload_tap_timeout = 500;
        main = {
          capslock = "overload(control, esc)";
          leftcontrol = "overload(control, esc)";
        };
      };
    };
  };
}
