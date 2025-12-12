{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # nixos-hardware
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

  my.bundles.common.enable = true;
  my.bundles.desktop-hyprland.enable = true;
  my.bundles.steam.enable = true;

  my.desktop.fprintd.enable = true;
  my.desktop.batteryHealth.enable = true;
  my.main-user.userConfig = ./home.nix;
  my.devpack = {
    enable = true;
    csccUtil.enable = true;
    tailscale.enable = true;
  };
  my.system.impermanence.enable = true;
  my.system.systemdInitrd.enable = true;
  # my.system.systemdInitrd.debug = true;
  my.system.backup.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking related
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.hostName = "stella"; # Define your hostname.

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    sof-firmware
    gparted
  ];

  # don't know why enable asusd module don't auto start asusd service
  systemd.services.asusd.enable = lib.mkForce true;

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
