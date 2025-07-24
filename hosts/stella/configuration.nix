{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let

  secretpath = builtins.toString inputs.nix-secrets;
  personal-s3-secret = {
    sopsFile = "${secretpath}/secrets/backup.yaml";
    format = "yaml";
  };
in
{
  imports = [
    # custom modules
    ../../modules
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # nixos-hardware
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

  main-user.enable = true;
  main-user.userName = "efficacy38";
  main-user.userConfig = ./home.nix;
  my-steam.enable = true;
  my-steam.hidpi = false;
  my-desktop.enable = true;
  my-desktop.zramEnable = false;
  my-desktop.hyprlandEnable = true;
  my-desktop.kdeEnable = false;
  cscc-work.enable = true;
  my-tailscale.enable = true;
  my-tailscale.asRouter = false;
  my-impermanence.enable = true;

  sops.secrets."homelab-1/password" = personal-s3-secret;
  sops.secrets."homelab-1/accessKey" = personal-s3-secret;
  sops.secrets."homelab-1/secretKey" = personal-s3-secret;

  services.kopia = {
    enabled = true;
    instances = {
      homelab = {
        enabled = true;
        passwordFile = config.sops.secrets."homelab-1/password".path;
        path = "/persistent";
        repository = {
          s3.bucket = "personal-backups";
          s3.endpoint = "s3.csjhuang.net";
          s3.accessKeyFile = config.sops.secrets."homelab-1/accessKey".path;
          s3.secretKeyFile = config.sops.secrets."homelab-1/secretKey".path;
        };

        policy = {
          retention = {
            keepLatest = 5;
            keepDaily = 30;
            keepWeekly = 4;
            keepMonthly = 3;
            keepAnnual = 0;
          };

          compression = {
            compressorName = "pgzip";
            neverCompress = [
              "*.zip"
              "*.tar"
              "*.gz"
              "*.tgz"
              "*.xz"
              "*.bz2"
              "*.7z"
              "*.rar"
              "*.iso"
            ];
          };
        };
      };
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  boot.tmp.useTmpfs = lib.mkDefault true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking related
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.hostName = "stella"; # Define your hostname.

  services.solaar.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    sof-firmware
    gparted
  ];

  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 30;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # don't know why enable asusd module don't auto start asusd service
  systemd.services.asusd.enable = lib.mkForce true;

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  networking.extraHosts = ''
    10.2.2.99   minio-backup.test.cc.cs.nctu.edu.tw
  '';

  networking.firewall.enable = lib.mkForce false;

  system.stateVersion = "24.11";
}
