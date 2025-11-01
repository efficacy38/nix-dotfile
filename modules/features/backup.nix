{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.myNixOS.backup;

  secretpath = builtins.toString inputs.nix-secrets;
  personal-s3-secret = {
    sopsFile = "${secretpath}/secrets/backup.yaml";
    format = "yaml";
  };
in
{
  options.myNixOS.backup = {
    enable = lib.mkEnableOption "enable cscc change vpn script module";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."homelab-1/password" = personal-s3-secret;
    sops.secrets."homelab-1/accessKey" = personal-s3-secret;
    sops.secrets."homelab-1/secretKey" = personal-s3-secret;

    services.kopia = {
      enable = true;
      instances = {
        homelab = {
          enable = true;
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
  };
}
