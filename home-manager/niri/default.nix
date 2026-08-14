{ pkgs, ... }:

let
  # These programs belong to the X11 session. Requiring an explicit X11
  # session keeps them from racing Mako or wasting resources under Niri.
  x11Only = ''
    [Unit]
    ConditionEnvironment=XDG_SESSION_TYPE=x11
  '';

  niriWallpaper = pkgs.writeShellScriptBin "niri-wallpaper" ''
    set -eu

    state_file="''${XDG_STATE_HOME:-$HOME/.local/state}/niri/wallpaper"
    wallpaper="/home/ohsean/wallpaper/astolfo.png"

    if [ -r "$state_file" ] && IFS= read -r saved < "$state_file" && [ -f "$saved" ]; then
      wallpaper="$saved"
    fi

    if [ "''${1:-}" = "--reload" ]; then
      ${pkgs.toybox}/bin/pkill swaybg || true
      exec ${pkgs.niri}/bin/niri msg action spawn -- \
        ${pkgs.swaybg}/bin/swaybg -i "$wallpaper" -m fill
    fi

    exec ${pkgs.swaybg}/bin/swaybg -i "$wallpaper" -m fill
  '';

  niriPowerMenu = pkgs.writeShellScriptBin "niri-power-menu" ''
    set -eu

    choice="$(printf '%s\n' \
      "Lock" \
      "Suspend" \
      "Log out" \
      "Reboot" \
      "Power off" | \
      ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="Session: " --lines=5 --minimal-lines)"

    case "$choice" in
      "Lock")
        ${pkgs.swaylock}/bin/swaylock -f -c 282a36
        ;;
      "Suspend")
        ${pkgs.swaylock}/bin/swaylock -f -c 282a36
        ${pkgs.systemd}/bin/systemctl suspend
        ;;
      "Log out")
        ${pkgs.niri}/bin/niri msg action quit --skip-confirmation
        ;;
      "Reboot")
        ${pkgs.systemd}/bin/systemctl reboot
        ;;
      "Power off")
        ${pkgs.systemd}/bin/systemctl poweroff
        ;;
    esac
  '';
