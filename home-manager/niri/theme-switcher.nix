{ config, lib, pkgs, ... }:

let
  stateDir = "${config.xdg.stateHome}/niri-theme";

  # Add another named palette here when you want another theme. The command
  # and generated application fragments do not need to change.
  themes = {
    default = import ./themes/default.nix;
    gruvbox = import ./themes/gruvbox.nix;
    latte = import ./themes/latte.nix;
    storm = import ./themes/storm.nix;
  };

  renderTheme = name: theme:
    let
      regularColors = lib.imap0 (index: color: "regular${toString index}=${color}") theme.terminal.regular;
      brightColors = lib.imap0 (index: color: "bright${toString index}=${color}") theme.terminal.bright;
    in
    pkgs.linkFarm "niri-theme-${name}" [
      {
        name = "niri.kdl";
        path = pkgs.writeText "niri-${name}.kdl" ''
          layout {
              focus-ring {
                  active-color "#${theme.accent}80"
                  inactive-color "#${theme.panel}80"
              }

              tab-indicator {
                  active-color "#${theme.tabActive}FF"
                  inactive-color "#${theme.tabInactive}FF"
              }
          }
        '';
      }
      {
        name = "waybar.css";
        path = pkgs.writeText "waybar-${name}.css" ''
          window#waybar#waybar {
            background: #${theme.panel};
            color: #${theme.foreground};
          }

          window#waybar #workspaces button {
            color: #${theme.foreground};
          }

          window#waybar #workspaces button.active,
          window#waybar #workspaces button.active:hover {
            background: #${theme.accent};
          }

          window#waybar .cffi-niri-windows label {
            color: #${theme.accent};
          }

          window#waybar #network,
          window#waybar #pulseaudio,
          window#waybar #battery,
          window#waybar #clock {
            color: #${theme.foreground};
          }
        '';
      }
      {
        name = "foot.ini";
        path = pkgs.writeText "foot-${name}.ini" ''
          [colors-dark]
          foreground=${theme.terminal.foreground}
          background=${theme.terminal.background}
          cursor=${theme.terminal.cursorBackground} ${theme.terminal.cursorForeground}
          ${lib.concatStringsSep "\n" regularColors}
          ${lib.concatStringsSep "\n" brightColors}
        '';
      }
      {
        name = "fuzzel.ini";
        path = pkgs.writeText "fuzzel-${name}.ini" ''
          [colors]
          background=${theme.background}ff
          text=${theme.foreground}ff
          match=${theme.pink}ff
          selection=${theme.selection}ff
          selection-text=${theme.foreground}ff
          selection-match=${theme.accent}ff
          border=${theme.accent}ff
        '';
      }
      {
        name = "mako.ini";
        path = pkgs.writeText "mako-${name}.ini" ''
          background-color=#${theme.background}
          text-color=#${theme.foreground}
          border-color=#${theme.accent}
        '';
      }
      {
        name = "wob.ini";
        path = pkgs.writeText "wob-${name}.ini" ''
          timeout = 1000
          max = 100
          width = 240
          height = 14
          border_offset = 0
          border_size = 2
          bar_padding = 2
          anchor = top right
          margin = 20 16 0 0
          border_color = ${lib.toUpper theme.foreground}FF
          background_color = ${lib.toUpper theme.panel}FF
          bar_color = ${lib.toUpper theme.foreground}FF
          overflow_mode = nowrap

          [style.muted]
          bar_color = ${lib.toUpper theme.mutedBar}FF
        '';
      }
    ];

  renderedThemes = lib.mapAttrs renderTheme themes;
  themeNames = lib.attrNames renderedThemes;
  themeChoices = lib.concatMapStringsSep "\n" (name: ''
    ${lib.escapeShellArg name}) source_dir=${lib.escapeShellArg (toString renderedThemes.${name})} ;;
  '') themeNames;
  availableThemes = lib.concatStringsSep " " themeNames;

  themeSet = pkgs.writeShellScriptBin "niri-theme-set" ''
    set -eu

    reload=true
    if [ "''${1:-}" = "--initialize" ]; then
      reload=false
      shift
    fi

    case "''${1:-}" in
      --list)
        printf '%s\n' ${lib.concatMapStringsSep " " lib.escapeShellArg themeNames}
        exit 0
        ;;
      "")
        echo "usage: niri-theme-set [--initialize] <theme>" >&2
        echo "available: ${availableThemes}" >&2
        exit 2
        ;;
    esac

    theme="$1"
    case "$theme" in
      ${themeChoices}
      *)
        echo "unknown theme: $theme" >&2
        echo "available: ${availableThemes}" >&2
        exit 2
        ;;
    esac

    state_dir=${lib.escapeShellArg stateDir}
    ${pkgs.coreutils}/bin/install -d -m 700 "$state_dir"

    for file in niri.kdl waybar.css foot.ini fuzzel.ini mako.ini wob.ini; do
      ${pkgs.coreutils}/bin/install -m 600 "$source_dir/$file" "$state_dir/.$file.new"
      ${pkgs.coreutils}/bin/mv -f "$state_dir/.$file.new" "$state_dir/$file"
    done

    printf '%s\n' "$theme" > "$state_dir/.selected.new"
    ${pkgs.coreutils}/bin/mv -f "$state_dir/.selected.new" "$state_dir/selected"

    if [ "$reload" = true ]; then
      # Niri notices its included fragment automatically. The other commands
      # only touch processes that are already running; no theme daemon remains.
      ${pkgs.procps}/bin/pkill -SIGUSR2 waybar 2>/dev/null || true
      ${pkgs.mako}/bin/makoctl reload 2>/dev/null || true
      ${pkgs.systemd}/bin/systemctl --user stop wob.service 2>/dev/null || true
    fi

    echo "theme: $theme"
  '';
in
{
  home.packages = [ themeSet ];

  # Each include overlays the existing static colors. Removing this module's
  # import therefore restores the original configuration without other edits.
  xdg.configFile."niri/config.kdl".text = lib.mkAfter ''

    include "${stateDir}/niri.kdl"
  '';

  xdg.configFile."waybar/style.css".text = lib.mkBefore ''
    @import url("${stateDir}/waybar.css");

  '';

  xdg.configFile."foot/foot.ini".text = lib.mkAfter ''

    [main]
    include=${stateDir}/foot.ini
  '';

  xdg.configFile."fuzzel/fuzzel.ini".text = lib.mkAfter ''

    [main]
    include=${stateDir}/fuzzel.ini
  '';

  xdg.configFile."mako/config".text = lib.mkAfter ''

    include=${stateDir}/mako.ini
  '';

  # Wob has no include directive. This is the only forced override, and it
  # disappears along with this module.
  systemd.user.services.wob.Service.ExecStart = lib.mkForce "${pkgs.wob}/bin/wob --config ${stateDir}/wob.ini";

  home.activation.initializeNiriTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    selected=default
    if [ -r ${lib.escapeShellArg "${stateDir}/selected"} ]; then
      IFS= read -r selected < ${lib.escapeShellArg "${stateDir}/selected"}
    fi

    ${themeSet}/bin/niri-theme-set --initialize "$selected" \
      || ${themeSet}/bin/niri-theme-set --initialize default
  '';
}
