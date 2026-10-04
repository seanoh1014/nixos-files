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

  # Dynamic wallpaper: every 15 minutes pick a random image and reload swaybg.
  # Just a shell loop and sleep on top of the existing swaybg, so nearly free.
  niriWallpaperCycle = pkgs.writeShellScriptBin "niri-wallpaper-cycle" ''
    state_file="''${XDG_STATE_HOME:-$HOME/.local/state}/niri/wallpaper"
    mkdir -p "''${state_file%/*}"
    while sleep "''${1:-900}"; do
      ${pkgs.findutils}/bin/find -L /home/ohsean/wallpaper -maxdepth 1 -type f \
        | ${pkgs.coreutils}/bin/shuf -n 1 > "$state_file"
      ${niriWallpaper}/bin/niri-wallpaper --reload
    done
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
        ${pkgs.swaylock}/bin/swaylock -f -c 000000
        ;;
      "Suspend")
        ${pkgs.swaylock}/bin/swaylock -f -c 000000
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

  niriAutoSuspend = pkgs.writeShellScriptBin "niri-auto-suspend" ''
    set -eu

    connected_displays="$(${pkgs.gnugrep}/bin/grep -l '^connected$' /sys/class/drm/card*-*/status | ${pkgs.coreutils}/bin/wc -l)"
    [ "$connected_displays" -le 1 ] || exit 0

    ac_online="$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/AC/online)"
    case "$1:$ac_online" in
      ac:1|battery:0) ;;
      *) exit 0 ;;
    esac

    ${pkgs.systemd}/bin/systemctl suspend
  '';

  # Pair newly opened tiled windows top/bottom in full-width columns on the
  # portrait display. A lone window remains one half-screen-tall tile, while
  # further pairs use Niri's normal horizontal scrolling.
  # Existing windows are recorded before events are handled, so starting or
  # restarting the helper does not rearrange them.
  niriPortraitStack = pkgs.writeShellScriptBin "niri-portrait-stack" ''
    set -u

    seen_ids=" "

    ${pkgs.niri}/bin/niri msg --json event-stream |
      while IFS= read -r event; do
        initial_ids="$(${pkgs.jq}/bin/jq -r '
          .WindowsChanged.windows? // empty | map(.id | tostring) | join(" ")
        ' <<< "$event")"
        if [ -n "$initial_ids" ]; then
          seen_ids="$seen_ids$initial_ids "

          continue
        fi

        closed_id="$(${pkgs.jq}/bin/jq -r '.WindowClosed.id? // empty' <<< "$event")"
        if [ -n "$closed_id" ]; then
          workspaces="$(${pkgs.niri}/bin/niri msg --json workspaces)"
          windows="$(${pkgs.niri}/bin/niri msg --json windows)"
          top_only_ids="$(${pkgs.jq}/bin/jq -r --argjson workspaces "$workspaces" '
            . as $windows |
            $workspaces[] |
            select(.output == "DP-2") |
            .id as $workspace_id |
            [$windows[] | select(
              .workspace_id == $workspace_id and .is_floating == false
            )] |
            group_by(.layout.pos_in_scrolling_layout[0]) |
            .[] |
            select(length == 1) |
            .[0].id
          ' <<< "$windows")"

          # Keep every unpaired top window half-height, including windows in
          # later scrolling columns rather than only the workspace's first.
          for top_id in $top_only_ids; do
            ${pkgs.niri}/bin/niri msg action set-window-width --id "$top_id" "100%"
            ${pkgs.niri}/bin/niri msg action set-window-height --id "$top_id" "50%"
          done
          continue
        fi

        window_id="$(${pkgs.jq}/bin/jq -r \
          '.WindowOpenedOrChanged.window.id? // empty' <<< "$event")"
        [ -n "$window_id" ] || continue

        case "$seen_ids" in
          *" $window_id "*) continue ;;
        esac
        seen_ids="$seen_ids$window_id "

        workspace_id="$(${pkgs.jq}/bin/jq -r '
          .WindowOpenedOrChanged.window? |
          select(.is_floating == false) |
          .workspace_id // empty
        ' <<< "$event")"
        [ -n "$workspace_id" ] || continue

        output="$(${pkgs.niri}/bin/niri msg --json workspaces |
          ${pkgs.jq}/bin/jq -r --argjson workspace_id "$workspace_id" '
            map(select(.id == $workspace_id))[0].output // empty
          ')"
        [ "$output" = "DP-2" ] || continue

        windows="$(${pkgs.niri}/bin/niri msg --json windows)"
        tiled_count="$(${pkgs.jq}/bin/jq -r \
          --argjson workspace_id "$workspace_id" '
            map(select(.workspace_id == $workspace_id and .is_floating == false)) | length
          ' <<< "$windows")"

        if [ "$tiled_count" -eq 1 ]; then
          ${pkgs.niri}/bin/niri msg action set-window-width --id "$window_id" "100%"
          ${pkgs.niri}/bin/niri msg action set-window-height --id "$window_id" "50%"
          continue
        fi

        column="$(${pkgs.jq}/bin/jq -r --argjson window_id "$window_id" '
          map(select(.id == $window_id))[0].layout.pos_in_scrolling_layout[0] // empty
        ' <<< "$windows")"
        [ -n "$column" ] || continue

        left_column_count="$(${pkgs.jq}/bin/jq -r \
          --argjson workspace_id "$workspace_id" \
          --argjson column "$column" '
            map(select(
              .workspace_id == $workspace_id and
              .is_floating == false and
              .layout.pos_in_scrolling_layout[0] == ($column - 1)
            )) | length
          ' <<< "$windows")"

        ${pkgs.niri}/bin/niri msg action set-window-width --id "$window_id" "100%"
        ${pkgs.niri}/bin/niri msg action set-window-height --id "$window_id" "50%"

        # Join a single window to the left, but never add a third row. If the
        # left column already holds a pair, this window starts the next pair.
        if [ "$left_column_count" -eq 1 ]; then
          ${pkgs.niri}/bin/niri msg action consume-or-expel-window-left --id "$window_id"
          ${pkgs.niri}/bin/niri msg action set-window-width --id "$window_id" "100%"
          ${pkgs.niri}/bin/niri msg action set-window-height --id "$window_id" "50%"
        fi
      done
  '';

  # Niri expels a window from a multi-window column when maximizing it and
  # never puts it back, so remember the stack and rejoin it on unmaximize.
  niriMaximizeToggle = pkgs.writeShellScriptBin "niri-maximize-toggle" ''
    set -u

    niri=${pkgs.niri}/bin/niri
    jq=${pkgs.jq}/bin/jq
    state_dir="$XDG_RUNTIME_DIR/niri-maximize"
    mkdir -p "$state_dir"

    pos() {
      $niri msg --json focused-window |
        $jq -r '.layout.pos_in_scrolling_layout // empty | map(tostring) | join(" ")'
    }

    output="$($niri msg --json focused-output | $jq -r '.name // empty')"
    if [ "$output" != "DP-2" ]; then
      exec $niri msg action maximize-window-to-edges
    fi

    id="$($niri msg --json focused-window | $jq -r '.id // empty')"
    [ -n "$id" ] || exit 0
    state="$state_dir/$id"
    read -r col row <<< "$(pos)"

    $niri msg action maximize-window-to-edges

    if [ -f "$state" ]; then
      read -r saved_col saved_row < "$state"
      rm -f "$state"
      # Only rejoin if the window is still where the maximize left it.
      [ "$col" = "$saved_col" ] || exit 0
      $niri msg action consume-or-expel-window-left
      [ "$saved_row" = 1 ] && $niri msg action move-window-up
      $niri msg action set-window-height "50%"
      exit 0
    fi

    read -r new_col _ <<< "$(pos)"
    if [ -n "$col" ] && [ "$new_col" != "$col" ]; then
      echo "$new_col $row" > "$state"
    fi
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
    swayidle
    swaylock
    vanilla-dmz
    wl-clipboard
    xwayland-satellite
    niriWallpaper
    niriWallpaperCycle
    niriPowerMenu
    niriAutoSuspend
    niriPortraitStack
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
              accel-profile "flat"
              accel-speed 0.8
          }

          mod-key "Alt"
      }

      output "eDP-1" {
          mode "1920x1080"
          scale 1
          position x=1080 y=420
      }

      // Portrait monitor to the left of the laptop display.
      output "DP-2" {
          mode "1920x1080"
          scale 1
          transform "90"
          position x=0 y=0
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

      // Claude's workspace (nested sway) opens without taking focus.
      window-rule {
          match app-id="^wlroots$"
          open-focused false
      }

      // Relaunch waybar if it crashes (e.g. when PipeWire restarts during a rebuild).
      spawn-sh-at-startup "while true; do waybar; sleep 1; done"
      spawn-at-startup "mako"
      spawn-at-startup "${niriWallpaper}/bin/niri-wallpaper"
      spawn-at-startup "${niriWallpaperCycle}/bin/niri-wallpaper-cycle"
      spawn-at-startup "${pkgs.swayidle}/bin/swayidle" "-w" "timeout" "300" "${pkgs.swaylock}/bin/swaylock -f -c 000000" "timeout" "600" "${pkgs.niri}/bin/niri msg action power-off-monitors" "resume" "${pkgs.niri}/bin/niri msg action power-on-monitors" "timeout" "900" "${niriAutoSuspend}/bin/niri-auto-suspend battery" "timeout" "1800" "${niriAutoSuspend}/bin/niri-auto-suspend ac" "before-sleep" "${pkgs.swaylock}/bin/swaylock -f -c 000000"
      spawn-at-startup "${niriPortraitStack}/bin/niri-portrait-stack"
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
          Mod+F hotkey-overlay-title="Maximize window" { spawn "${niriMaximizeToggle}/bin/niri-maximize-toggle"; }
          Mod+B hotkey-overlay-title="Toggle fullscreen" { fullscreen-window; }

          Mod+J hotkey-overlay-title="Focus column left (wrap)" { focus-column-left-or-last; }
          Mod+K hotkey-overlay-title="Focus column right (wrap)" { focus-column-right-or-first; }
          Mod+Shift+J hotkey-overlay-title="Move column left or to monitor left" { move-column-left-or-to-monitor-left; }
          Mod+Shift+K hotkey-overlay-title="Move column right or to monitor right" { move-column-right-or-to-monitor-right; }
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
          Mod+Alt+W hotkey-overlay-title="Toggle dynamic wallpaper" { spawn-sh "pkill -f 'bin/[n]iri-wallpaper-cycle' || niri-wallpaper-cycle"; }
          Mod+X hotkey-overlay-title="Lock and turn off displays" { spawn-sh "swaylock -f -c 000000 & sleep 0.2; niri msg action power-off-monitors"; }
          Mod+Shift+E hotkey-overlay-title="Open power menu" { spawn "niri-power-menu"; }

          // Wob displays the result; Wiremix is the interactive mixer alternative.
          XF86AudioLowerVolume allow-when-locked=true hotkey-overlay-title="Volume down" { spawn "niri-volume-wob" "down"; }
          XF86AudioMute allow-when-locked=true hotkey-overlay-title="Toggle mute" { spawn "niri-volume-wob" "mute"; }
          XF86AudioRaiseVolume allow-when-locked=true hotkey-overlay-title="Volume up" { spawn "niri-volume-wob" "up"; }
          XF86MonBrightnessDown allow-when-locked=true hotkey-overlay-title="Brightness down" { spawn "brightnessctl" "set" "5%-"; }
          XF86MonBrightnessUp allow-when-locked=true hotkey-overlay-title="Brightness up" { spawn "brightnessctl" "set" "+5%"; }
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
