{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # custom modules
    ../../modules
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.solaar.nixosModules.default
    inputs.impermanence.nixosModules.impermanence

    # nixos-hardware
    # inputs.nixos-hardware.nixosModules.common-cpu-intel
  ];

  main-user.enable = true;
  main-user.userName = "efficacy38";
  main-user.userConfig = ./home.nix;
  my-steam.enable = true;
  my-steam.hidpi = false;
  my-desktop.enable = true;
  my-desktop.zramEnable = false;
  my-desktop.hyprlandEnable = true;
  my-desktop.kdeEnable = true;
  cscc-work.enable = true;
  my-tailscale.enable = true;
  my-tailscale.asRouter = false;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.useTmpfs = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking related
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.hostName = "stella"; # Define your hostname.
  networking.extraHosts = ''
    10.1.0.131   imap.cs.nycu.edu.tw
  '';

  services.solaar.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    sof-firmware
  ];
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  system.stateVersion = "24.11";
}
