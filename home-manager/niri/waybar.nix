{ pkgs, ... }:

let
  waybarNiriWindows = pkgs.callPackage ./waybar-niri-windows.nix { };
in
{
  home.packages = [ pkgs.waybar ];

  xdg.configFile = {
    "waybar/config.jsonc".text = builtins.toJSON {
      layer = "top";
      position = "top";
      height = 22;
      spacing = 0;
      modules-left = [ "niri/workspaces" ];
      modules-right = [ "cffi/niri-windows" "network" "pulseaudio" "backlight" "battery" "clock" ];

      "niri/workspaces" = {
        format = "{icon}";
        format-icons = {
          default = "●";
          active = ''<span size="1"> </span>'';
        };
        on-click = "activate";
      };

      "cffi/niri-windows" = {
        module_path = "${waybarNiriWindows}/lib/waybar-niri-windows.so";
        options = {
          mode = "text";
          symbols = {
            unfocused = ''<span foreground="#a6a6a6" size="10pt" rise="1024">▪</span>&#x2009;'';
            focused = ''<span foreground="#f8f8f2" size="10pt" rise="1024">▪</span>&#x2009;'';
            unfocused-floating = ''<span foreground="#a6a6a6" size="10pt" rise="1024">▪</span>&#x2009;'';
            focused-floating = ''<span foreground="#f8f8f2" size="10pt" rise="1024">▪</span>&#x2009;'';
            empty = "";
          };
        };
        actions = {
          on-scroll-up = "FocusColumnLeft";
          on-scroll-down = "FocusColumnRight";
        };
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
        min-width: 7px;
        padding: 0 4px;
        background: transparent;
        color: #f8f8f2;
        box-shadow: none;
        transition: min-width 180ms ease-in-out;
      }

      #workspaces button.active {
        min-width: 22px;
        min-height: 7px;
        margin: 7px 4px;
        padding: 0;
        border-radius: 4px;
        background: #8be9fd;
        color: transparent;
        font-size: 1px;
      }

      #workspaces button:hover {
        background: transparent;
        box-shadow: none;
        text-shadow: none;
      }

      #workspaces button.active:hover {
        background: #8be9fd;
      }

      .cffi-niri-windows label {
        padding: 0 4px;
        color: #8be9fd;
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
  };
}
