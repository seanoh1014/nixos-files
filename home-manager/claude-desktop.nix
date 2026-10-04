{ pkgs, lib, ... }:

let
  desktopControl = pkgs.callPackage ../packages/desktop-control-mcp { };
  mcpServers = {
    # Controls your whole niri desktop by default. Claude's workspace (below)
    # is used only when a tool call asks for target "workspace".
    desktop-control = {
      command = lib.getExe desktopControl;
      env.DESKTOP_CONTROL_TARGET = "desktop";
    };
  };

  # Claude's workspace is a nested sway session in a window on the niri
  # desktop. It has its own seat, so Claude's cursor and keyboard focus never
  # take over yours. The MCP server starts it on demand; close the window or
  # `systemctl --user stop claude-workspace` to end it.
  workspaceConfig = pkgs.writeText "claude-workspace-sway.conf" ''
    default_border none
    focus_follows_mouse no
    exec printf '%s %s\n' "$SWAYSOCK" "$WAYLAND_DISPLAY" > "$XDG_RUNTIME_DIR/claude-workspace.env"
  '';

  # A browser profile of its own, so pages open inside the workspace instead
  # of in your running Brave.
  workspaceBrowser = pkgs.writeShellScriptBin "claude-workspace-browser" ''
    exec brave --user-data-dir="$HOME/.local/share/claude-workspace/brave" \
      --ozone-platform=wayland "$@"
  '';
in
{
  home.packages = [
    desktopControl
    workspaceBrowser
  ];

  systemd.user.services.claude-workspace = {
    Unit.Description = "Nested sway session for Claude's desktop control";
    Service = {
      ExecStart = "${lib.getExe' pkgs.sway-unwrapped "sway"} -c ${workspaceConfig}";
      ExecStopPost = "${lib.getExe' pkgs.coreutils "rm"} -f %t/claude-workspace.env";
      Environment = [
        "WLR_BACKENDS=wayland"
        "PATH=%h/.nix-profile/bin:/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin"
      ];
      # Apps in the workspace must use its own Xwayland, not the host's.
      UnsetEnvironment = [ "DISPLAY" ];
    };
  };

  # Claude Desktop rewrites this file with its own preferences, so it can't be
  # a read-only store link. Merge only the mcpServers entries into it.
  home.activation.claudeDesktopMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe pkgs.python3} - ${pkgs.writeText "mcp-servers.json" (builtins.toJSON mcpServers)} <<'EOF'
    import json, os, sys
    path = os.path.expanduser("~/.config/Claude/claude_desktop_config.json")
    try:
        with open(path) as f:
            config = json.load(f)
    except FileNotFoundError:
        config = {}
    with open(sys.argv[1]) as f:
        config.setdefault("mcpServers", {}).update(json.load(f))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path + ".tmp", "w") as f:
        json.dump(config, f, indent=2)
    os.replace(path + ".tmp", path)
    EOF
  '';
}