in
{
  imports = [
    # Remove this one line to detach live theme switching and use the static
    # colors below again.
    ./theme-switcher.nix
    ./waybar.nix
    ./wob.nix
  ];

  home.packages = with pkgs; [
    foot
    fuzzel
    mako
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
    swaybg
    swayimg
    swaylock
    vanilla-dmz
    wl-clipboard
    xwayland-satellite
    niriWallpaper
    niriPowerMenu
  ];

  xdg.configFile = {
    "niri/config.kdl".text = ''
      input {
          keyboard {
              xkb {
                  layout "us"
              }
          }

          touchpad {
              tap
              natural-scroll
              dwt
          }

          mod-key "Alt"
      }

      output "eDP-1" {
          mode "1920x1080"
          scale 1
      }

      // Match the compact classic cursor used by the X11/DWM session.
      cursor {
          xcursor-theme "DMZ-Black"
          xcursor-size 16
      }

      layout {
          // Keep the wallpaper stationary behind the workspaces in Overview.
          background-color "transparent"
          gaps 10
          center-focused-column "never"

          default-column-width {
              proportion 0.5
          }

          focus-ring {
              width 3
              active-color "#8be9fd80"
              inactive-color "#44475a80"
          }

          tab-indicator {
              active-color "#9F9F9FFF"
              inactive-color "#656565FF"
          }

          border {
              off
          }
      }

      prefer-no-csd
      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

      hotkey-overlay {
          skip-at-startup
          // Keep hide-not-bound unset so Niri lists unused important actions.
      }

      // Keep transparent workspace backgrounds free of Overview shadows.
      overview {
          workspace-shadow {
              off
          }
      }

      // Draw focus rings around windows instead of behind their contents.
      window-rule {
          draw-border-with-background false
      }

      // Float only terminals opened with Mod+Enter.
      window-rule {
          match app-id="^floating-terminal$"
          open-floating true
          default-floating-position x=10 y=10 relative-to="bottom-right"
          default-column-width { proportion 0.33; }
          default-window-height { proportion 0.5; }
      }

      spawn-at-startup "waybar"
      spawn-at-startup "mako"
      spawn-at-startup "${niriWallpaper}/bin/niri-wallpaper"
      // Kime is temporarily disabled in Niri. Uncomment to restore Wayland input.
      // spawn-at-startup "${pkgs.kime}/bin/kime"

      // Move Swaybg into Niri's full-screen Overview backdrop.
      layer-rule {
          match namespace="^wallpaper$"
          place-within-backdrop true
      }

      recent-windows {
          binds {
              Mod+Tab hotkey-overlay-title="Switch recent windows" { next-window; }
          }
      }

      binds {
          Mod+Shift+Slash hotkey-overlay-title="Show important hotkeys" { show-hotkey-overlay; }
          Mod+Space repeat=false hotkey-overlay-title="Toggle overview" { toggle-overview; }
          Mod+P hotkey-overlay-title="Open application launcher" { spawn "fuzzel"; }
          Mod+Shift+Return hotkey-overlay-title="Open terminal" { spawn "foot"; }
          Mod+F hotkey-overlay-title="Maximize window" { maximize-window-to-edges; }
          Mod+B hotkey-overlay-title="Toggle fullscreen" { fullscreen-window; }

          Mod+J hotkey-overlay-title="Focus column left (wrap)" { focus-column-left-or-last; }
          Mod+K hotkey-overlay-title="Focus column right (wrap)" { focus-column-right-or-first; }
          Mod+Shift+J hotkey-overlay-title="Move column left" { move-column-left; }
          Mod+Shift+K hotkey-overlay-title="Move column right" { move-column-right; }
          Mod+Shift+H hotkey-overlay-title="Move column to first" { move-column-to-first; }
          Mod+Shift+L hotkey-overlay-title="Move column to last" { move-column-to-last; }
          Mod+H hotkey-overlay-title="Decrease column width" { set-column-width "-5%"; }
          Mod+L hotkey-overlay-title="Increase column width" { set-column-width "+5%"; }
          Mod+N hotkey-overlay-title="Consume or expel window left" { consume-or-expel-window-left; }
          Mod+M hotkey-overlay-title="Consume or expel window right" { consume-or-expel-window-right; }
          Mod+Shift+N hotkey-overlay-title="Consume window into column" { consume-window-into-column; }
          Mod+Shift+M hotkey-overlay-title="Expel window from column" { expel-window-from-column; }
          Mod+W hotkey-overlay-title="Toggle tabbed column" { toggle-column-tabbed-display; }
          Mod+Return hotkey-overlay-title="Open floating terminal" { spawn "foot" "--app-id=floating-terminal"; }
          Mod+Shift+C hotkey-overlay-title="Close window" { close-window; }
          Super+Tab hotkey-overlay-title="Focus previous workspace" { focus-workspace-previous; }
          Mod+Shift+Space hotkey-overlay-title="Toggle floating window" { toggle-window-floating; }

          Mod+I hotkey-overlay-title="Focus window or workspace up" { focus-window-or-workspace-up; }
          Mod+O hotkey-overlay-title="Focus window or workspace down" { focus-window-or-workspace-down; }
          Mod+Shift+I hotkey-overlay-title="Move column to workspace up" { move-column-to-workspace-up; }
          Mod+Shift+O hotkey-overlay-title="Move column to workspace down" { move-column-to-workspace-down; }

          Mod+Comma hotkey-overlay-title="Focus monitor left" { focus-monitor-left; }
          Mod+Period hotkey-overlay-title="Focus monitor right" { focus-monitor-right; }
          Mod+Shift+Comma hotkey-overlay-title="Move column to monitor left" { move-column-to-monitor-left; }
          Mod+Shift+Period hotkey-overlay-title="Move column to monitor right" { move-column-to-monitor-right; }

          Mod+Left hotkey-overlay-title="Focus column left" { focus-column-left; }
          Mod+Right hotkey-overlay-title="Focus column right" { focus-column-right; }
          Mod+Up hotkey-overlay-title="Focus window up" { focus-window-up; }
          Mod+Down hotkey-overlay-title="Focus window down" { focus-window-down; }
          Mod+Ctrl+Left hotkey-overlay-title="Move column left (arrow)" { move-column-left; }
          Mod+Ctrl+Right hotkey-overlay-title="Move column right (arrow)" { move-column-right; }
          Mod+Ctrl+Up hotkey-overlay-title="Move window up" { move-window-up; }
          Mod+Ctrl+Down hotkey-overlay-title="Move window down" { move-window-down; }

          Mod+Shift+S hotkey-overlay-title="Take screenshot" { screenshot; }
          Mod+Shift+W hotkey-overlay-title="Open wallpaper gallery" { spawn "swayimg" "--gallery" "/home/ohsean/wallpaper"; }
          Mod+X hotkey-overlay-title="Lock and turn off displays" { spawn-sh "swaylock -f -c 282a36 & sleep 0.2; niri msg action power-off-monitors"; }
          Mod+Shift+E hotkey-overlay-title="Open power menu" { spawn "niri-power-menu"; }

          // Wob displays the result; Wiremix is the interactive mixer alternative.
          Mod+F11 hotkey-overlay-title="Volume down" { spawn "niri-volume-wob" "down"; }
          Mod+F10 hotkey-overlay-title="Toggle mute" { spawn "niri-volume-wob" "mute"; }
          Mod+F12 hotkey-overlay-title="Volume up" { spawn "niri-volume-wob" "up"; }
          F2 hotkey-overlay-title="Brightness down" { spawn "brightnessctl" "set" "5%-"; }
          F3 hotkey-overlay-title="Brightness up" { spawn "brightnessctl" "set" "+5%"; }
      }
    '';

    "foot/foot.ini".text = ''
      [main]
      font=FiraCode Nerd Font Mono:style=Bold:size=10
      pad=8x8

      [key-bindings]
      clipboard-copy=Control+Shift+c XF86Copy Mod1+c
      clipboard-paste=Control+Shift+v XF86Paste Mod1+v

      [colors-dark]
      foreground=cad3f5
      background=24273a
      cursor=24273a f4dbd6
      regular0=494d64
      regular1=ed8796
      regular2=a6da95
      regular3=eed49f
      regular4=8aadf4
      regular5=f5bde6
      regular6=8bd5ca
      regular7=b8c0e0
      bright0=5b6078
      bright1=ed8796
      bright2=a6da95
      bright3=eed49f
      bright4=8aadf4
      bright5=f5bde6
      bright6=8bd5ca
      bright7=a5adcb
    '';

    "fuzzel/fuzzel.ini".text = ''
      [main]
      terminal=foot
      font=FiraCode Nerd Font:size=10
      width=40
      lines=10
      horizontal-pad=12
      vertical-pad=8

      [colors]
      background=282a36ff
      text=f8f8f2ff
      match=ff79c6ff
      selection=44475aff
      selection-text=f8f8f2ff
      selection-match=8be9fdff
      border=8be9fdff

      [border]
      width=2
      radius=0
    '';

    "swayimg/init.lua".text = ''
      swayimg.gallery.set_text("topleft", {})

      local state_dir = "/home/ohsean/.local/state/niri"
      local state_file = state_dir .. "/wallpaper"

      local function set_wallpaper(image)
        if not image then
          return
        end

        os.execute("${pkgs.coreutils}/bin/mkdir -p " .. state_dir)

        local file, err = io.open(state_file, "w")
        if not file then
          swayimg.text.status = "Could not save wallpaper: " .. tostring(err)
          return
        end

        file:write(image.path, "\n")
        file:close()

        local success = os.execute("${niriWallpaper}/bin/niri-wallpaper --reload")
        if success then
          swayimg.exit()
        else
          swayimg.text.status = "Could not change wallpaper"
        end
      end

      swayimg.gallery.on_key("Return", function()
        set_wallpaper(swayimg.gallery.get_image())
      end)

      swayimg.gallery.on_key("w", function()
        set_wallpaper(swayimg.gallery.get_image())
      end)

      swayimg.viewer.on_key("w", function()
        set_wallpaper(swayimg.viewer.get_image())
      end)
    '';

    "mako/config".text = ''
      font=FiraCode Nerd Font 10
      background-color=#282a36
      text-color=#f8f8f2
      border-color=#8be9fd
      border-size=2
      border-radius=0
      default-timeout=5000
      max-visible=3
      width=320
      height=120
      margin=10
      padding=10
    '';

    "systemd/user/dunst.service.d/niri.conf".text = x11Only;
    "systemd/user/app-picom@autostart.service.d/niri.conf".text = x11Only;
    # Waybar already exposes NetworkManager through its network module; without
    # a tray, nm-applet is invisible and only consumes memory in Niri.
    "systemd/user/app-nm\\x2dapplet@autostart.service.d/niri.conf".text = x11Only;
    "systemd/user/app-blueman@autostart.service.d/niri.conf".text = x11Only;
    "systemd/user/app-bitwarden@autostart.service.d/niri.conf".text = x11Only;
    # Niri starts its own Wayland-aware Kime instance when the line above is enabled.
    "systemd/user/app-kime@autostart.service.d/niri.conf".text = x11Only;
  };
}
