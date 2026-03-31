{ pinnedPkgs }:

pinnedPkgs.dwmblocks.overrideAttrs (oldAttrs: rec {
  src = builtins.fetchTarball {
  url = "https://github.com/seanoh1014/dwmblocks-torrinfail/tarball/master";
  sha256 = "046mwfr06f5ppnb6l72bqs160hdw1iq02ss4kpbjydrfjh87p70z";
  };
  patches = [ ./patches/dwmblocks-statuscmd.diff ];
})
