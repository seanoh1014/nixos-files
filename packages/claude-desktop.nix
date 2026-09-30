# Claude Desktop from the k3d3/claude-desktop-linux-flake source, built against
# this configuration's nixpkgs. Upstream still uses `nodePackages.asar`, which
# nixpkgs has removed; building with the system nixpkgs (rather than upstream's
# pinned one) also keeps glibc in step with Mesa, so GPU acceleration works.
{
  src,
  callPackage,
  buildFHSEnv,
  asar,
}:

let
  patchy-cnb = callPackage "${src}/pkgs/patchy-cnb.nix" { };
  claude-desktop = callPackage "${src}/pkgs/claude-desktop.nix" {
    inherit patchy-cnb;
    nodePackages = { inherit asar; };
  };
in
# Same FHS wrapper as upstream's `claude-desktop-with-fhs`, so MCP servers
# launched through npx, uvx, or docker can run.
buildFHSEnv {
  name = "claude-desktop";
  targetPkgs =
    pkgs: with pkgs; [
      docker
      glibc
      openssl
      nodejs
      uv
    ];
  runScript = "${claude-desktop}/bin/claude-desktop";
  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${claude-desktop}/share/applications/claude.desktop $out/share/applications/

    mkdir -p $out/share/icons
    cp -r ${claude-desktop}/share/icons/* $out/share/icons/
  '';
}
