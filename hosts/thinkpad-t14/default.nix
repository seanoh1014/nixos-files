{ ... }:

{
  imports = [
    ../../nixos/configuration.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "thinkpad-t14";
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.kernelParams = [ "psmouse.synaptics_intertouch=1" ];
}
