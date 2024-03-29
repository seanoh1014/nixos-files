{ config, lib, pkgs, ... }:

{
  systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    extraConfig = ''
      # See https://wiki.hyprland.org/Configuring/Monitors/
      monitor=eDP-1,1920x1080@60,0x0,1

      # See https://wiki.hyprland.org/Configuring/Keywords/ for more

      # Execute your favorite apps at launch
      #exec-once = /usr/lib/polkit-kde-authentication-agent-1 & hyprpaper & dunst

      # Source a file (multi-file configs)
      # source = ~/.config/hypr/myColors.conf

      # Some default env vars.
      env = XCURSOR_SIZE,24

      # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
      input {
      kb_layout = us
      kb_variant =
      kb_model =
      kb_options=caps:escape
      kb_rules =

      follow_mouse = 1

      touchpad {
          natural_scroll = no
      }

      sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }

      general {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      gaps_in = 5
      gaps_out = 20
      border_size = 2
      col.active_border = 0xffb4befe
      col.inactive_border = 0xff45475a

      layout = dwindle
      }

      decoration {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more

      rounding = 10
      blur = yes
      blur_size = 3
      blur_passes = 1
      blur_new_optimizations = on

      drop_shadow = yes
      shadow_range = 4
      shadow_render_power = 3
      col.shadow = rgba(1a1a1aee)
      }

      animations {
      enabled = yes

      bezier = md3_decel, 0.05, 0.7, 0.1, 1
      animation = windowsIn, 1, 6, md3_decel, slide
      animation=windowsOut, 1,6,md3_decel,slide
      animation=windowsMove, 1,6,md3_decel,slide
      animation=fade, 1, 10, md3_decel
      animation=workspaces, 1, 7, md3_decel,slide
      animation=specialWorkspace, 1, 8, md3_decel, slide
      }

      dwindle {
      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
      preserve_split = yes # you probably want this
      }

      master {
      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      new_is_master = true
      }

      gestures {
      # See https://wiki.hyprland.org/Configuring/Variables/ for more
      workspace_swipe = off
      }

      # Example per-device config
      # See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
      device:epic-mouse-v1 {
      sensitivity = -0.5
      }

      # Example windowrule v1
      # windowrule = float, ^(kitty)$
      # Example windowrule v2
      # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more


      # See https://wiki.hyprland.org/Configuring/Keywords/ for more
      $mainMod = ALT

      bind = $mainMod SHIFT, Q, killactive,
      bind = $mainMod SHIFT, RETURN, exec, kitty
      bind = $mainMod, B, exec, brave
      #bind = $mainMod, SPACE, exec, wofi --show drun
      bind = $mainMod SHIFT, E, exit, 
      #bind = $mainMod, E, exec, dolphin
      bind = $mainMod, F, togglefloating, 
      bind = $mainMod, P, pseudo, # dwindle
      bind = $mainMod, J, togglesplit, # dwindle

      bind = , XF86MonBrightnessUp, exec, changebrightness up
      bind = , XF86MonBrightnessDown, exec, changebrightness down
      bind = , XF86AudioPrev, exec, playerctl prev
      bind = , XF86AudioNext, exec, playerctl next
      bind = , XF86AudioPlay, exec, playerctl play-pause
      bind = , XF86AudioRaiseVolume, exec, changevolume up
      bind = , XF86AudioLowerVolume, exec, changevolume down
      bind = , XF86AudioMute, exec, changevolume mute

      # Move focus with mainMod + arrow keys
      bind = $mainMod, H, movefocus, l
      bind = $mainMod, L, movefocus, r
      bind = $mainMod, K, movefocus, u
      bind = $mainMod, J, movefocus, d

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow
    '';
  };
}
