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

    # nixos-hardware
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-cpu-amd-raphael-igpu
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-hidpi
  ];

  myNixOS.bundles.common.enable = true;
  myNixOS.main-user.userConfig = ./home.nix;
  myNixOS.bundles.desktop-hyprland.enable = true;

  myNixOS.steam.enable = true;
  myNixOS.steam.hidpi = false;
  myNixOS.cscc-work.enable = true;
  myNixOS.tailscale.enable = true;
  myNixOS.tailscale.asRouter = false;
  myNixOS.impermanence.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "reboot=bios"
    "amdgpu.sg_display=0"
  ];
  boot.tmp.useTmpfs = true;

  # Enable networking related
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.hostName = "phoenixton"; # Define your hostname.
  networking.extraHosts = ''
    10.1.0.131   imap.cs.nycu.edu.tw
  '';

  services.udev.extraRules = ''
    # make amdgpu card don't display some artifact
        KERNEL=="card1", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="high"
  '';

  services.solaar.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  system.stateVersion = "24.11";
}
