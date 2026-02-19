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
      backupSecret = {
        sopsFile = "${secretpath}/secrets/backup.yaml";
        format = "yaml";
      };
    in
    {
      options.my.system.backup.enable = lib.mkEnableOption "backup configuration (kopia)";

      config = lib.mkIf cfg.backup.enable {
        sops.secrets = {
          "homelab-1/password" = backupSecret;
          "homelab-1/accessKey" = backupSecret;
          "homelab-1/secretKey" = backupSecret;
          "b2/password" = backupSecret;
          "b2/accessKey" = backupSecret;
          "b2/secretKey" = backupSecret;
        };

        sops.templates."kopia-s3-env" = {
          content = ''
            AWS_ACCESS_KEY_ID=${config.sops.placeholder."homelab-1/accessKey"}
            AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."homelab-1/secretKey"}
          '';
        };

        sops.templates."kopia-b2-env" = {
          content = ''
            AWS_ACCESS_KEY_ID=${config.sops.placeholder."b2/accessKey"}
            AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."b2/secretKey"}
          '';
        };

        # disabled: due to homelab raid corruption :<
        # services.kopia.backups.homelab = {
        #   repositoryType = "s3";
        #   s3 = {
        #     bucket = "personal-backups";
        #     endpoint = "s3.csjhuang.net";
        #   };
        #   passwordFile = config.sops.secrets."homelab-1/password".path;
        #   environmentFile = config.sops.templates."kopia-s3-env".path;
        #
        #   paths = [ "/persistent" ];
        #
        #   policy = {
        #     retention = {
        #       keepLatest = 5;
        #       keepDaily = 30;
        #       keepWeekly = 4;
        #       keepMonthly = 3;
        #       keepAnnual = 0;
        #     };
        #     compression = "pgzip";
        #   };
        # };

        services.kopia.backups.b2 = {
          repositoryType = "s3";
          s3 = {
            bucket = "csjhuang-personal-backup";
            endpoint = "s3.us-west-004.backblazeb2.com";
          };
          passwordFile = config.sops.secrets."b2/password".path;
          environmentFile = config.sops.templates."kopia-b2-env".path;

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

        # services.kopia.backups.sftp = {
        #   repositoryType = "sftp";
        #   sftp = {
        #     host = "localhost";
        #     port = 2222;
        #     username = "backup1";
        #     path = "/opt/backups";
        #     password = "12345678";
        #     knownHostsFile = "/home/efficacy38/.ssh/known_hosts";
        #   };
        #   passwordFile = config.sops.secrets."homelab-1/password".path;
        #
        #   paths = [ "/home/efficacy38/.ssh" ];
        #
        #   policy = {
        #     retention = {
        #       keepLatest = 5;
        #       keepDaily = 30;
        #       keepWeekly = 4;
        #       keepMonthly = 3;
        #       keepAnnual = 0;
        #     };
        #     compression = "pgzip";
        #   };
        #
        #   web.enable = true;
        #   web.serverPasswordFile = "/home/efficacy38/.kopia-web-password";
        # };

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
