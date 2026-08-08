{ ... }:

{
  # Niri stays independent from the existing X11/DWM configuration. Removing
  # this module disables the compositor and its only system service, keyd.
  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  # Match the DWM session's Caps Lock behavior without relying on X11 tools:
  # tap for Escape, hold for Control.
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        capslock = "overload(control, esc)";
        leftmeta = "overload(meta, f13)";
      };
    };
  };
}
