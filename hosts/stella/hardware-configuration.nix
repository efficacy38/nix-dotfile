# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "uas"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d09c7fde-1b73-4810-b66f-eb52c7d83e87";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A6C3-69D4";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/d09c7fde-1b73-4810-b66f-eb52c7d83e87";
    fsType = "btrfs";
    options = [ "subvol=@nix" ];
    neededForBoot = true;
  };

  fileSystems."/persistent" = {
    device = "/dev/disk/by-uuid/d09c7fde-1b73-4810-b66f-eb52c7d83e87";
    fsType = "btrfs";
    options = [ "subvol=persistent" ];
    neededForBoot = true;
  };

  fileSystems."/home/efficacy38/.cache" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "defaults"
      "size=2G"
      "mode=744"
      "uid=1000"
    ];
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s13f0u1u4c2.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
