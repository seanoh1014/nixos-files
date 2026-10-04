{ lib, rustPlatform, fetchFromGitHub }:

let
  src = fetchFromGitHub {
    owner = "am-kantox";
    repo = "fbii";
    rev = "cd91aa01a159a46c1d3599f32d044fe6c91f1e47";
    hash = "sha256-J/hvcxWzgrJILx+gdTdGFJEpuTob2jqq3yNr/vDjzBM=";
  };
in
rustPlatform.buildRustPackage {
  inherit src;
  pname = "fbii";
  version = "0.1.0-unstable-2026-10-04";

  cargoLock.lockFile = "${src}/Cargo.lock";

  doCheck = false;

  meta = {
    description = "Terminal FB2/EPUB reader with inline images (Kitty, Sixel, iTerm2)";
    homepage = "https://github.com/am-kantox/fbii";
    license = lib.licenses.mit;
    mainProgram = "fbii";
  };
}
