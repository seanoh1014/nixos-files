{ pinnedPkgs }:

pinnedPkgs.dwmblocks.overrideAttrs (oldAttrs: rec {
  src = builtins.fetchTarball {
  url = "https://github.com/seanoh1014/dwmblocks-torrinfail/tarball/master";
  sha256 = "1jhgmk4kh5b5qlmsahx1iglmrx543d1s2jfrg0rh2inx6g6jdgk1";
  };
  patches = [ ./patches/dwmblocks-statuscmd.diff ];
})
