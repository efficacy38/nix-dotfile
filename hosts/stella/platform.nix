{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  my.desktop = {
    fprintd.enable = true;
    batteryHealth.enable = true;
    steam.hidpi = lib.mkForce true;
  };

  environment.systemPackages = with pkgs; [
    sof-firmware
    gparted
  ];

  # The module does not enable this service automatically on this host.
  systemd.services.asusd.enable = lib.mkForce true;
}
