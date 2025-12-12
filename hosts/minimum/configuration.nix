{
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    # (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
    # ./hardware-configuration.nix
  ];

  my.bundles.common.enable = true;

  my.main-user.userConfig = ./home.nix;
  # my.system.impermanenceEnable = true;
  my.system.systemdInitrdEnable = true;
  my.system.systemdInitrdDebug = true;

  services.lvm.enable = true;
  boot.initrd.kernelModules = [
    "dm_mod"
    "dm-snapshot"
  ];
  boot.initrd.availableKernelModules = [
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
  boot.initrd.services.lvm.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = lib.mkDefault "TEMPLATE_HOSTNAME";

  networking.firewall.enable = lib.mkForce false;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzWsdkvpAQzPAjKuL9H3H+No8zaqhdvFFBdKAkTS0Kp efficacy38@phoenixton"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.stateVersion = "24.11";
}
