final: prev:
  let
    rustChannel = inputs.rust-overlay.packages.x86_64-linux.rust_1_81_0;
  in
  {
    kime = prev.kime.override {
      rustPlatform = prev.makeRustPlatform {
        rustc = rustChannel;
        cargo = rustChannel;
      };
      rustc = rustChannel;
      cargo = rustChannel;
    };
  };
