{
  inputs,
  config,
  pkgs,
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

  # boot.supportedFilesystems = [ "bcachefs" "zfs" ];
  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.tmp.useTmpfs = true;
  boot.extraModprobeConfig = ''
    # only allow 50% arc cache is enabled
    options zfs zfs_arc_max_percent=50
  '';

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

  # module related options
  my.bundles.homelab.enable = true;
  my.devpack.tailscaleEnable = true;
  my.devpack.tailscaleAsRouter = true;

  services.openiscsi = {
    enable = true;
    name = "iqn.2025-02.net.csjhuang:homelab-1";
  };
  services.target.enable = true;

  # services
  services.openssh.enable = true;
  services.nfs.server.enable = true;
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
