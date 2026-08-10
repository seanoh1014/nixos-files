{ ... }:

{
  # Complete X11/DWM system integration. Keep this module detached while Niri
  # is the only active desktop; re-enable its import in configuration.nix.
  services = {
    libinput = {
      enable = true;
      touchpad = {
        tapping = true;
        middleEmulation = true;
        naturalScrolling = true;
        disableWhileTyping = true;
      };
    };

    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
      displayManager.startx.enable = true;
      windowManager.dwm.enable = true;
    };
  };
}
