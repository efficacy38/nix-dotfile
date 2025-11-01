{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let

in
{
  imports = [
    # custom modules
    ../../modules
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # nixos-hardware
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

  myNixOS.bundles.common.enable = true;
  myNixOS.bundles.desktop-hyprland.enable = true;
  myNixOS.bundles.steam.enable = true;

  myNixOS.fprintd.enable = true;
  myNixOS.cscc-work.enable = true;
  myNixOS.main-user.userConfig = ./home.nix;
  myNixOS.tailscale.enable = true;
  myNixOS.tailscale.asRouter = false;
  myNixOS.impermanence.enable = true;
  myNixOS.backup.enable = true;
  myNixOS.battery-health.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  boot.tmp.useTmpfs = lib.mkDefault true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking related
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.hostName = "stella"; # Define your hostname.

  services.solaar.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    sof-firmware
    gparted
  ];

  # don't know why enable asusd module don't auto start asusd service
  systemd.services.asusd.enable = lib.mkForce true;

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  networking.extraHosts = ''
    10.2.2.99   minio-backup.test.cc.cs.nctu.edu.tw
  '';

  networking.firewall.enable = lib.mkForce false;

  system.stateVersion = "24.11";
}
