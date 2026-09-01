{ ... }:

{
  imports = [
    ../../nixos/configuration.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "gram";
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
}
