{ pkgs, ... }:

let
  volumeWob = pkgs.writeShellScriptBin "niri-volume-wob" ''
    set -eu

    sink="@DEFAULT_AUDIO_SINK@"

    case "''${1:-}" in
      down)
        ${pkgs.wireplumber}/bin/wpctl set-volume "$sink" 5%-
        ;;
      mute)
        ${pkgs.wireplumber}/bin/wpctl set-mute "$sink" toggle
        ;;
      up)
        ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.0 "$sink" 5%+
        ;;
      *)
        echo "usage: niri-volume-wob {down|mute|up}" >&2
        exit 2
        ;;
    esac

    volume="$(${pkgs.wireplumber}/bin/wpctl get-volume "$sink")"
    percentage="$(printf '%s\n' "$volume" | ${pkgs.gawk}/bin/awk '{ printf "%.0f", $2 * 100 }')"

    case "$volume" in
      *"[MUTED]"*) printf '%s muted\n' "$percentage" ;;
      *) printf '%s\n' "$percentage" ;;
    esac > "''${XDG_RUNTIME_DIR:?}/wob.sock"
  '';
in
{
  home.packages = [
    pkgs.wob
    volumeWob
    # Interactive PipeWire TUI alternative: pkgs.wiremix
  ];

  xdg.configFile."wob/wob.ini".text = ''
    timeout = 1000
    max = 100
    width = 240
    height = 14
    border_offset = 0
    border_size = 2
    bar_padding = 2
    anchor = top right
    margin = 23 16 0 0
    border_color = F8F8F2FF
    background_color = 44475AFF
    bar_color = F8F8F2FF
    overflow_bar_color = B8B8B4FF
    overflow_mode = nowrap

    [style.muted]
    bar_color = F8F8F2FF
  '';

  # Socket activation avoids keeping a separate `tail -f` process alive.
  systemd.user.sockets.wob = {
    Socket = {
      ListenFIFO = "%t/wob.sock";
      SocketMode = "0600";
      RemoveOnStop = true;
      FlushPending = true;
    };
    Install.WantedBy = [ "sockets.target" ];
  };

  systemd.user.services.wob = {
    Unit = {
      Description = "Lightweight Wayland overlay bar";
      Documentation = [ "man:wob(1)" ];
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
    };
    Service = {
      StandardInput = "socket";
      StandardOutput = "journal";
      ExecStart = "${pkgs.wob}/bin/wob";
    };
  };
}
