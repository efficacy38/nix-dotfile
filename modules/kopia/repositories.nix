{
  pkgs,
  lib,
  config,
  ...
}:
let
  s3RepositoryType = lib.types.submodule {
    options = {
      bucket = lib.mkOption {
        type = lib.types.str;
        default = "default-bucket-value";
        description = "Bucket name for S3 repository.";
      };
      accessKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Access key for S3 repository.";
      };
      accessKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to file containing access key for S3 repository, content in this file would override instance.<name>.accessKey.";
      };
      secretKey = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Secret key for S3 repository.";
      };
      secretKeyFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to file containing secret key for S3 repository, content in this file would override instance.<name>.secretKey.";
      };
      region = lib.mkOption {
        type = lib.types.str;
        default = "us-east-1";
        description = "Region for S3 repository.";
      };
      endpoint = lib.mkOption {
        type = lib.types.str;
        default = "https://s3.amazonaws.com";
        description = "Endpoint for S3 repository.";
      };
    };
  };

  azureRepositoryType = lib.types.submodule {
    options = {
      azure = lib.mkOption {
        type = lib.types.str;
        default = "default-azure-value";
        description = "Bar option for Azure repository.";
      };
    };
  };

  instanceType = lib.types.submodule {
    options = {
      repository = lib.mkOption {
        type = lib.types.attrTag {
          s3 = lib.mkOption {
            type = s3RepositoryType;
          };
          azure = lib.mkOption {
            type = azureRepositoryType;
          };
        };
      };
    };
  };
in
{
  options.services.kopia.instances = lib.mkOption {
    type = lib.types.attrsOf instanceType;
  };

  config = {
    # systemd service for repositories open
    systemd.services =
      let
        mkRepositoryArgs =
          name: instance:
          (
            if lib.hasAttr "s3" instance.repository then
              [
                "--bucket"
                instance.repository.s3.bucket
                "--endpoint"
                instance.repository.s3.endpoint
                "--region"
                instance.repository.s3.region
              ]
            else if lib.hasAttr "azure" instance.repository then
              [
                "--azure-account-name"
                instance.repository.azure.azure
              ]
            else
              throw "Unsupported repository type for Kopia instance ${name}"
          )
          ++ [
            "--password"
            instance.password
          ];

        mkRepository =
          # refactor with mkRepositoryArgs
          name: instance:
          if lib.hasAttr "s3" instance.repository then
            lib.attrsets.nameValuePair "kopia-repository-${name}" {
              description = "Kopia S3 repository service";
              wantedBy = [ "multi-user.target" ];
              environment = {
                # TODO: setup HOME environment of selected user
                HOME = "/root";
              };
              script = ''
                if ! ${pkgs.kopia}/bin/kopia repository connect s3 ${lib.concatStringsSep " " (mkRepositoryArgs name instance)}; then
                  ${pkgs.kopia}/bin/kopia repository create s3 ${lib.concatStringsSep " " (mkRepositoryArgs name instance)};
                fi
              '';
              serviceConfig = {
                Type = "simple";
                EnvironmentFile = "/etc/default/kopia-repository-${name}";
                User = "${instance.user}";
                WorkingDirectory = "~";
                SetLoginEnvironment = true;
              };
            }
          else if lib.hasAttr "azure" instance.repository then
            lib.attrsets.nameValuePair "kopia-repository-${name}" {
              description = "Kopia Azure repository service";
              wantedBy = [ "multi-user.target" ];
              environment = {
                XDG_CACHE_HOME = "/var/cache";
              };
              serviceConfig = {
                Type = "simple";
                EnvironmentFile = "/etc/default/kopia-repository-${name}";
                ExecStart = "${pkgs.kopia}/bin/kopia repository create azure ${lib.concatStringsSep " " (mkRepositoryArgs name instance)}";
                Restart = "on-failure";
              };
            }
          else
            throw "Unsupported repository type for Kopia instance ${name}";
      in
      lib.recursiveUpdate { } (lib.attrsets.mapAttrs' mkRepository config.services.kopia.instances);

    environment.etc =
      let
        mkRepositoryEnvFile =
          name: instance:
          let
            envlines = lib.concatStringsSep "\n" (
              lib.lists.flatten [
                (lib.optional (
                  instance.passwordFile == null && instance.password != null
                ) "KOPIA_PASSWORD=${instance.password}")
                (lib.optional (
                  instance.passwordFile != null
                ) "KOPIA_PASSWORD=${builtins.readFile instance.passwordFile}")

                (lib.optional (
                  instance.repository.s3.accessKey != null && instance.repository.s3.accessKeyFile == null
                ) "AWS_ACCESS_KEY_ID=${instance.repository.s3.accessKey}")

                (lib.optional (instance.repository.s3.accessKeyFile != null) ''
                  AWS_ACCESS_KEY_ID=${builtins.readFile instance.repository.s3.accessKeyFile}
                '')

                (lib.optional (
                  instance.repository.s3.secretKey != null && instance.repository.s3.secretKeyFile == null
                ) "AWS_SECRET_ACCESS_KEY=${instance.repository.s3.secretKey}")
                (lib.optional (instance.repository.s3.secretKeyFile != null) ''
                  AWS_SECRET_ACCESS_KEY=${builtins.readFile instance.repository.s3.secretKeyFile}
                '')
              ]
            );
          in
          lib.attrsets.nameValuePair "default/kopia-repository-${name}" {
            text = envlines;
            mode = "0600";
            user = instance.user;
          };
      in
      lib.recursiveUpdate { } (
        lib.attrsets.mapAttrs' mkRepositoryEnvFile config.services.kopia.instances
      );
  };
}
