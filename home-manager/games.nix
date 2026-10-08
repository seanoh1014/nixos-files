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
      name="$(ls -1 "$games" | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt="Play: ")"
    fi
    dir="$games/$name"
    [ -d "$dir" ] || { echo "No game folder: $dir" >&2; exit 1; }

    exe="$(find "$dir" -maxdepth 2 -iname '*.exe' \
      ! -iname '*crash*' ! -iname 'unins*' ! -iname '*setup*' ! -iname '*redist*' | head -n1)"
    [ -n "$exe" ] || { echo "No .exe found in $dir" >&2; exit 1; }

    # Steam AppID from the steamcmd manifest lets Proton apply game fixes.
    appid="$(ls "$dir"/steamapps/appmanifest_*.acf 2>/dev/null | head -n1 | grep -o '[0-9]\+\.acf' | cut -d. -f1 || true)"

    cd "$(dirname "$exe")"
    GAMEID="umu-''${appid:-0}" exec ${pkgs.umu-launcher}/bin/umu-run "$exe"
  '';
in
{
  home.packages = [
    pkgs.steamcmd
    pkgs.umu-launcher
    play
  ];
}
