{ pinnedPkgs }:

pinnedPkgs.dwmblocks.overrideAttrs (oldAttrs: rec {
  src = builtins.fetchTarball {
  url = "https://github.com/seanoh1014/dwmblocks-torrinfail/tarball/master";
  sha256 = "1cw78y7i9373a0s3i7ny1b45lizq9b4hxrrqhvrra8ayl4fmqrcm";
  };
  patches = (old.patches or []) ++ [ ./patches/dwmblocks-statuscmd.diff ];
})
