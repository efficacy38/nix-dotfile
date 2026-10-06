{ pkgs, ... }:
{
  # Bootloader.
  boot = {
    supportedFilesystems = [ "zfs" ];
    kernelModules = [ "kvm-intel" ];
    tmp.useTmpfs = true;
  };

  # services
  services.openssh.enable = true;
  services.nfs.server.enable = true;

  environment.systemPackages = with pkgs; [
    nut
  ];
  environment.variables.EDITOR = "vim";

  programs.zsh.enable = true;
}
