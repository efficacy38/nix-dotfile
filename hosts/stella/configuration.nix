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

  my = {
    bundles = {
      common.enable = true;
      desktop-hyprland.enable = true;
      steam.enable = true;
    };
    desktop = {
      fprintd.enable = true;
      batteryHealth.enable = true;
    };
    users = {
      efficacy38 = {
        type = "desktop-user";
        extraHomeConfig = import ./home.nix;
      };
      gaming = {
        type = "minimal";
      };
    };
    devpack = {
      enable = true;
      csccUtil.enable = true;
      tailscale.enable = true;
    };
    system = {
      impermanence.enable = true;
      systemdInitrd.enable = true;
      # systemdInitrd.debug = true;
      backup.enable = true;
    };
  };

  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking related
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking = {
    hostName = "stella"; # Define your hostname.
    extraHosts = ''
      10.2.2.99   minio-backup.test.cc.cs.nctu.edu.tw
      127.0.0.1   ipa.cs.nctu.edu.tw keycloak.cs.nctu.edu.tw
    '';
    firewall.enable = lib.mkForce false;
  };

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

  system.stateVersion = "24.11";
}
