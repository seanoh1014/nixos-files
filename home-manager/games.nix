{ pkgs, ... }:

let
  # Launch a Windows game from ~/Games through Proton (umu-launcher).
  # `play` opens a fuzzel picker; `play <name>` launches that folder directly.
  play = pkgs.writeShellScriptBin "play" ''
    set -eu

    games="$HOME/Games"

    if [ $# -gt 0 ]; then
      name="$*"
    else
      name="$(ls -1 "$games" | grep -vx umu | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="Play: ")"
    fi
    dir="$games/$name"
    [ -d "$dir" ] || { echo "No game folder: $dir" >&2; exit 1; }

    exe="$(find "$dir" -maxdepth 2 -iname '*.exe' \
      ! -iname '*crash*' ! -iname 'unins*' ! -iname '*setup*' ! -iname '*redist*' | head -n1)"
    [ -n "$exe" ] || { echo "No .exe found in $dir" >&2; exit 1; }

    # Steam AppID from the steamcmd manifest lets Proton apply game fixes.
    appid="$(ls "$dir"/steamapps/appmanifest_*.acf 2>/dev/null | grep -v _228980 | head -n1 | grep -o '[0-9]\+\.acf' | cut -d. -f1 || true)"

    # Caps Lock and Ctrl behave normally only while a window of this game is
    # focused. Caps Lock can't be untoggled once keyd's remap is back, so turn
    # it off first.
    keyd="/run/wrappers/bin/doas /run/current-system/sw/bin/keyd"
    niri=${pkgs.niri}/bin/niri
    jq=${pkgs.jq}/bin/jq
    game_keys() { $keyd bind "capslock=capslock" "leftcontrol=leftcontrol" >/dev/null; }
    normal_keys() {
      if grep -q 1 /sys/class/leds/*::capslock/brightness 2>/dev/null; then
        /run/current-system/sw/bin/ydotool key 58:1 58:0
      fi
      $keyd bind reset >/dev/null
    }
    in_game=0
    $niri msg --json event-stream |
      $jq --unbuffered -r 'select(.WindowFocusChanged) | .WindowFocusChanged.id // "none"' |
      while read -r id; do
        pid="$($niri msg --json windows | $jq -r ".[] | select(.id == ''${id/none/-1}) | .pid")"
        if [ -n "$pid" ] && tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null |
            grep -qiF "\\Games\\$name\\"; then
          [ "$in_game" = 1 ] || { game_keys; in_game=1; }
        else
          [ "$in_game" = 0 ] || { normal_keys; in_game=0; }
        fi
      done &
    trap 'pkill -P $$; normal_keys' EXIT

    cd "$(dirname "$exe")"
    PROTON_ENABLE_WAYLAND=1 GAMEID="umu-''${appid:-0}" ${pkgs.umu-launcher}/bin/umu-run "$exe"
  '';
in
{
  home.packages = [
    pkgs.steamcmd
    pkgs.umu-launcher
    play
  ];
}
