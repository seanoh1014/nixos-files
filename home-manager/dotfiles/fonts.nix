{ pkgs, ... }:

{
  # Use the maintained Nixpkgs package instead of storing another font copy in
  # this repository.
  home.packages = [ pkgs.nerd-fonts.symbols-only ];
}
