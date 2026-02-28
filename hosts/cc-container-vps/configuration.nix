{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    # (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
    # ./hardware-configuration.nix
  ];

  my = {
    bundles.common.enable = true;
    users.efficacy38 = {
      type = "minimal";
      extraHomeConfig = import ./home.nix;
    };
    # system.impermanence.enable = true;
    system.systemdInitrd = {
      enable = true;
      debug = true;
    };
  };

  services.lvm.enable = true;
  boot = {
    initrd = {
      kernelModules = [
        "dm_mod"
        "dm-snapshot"
      ];
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ]
      # vmware vm
      ++ [
        "ata_piix"
        "vmw_pvscsi"
        "sr_mod"
      ];
      services.lvm.enable = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = lib.mkDefault "cc-container-vps";

  networking.interfaces.ens192 = {
    useDHCP = true;
  };
  networking.interfaces.ens224 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "140.113.168.232";
        prefixLength = 24;
      }
    ];
  };

  networking.defaultGateway = "140.113.168.254";
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  networking.firewall.enable = lib.mkForce false;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzWsdkvpAQzPAjKuL9H3H+No8zaqhdvFFBdKAkTS0Kp efficacy38@phoenixton"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";
}
