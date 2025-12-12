{ pkgs, ... }:
{
  imports = [
    # custom modules
    ../../modules
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.tmp.useTmpfs = true;

  # module related options
  myNixOS.bundles.common.enable = true;
  myNixOS.incus.enable = true;
  myNixOS.common.resolvedDnssec = true;
  myNixOS.nftables.enable = true;
  myNixOS.steam.enable = false;
  myNixOS.desktop.enable = false;
  myNixOS.desktop.zramEnable = false;
  myNixOS.cscc-work.enable = false;

  # services
  services.openssh.enable = true;
  services.nfs.server.enable = true;
  # Enable networking related
  networking.hostName = "homelab-test"; # Define your hostname.

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nut
  ];
  environment.variables.EDITOR = "vim";

  programs.zsh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  system.stateVersion = "24.05";
}
