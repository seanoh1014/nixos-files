# Local packages

## Desktop with Linux computer use

The `chatgpt-desktop` flake output and Home Manager use the pinned
`codex-desktop-linux` input's `codex-desktop-computer-use-ui` package.
Launch it with `codex-desktop`. Enable native access in
Settings → Computer use → Any App.

The Niri system module enables `ydotool` and adds `ohsean` to its group.
Apply both configurations, then log out and back in:

```console
sudo nixos-rebuild switch --flake .#thinkpad-t14
home-manager switch --impure --flake .#ohsean
```

Ask the app to check Linux Computer Use readiness before using native control.
Update the community package with `nix flake update codex-desktop-linux`.

## Original official-package fallback

`chatgpt-desktop.nix` repackages OpenAI's official x86_64 Debian package for
NixOS. The upstream version and SHA-256 are pinned, so updating the flake does
not silently replace the application.

Build this fallback directly with:

```console
nix-build -E 'let pkgs = import <nixpkgs> { config.allowUnfree = true; }; in pkgs.callPackage ./packages/chatgpt-desktop.nix {}'
```

This fallback is retained for reference and is not installed by Home Manager.

### Updating

1. Read `Version`, `Filename`, and `SHA256` from OpenAI's amd64 package index:
   `https://persistent.oaistatic.com/codex-app-prod/linux/deb/dists/stable/main/binary-amd64/Packages`
2. Replace `version`, the versioned source URL if its path changed, and `hash`
   in `chatgpt-desktop.nix`. Convert the index's hexadecimal checksum with:

   ```console
   nix hash convert --hash-algo sha256 --to sri CHECKSUM
   ```

3. Rebuild the package and the Home Manager activation package.

The first launch of each version copies only the bundled plugin resources
(currently about 39 MiB) to `~/.cache/chatgpt-nix/`. This is necessary because
the application adjusts those copied manifests at runtime, while files in the
Nix store are intentionally read-only. The cache also contains links to the
immutable Codex and Node runtimes because the resource-path override is used by
the Chrome bridge as well as the plugin loader.
