{ ... }:

{
  imports = [
    ../../nixos/configuration.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "thinkpad-t14";
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.kernelParams = [ "psmouse.synaptics_intertouch=1" ];

  # This laptop exposes the internal speakers and headphone jack as separate
  # UCM profiles. Prefer the speaker profile and its sink so DisplayPort audio
  # from a speakerless monitor cannot silently become the default output.
  services.pipewire.wireplumber.extraConfig."51-thinkpad-speakers" = {
    "device.profile.priority.rules" = [
      {
        matches = [
          {
            "device.name" = "alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic";
          }
        ];
        actions."update-props".priorities = [
          "HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)"
          "HiFi (HDMI1, HDMI2, HDMI3, Headphones, Mic1, Mic2)"
        ];
      }
    ];

    "monitor.alsa.rules" = [
      {
        matches = [
          {
            "node.name" = "~alsa_output\\.pci-0000_00_1f\\.3-platform-skl_hda_dsp_generic\\.HiFi__Speaker__sink";
          }
        ];
        actions."update-props"."priority.session" = 1200;
      }
      {
        matches = [
          {
            "node.name" = "~alsa_output\\.pci-0000_00_1f\\.3-platform-skl_hda_dsp_generic\\.HiFi__HDMI.*__sink";
          }
        ];
        actions."update-props"."priority.session" = 500;
      }
    ];
  };
}
