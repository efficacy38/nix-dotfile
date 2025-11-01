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
    # custom modules
    ../../modules
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
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
  myNixOS.bundles.common.enable = true;
  myNixOS.steam.enable = false;
  myNixOS.desktop.enable = false;
  myNixOS.desktop.zramEnable = false;
  myNixOS.cscc-work.enable = false;
  myNixOS.tailscale.enable = true;
  myNixOS.tailscale.asRouter = true;
  # services.kopia.enable = false;

  # systemd-resolved
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    dnsovertls = "true";
  };

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
  networking.nftables.enable = true;
  networking.firewall.enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    man-db
    git
    vim
    wget
    curl
    htop
    openfortivpn
    incus-lts
    tcpdump

    bcachefs-tools
    nut
  ];
  environment.variables.EDITOR = "vim";

  programs.zsh.enable = true;
  virtualisation.incus = {
    enable = true;
    ui = {
      enable = true;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  system.stateVersion = "24.05";
}
