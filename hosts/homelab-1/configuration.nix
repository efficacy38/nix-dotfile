{
  inputs,
  config,
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
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

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

  my = {
    bundles.homelab.enable = true;
    devpack = {
      tailscale.enable = true;
      tailscaleAsRouter = true;
    };
  };

  services = {
    openiscsi = {
      enable = true;
      name = "iqn.2025-02.net.csjhuang:homelab-1";
    };
    target.enable = true;
    nfs.server.enable = true;
  };
  # Enable networking related
  networking.hostName = "homelab-1"; # Define your hostname.

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [ ];
  environment.variables.EDITOR = "vim";

  programs.zsh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  system.stateVersion = "24.05";
}
