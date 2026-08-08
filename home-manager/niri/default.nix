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
in
{
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
    waybar
    wl-clipboard
    xwayland-satellite
    niriWallpaper
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
              proportion 0.55
          }

          focus-ring {
              width 2
              active-color "#8be9fd"
              inactive-color "#44475a"
          }

          border {
              off
          }
      }

      prefer-no-csd
      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

      hotkey-overlay {
          skip-at-startup
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

      spawn-at-startup "waybar"
      spawn-at-startup "mako"
      spawn-at-startup "${niriWallpaper}/bin/niri-wallpaper"
      // Replace a Kime daemon left attached to X11 with one attached to Niri.
      spawn-at-startup "${pkgs.runtimeShell}" "-c" "${pkgs.procps}/bin/pkill -x kime 2>/dev/null; while ${pkgs.procps}/bin/pgrep -x kime >/dev/null; do ${pkgs.coreutils}/bin/sleep 0.05; done; exec ${pkgs.kime}/bin/kime"

      // Move Swaybg into Niri's full-screen Overview backdrop.
      layer-rule {
          match namespace="^wallpaper$"
          place-within-backdrop true
      }

      binds {
          F13 repeat=false { toggle-overview; }
          Mod+P { spawn "fuzzel"; }
          Mod+Shift+Return { spawn "foot"; }
          Mod+F { maximize-window-to-edges; }
          Mod+B { fullscreen-window; }

          Mod+J { focus-column-left; }
          Mod+K { focus-column-right; }
          Mod+H { set-column-width "-5%"; }
          Mod+L { set-column-width "+5%"; }
          Mod+N { consume-or-expel-window-left; }
          Mod+M { consume-or-expel-window-right; }
          Mod+Return { move-column-to-first; }
          Mod+Shift+C { close-window; }
          Mod+Tab { focus-workspace-previous; }
          Mod+Shift+Space { toggle-window-floating; }

          Mod+I { focus-window-or-workspace-up; }
          Mod+O { focus-window-or-workspace-down; }
          Mod+Shift+I { move-column-to-workspace-up; }
          Mod+Shift+O { move-column-to-workspace-down; }

          Mod+Comma { focus-monitor-left; }
          Mod+Period { focus-monitor-right; }
          Mod+Shift+Comma { move-column-to-monitor-left; }
          Mod+Shift+Period { move-column-to-monitor-right; }

          Mod+Left { focus-column-left; }
          Mod+Right { focus-column-right; }
          Mod+Up { focus-window-up; }
          Mod+Down { focus-window-down; }
          Mod+Ctrl+Left { move-column-left; }
          Mod+Ctrl+Right { move-column-right; }
          Mod+Ctrl+Up { move-window-up; }
          Mod+Ctrl+Down { move-window-down; }

          Mod+Shift+S { screenshot; }
          Mod+Shift+W { spawn "swayimg" "--gallery" "/home/ohsean/wallpaper"; }
          Mod+X { spawn-sh "swaylock -f -c 282a36 & sleep 0.2; niri msg action power-off-monitors"; }
          Mod+Shift+E { quit; }

          Mod+F11 { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
          Mod+F10 { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
          Mod+F12 { spawn "wpctl" "set-volume" "-l" "1.0" "@DEFAULT_AUDIO_SINK@" "5%+"; }
          Mod+F2 { spawn "brightnessctl" "set" "5%-"; }
          Mod+F3 { spawn "brightnessctl" "set" "+5%"; }
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

    "waybar/config.jsonc".text = builtins.toJSON {
      layer = "top";
      position = "top";
      height = 22;
      spacing = 0;
      modules-left = [ "niri/workspaces" ];
      modules-right = [ "network" "pulseaudio" "backlight" "battery" "clock" ];

      "niri/workspaces" = {
        format = "{value}";
        on-click = "activate";
      };

      network = {
        interval = 5;
        format-wifi = "󰖩 {essid}";
        format-ethernet = " {ifname}";
        format-disconnected = "睊";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        tooltip-format-wifi = "{essid}: {signalStrength}%";
        on-click = "foot -e nmtui";
      };

      pulseaudio = {
        scroll-step = 5;
        format = "{icon} {volume}%";
        format-muted = "󰖁";
        format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

      backlight = {
        interval = 10;
        format = "󰌵 {percent}%";
        on-scroll-up = "brightnessctl set +5%";
        on-scroll-down = "brightnessctl set 5%-";
      };

      battery = {
        bat = "CMB0";
        interval = 5;
        states = {
          warning = 50;
          critical = 25;
        };
        format = "{icon} {capacity}%";
        format-charging = "<span color=\"#50fa7b\"></span> {icon} {capacity}%";
        format-full = "󱐋 {capacity}%";
        format-icons = [ " " " " " " " " " " ];
      };

      clock = {
        interval = 60;
        format = "󰃵 {:%a, %b %d  %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
        calendar = {
          mode = "month";
          weeks-pos = "right";
        };
      };
    };

    "waybar/style.css".text = ''
      * {
        border: none;
        border-radius: 0;
        min-height: 0;
        font-family: "FiraCode Nerd Font", "Symbols Nerd Font";
        font-size: 10pt;
        font-style: normal;
        font-weight: bold;
      }

      window#waybar {
        background: #44475a;
        color: #f8f8f2;
      }

      #workspaces button {
        padding: 0 8px;
        background: transparent;
        color: #f8f8f2;
      }

      #workspaces button.active {
        background: #8be9fd;
        color: #282a36;
      }

      #network,
      #pulseaudio,
      #backlight,
      #battery,
      #clock {
        padding: 0 4px;
        background: transparent;
      }

      #network { color: #ff79c9; }
      #pulseaudio { color: #8be9fd; }
      #backlight { color: #f1fa8c; }
      #battery { color: #50fa7b; }
      #clock { color: #8be9fd; }

      #battery.warning { color: #ffb86c; }
      #battery.critical { color: #ff5555; }
    '';

    "systemd/user/dunst.service.d/niri.conf".text = x11Only;
    "systemd/user/app-picom@autostart.service.d/niri.conf".text = x11Only;
    "systemd/user/app-blueman@autostart.service.d/niri.conf".text = x11Only;
    "systemd/user/app-bitwarden@autostart.service.d/niri.conf".text = x11Only;
  };
}
