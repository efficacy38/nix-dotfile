{
  pkgs,
  lib,
  ...
}:
{
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
    initrd.systemd.emergencyAccess = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzWsdkvpAQzPAjKuL9H3H+No8zaqhdvFFBdKAkTS0Kp efficacy38@phoenixton"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
