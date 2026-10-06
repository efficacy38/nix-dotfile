{ lib, ... }:
{
  boot = {
    supportedFilesystems = [ "zfs" ];
    initrd.systemd.enable = true;
    tmp.useTmpfs = true;
    extraModprobeConfig = ''
      # only allow 50% arc cache is enabled
      options zfs zfs_arc_max_percent=50
    '';
  };

  # FIXME: this should add extra module option to make sure this machine would
  # not sleep
  systemd.sleep.settings.Sleep = {
    AllowSuspend = lib.mkForce "no";
    AllowHibernation = lib.mkForce "no";
    AllowHybridSleep = lib.mkForce "no";
    AllowSuspendThenHibernate = lib.mkForce "no";
  };

  services.nfs.server.enable = true;

  my = {
    desktop = {
      fprintd.enable = true;
      batteryHealth.enable = true;
    };
    system = {
      netbird.enable = true;
      impermanence.enable = false;
      incus = {
        enable = true;
        ui.enable = true;
      };
      # TODO: add more persistent directory, currently only user home
      backup = {
        enable = true;
        path = "/home/efficacy38";
      };
    };
  };

  environment.variables.EDITOR = "vim";

  programs.zsh.enable = true;
}
