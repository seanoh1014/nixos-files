# MCP server for controlling the niri desktop from Claude Desktop. niri itself
# is taken from the running system so its IPC always matches the compositor.
{
  lib,
  python3,
  writeShellApplication,
  grim,
  sway-unwrapped,
  wtype,
  ydotool,
}:

writeShellApplication {
  name = "desktop-control-mcp";
  runtimeInputs = [
    grim
    sway-unwrapped # swaymsg, for Claude's workspace
    wtype
    ydotool
  ];
  text = ''
    export PATH="$PATH:/run/current-system/sw/bin"
    exec ${lib.getExe python3} ${./server.py} "$@"
  '';
}
