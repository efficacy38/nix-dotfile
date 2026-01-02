# Backup system configurations
_: {
  # NixOS: backup configuration (kopia)
  flake.nixosModules.system-backup =
    {
      inputs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.system;
      secretpath = builtins.toString inputs.nix-secrets;
      personal-s3-secret = {
        sopsFile = "${secretpath}/secrets/backup.yaml";
        format = "yaml";
      };
    in
    {
      options.my.system.backup.enable = lib.mkEnableOption "backup configuration (kopia)";

      config = lib.mkIf cfg.backup.enable {
        sops.secrets = {
          "homelab-1/password" = personal-s3-secret;
          "homelab-1/accessKey" = personal-s3-secret;
          "homelab-1/secretKey" = personal-s3-secret;
        };

        services.kopia = {
          enable = true;
          instances = {
            homelab = {
              enable = true;
              passwordFile = config.sops.secrets."homelab-1/password".path;
              path = "/persistent";
              repository = {
                s3 = {
                  bucket = "personal-backups";
                  endpoint = "s3.csjhuang.net";
                  accessKeyFile = config.sops.secrets."homelab-1/accessKey".path;
                  secretKeyFile = config.sops.secrets."homelab-1/secretKey".path;
                };
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
      };
    };

  # Home-manager: backup tools
  flake.homeModules.system-backup =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.my.system;
    in
    {
      options.my.system.backup.enable = lib.mkEnableOption "backup tools (rclone, kopia, syncthing)";

      config = lib.mkIf cfg.backup.enable {
        home.packages = with pkgs; [
          rclone
          kopia
        ];

        services.syncthing.enable = true;
      };
    };
}
