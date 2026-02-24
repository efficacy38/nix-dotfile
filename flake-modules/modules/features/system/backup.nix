# Backup system configurations: kopia, rclone, syncthing
_: {
  # NixOS: kopia backup to Backblaze B2
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
      backupSecret = {
        sopsFile = "${secretpath}/secrets/backup.yaml";
        format = "yaml";
      };
    in
    {
      options.my.system.backup.enable = lib.mkEnableOption "backup configuration (kopia)";

      config = lib.mkIf cfg.backup.enable {
        sops.secrets = {
          # homelab-1 secrets kept for future homelab backup restore
          "homelab-1/password" = backupSecret;
          "homelab-1/accessKey" = backupSecret;
          "homelab-1/secretKey" = backupSecret;
          "b2/password" = backupSecret;
          "b2/accessKey" = backupSecret;
          "b2/secretKey" = backupSecret;
        };

        services.kopia.backups.b2 = {
          repository.s3 = {
            bucket = "csjhuang-personal-backup";
            endpoint = "s3.us-west-004.backblazeb2.com";
            accessKeyIdFile = config.sops.secrets."b2/accessKey".path;
            secretAccessKeyFile = config.sops.secrets."b2/secretKey".path;
          };
          passwordFile = config.sops.secrets."b2/password".path;

          paths = [ "/persistent" ];

          policy = {
            retention = {
              keepLatest = 5;
              keepDaily = 30;
              keepWeekly = 4;
              keepMonthly = 3;
              keepAnnual = 0;
            };
            compression = "pgzip";
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
