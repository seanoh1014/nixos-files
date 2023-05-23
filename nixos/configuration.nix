# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ohsean = {
    isNormalUser = true;
    description = "ohsean";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    packages = with pkgs; [];
  };

  # Fonts for programs
  #fonts.fonts = with pkgs; [
  #  (nerdfonts.override { fonts = [ "FiraCode" ]; })
  #];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    #firefox
    #dmenu
    #st
    #xorg.xbacklight
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable dwm, dmenu, and st
  services.xserver.windowManager.dwm.enable = true;

  nixpkgs.overlays = [
    #(final: prev: {
      #dwm = prev.dwm.overrideAttrs (old: { src = pkgs/dwm ;});
      #dmenu = prev.dmenu.overrideAttrs (old: { src = pkgs/dmenu ;});
      #st = prev.st.overrideAttrs (old: { src = /home/ohsean/.config/home-manager/pkgs/st ;});
      #dwmblocks = prev.dwmblocks.overrideAttrs (old: { src = pkgs/dwmblocks ;});
    #})
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.passwordAuthentication = false;
    settings.kbdInteractiveAuthentication = false;
  #permitRootLogin = "yes";
  };
  # rtkit is optional but recommended
  #security.rtkit.enable = true;
  #services.pipewire = {
  #  enable = true;
  #  alsa.enable = true;
  #  alsa.support32Bit = true;
  #  pulse.enable = true;
  # If you want to use JACK applications, uncomment this
  #  jack.enable = true;
  #};
  environment.interactiveShellInit = ''
    alias vim='nvim'
  '';
  sound.enable = true;
  programs.light.enable = true;
  programs.zsh.enable = true;
  users.users.ohsean.shell = pkgs.zsh;
  boot.extraModprobeConfig = ''
    options snd slots=snd-hda-intel
  '';

  i18n = {
    inputMethod = {
      enabled = "kime";
      #kime.config = {
      #  indicator.icon_color = "White";
      #};
    };
  };



  security = {
    sudo = {
      enable = false;
    };
    doas = {
      enable = true;
      wheelNeedsPassword = false;
      extraRules = [{
        users = [ "ohsean" ];
        keepEnv = true;
        persist = true;  
      }];
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "python3.10-django-3.1.14"
  ];


  #services.xserver.synaptics.enable = true;

  #environment.shells = with pkgs; [ zsh ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
