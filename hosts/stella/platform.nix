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

  # Use the mq-deadline I/O scheduler for the NVMe system disk (kernel default is none).
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme0n1", ATTR{queue/scheduler}="mq-deadline"
  '';

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
