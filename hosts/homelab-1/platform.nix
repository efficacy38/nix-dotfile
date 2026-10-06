{
  inputs,
  config,
  lib,
  ...
}:
let
  secretpath = builtins.toString inputs.nix-secrets;

  common-secret = {
    sopsFile = "${secretpath}/secrets/common.yaml";
    format = "yaml";
  };
in
{
  boot = {
    supportedFilesystems = [ "zfs" ];
    kernelModules = [ "kvm-intel" ];
    tmp.useTmpfs = true;
    extraModprobeConfig = ''
      # only allow 50% arc cache is enabled
      options zfs zfs_arc_max_percent=50
    '';
  };

  sops.secrets."nut_sever_password" = common-secret;

  power.ups = {
    enable = true;
    ups."serverups" = {
      driver = "nutdrv_qx";
      port = "auto";
    };
    users = {
      admin = {
        passwordFile = config.sops.secrets."nut_sever_password".path;
        instcmds = [ "all" ];
        actions = [ "set" ];
      };
    };
    upsd.listen = [
      {
        address = "::1";
        port = 3493;
      }
      {
        address = "0.0.0.0";
        port = 3493;
      }
    ];
    upsmon = {
      enable = false;
    };
  };

  virtualisation = {
    podman.enable = lib.mkForce true;
    docker.enable = lib.mkForce true;
  };

  services = {
    openiscsi = {
      enable = true;
      name = "iqn.2025-02.net.csjhuang:homelab-1";
    };
    target.enable = true;
    nfs.server.enable = true;
  };

  environment.variables.EDITOR = "vim";

  programs.zsh.enable = true;
}
