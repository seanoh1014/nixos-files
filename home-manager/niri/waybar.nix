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
      spacing = 8;
      modules-left = [ "niri/workspaces" ];
      modules-right = [ "cffi/niri-windows" "network" "pulseaudio" "battery" "clock" ];

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
        format-wifi = "󰖩";
        format-ethernet = "";
        format-disconnected = "󰖪";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        tooltip-format-wifi = "{essid}: {signalStrength}%";
        tooltip-format-disconnected = "Disconnected";
        on-click = "foot -e nmtui";
      };

      pulseaudio = {
        scroll-step = 5;
        format = "{icon}";
        format-muted = "󰖁";
        format-icons.default = [ "󰕿" "󰖀" "󰕾" ];
        tooltip-format = "{desc}: {volume}%";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

      battery = {
        bat = "CMB0";
        interval = 5;
        states = {
          warning = 50;
          critical = 25;
        };
        format = "{icon}";
        format-charging = " {icon}";
        format-full = "󱐋 ";
        format-icons = [ " " " " " " " " " " ];
        tooltip-format = "Battery: {capacity}%";
      };

      clock = {
        interval = 60;
        format = "󰃵 {:%b %d %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
        calendar = {
          mode = "month";
          weeks-pos = "right";
          format = {
            months = "{{0:<20%b %Y}}{{0:>3%a}}";
            today = ''<span foreground="#44475a" background="#f8f8f2"><b>{}</b></span>'';
          };
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

      .modules-right {
        margin-right: 4px;
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
      #battery {
        padding: 0 3px;
        background: transparent;
        color: #f8f8f2;
      }

      #clock {
        padding: 0 2px;
        background: transparent;
        color: #f8f8f2;
      }

    '';
  };
}
