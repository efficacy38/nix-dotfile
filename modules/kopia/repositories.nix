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
        type = lib.types.str;
        description = "Access key for S3 repository.";
      };
      secretKey = lib.mkOption {
        type = lib.types.str;
        description = "Secret key for S3 repository.";
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
                ExecStart = "${pkgs.kopia}/bin/kopia repository create azure ${lib.concatStringsSep " " (mkRepositoryArgs name instance)}";
                Restart = "on-failure";
              };
            }
          else
            throw "Unsupported repository type for Kopia instance ${name}";

        # name: instance:
        # if lib.hasAttr "s3" instance.repository then
        #   mkS3Repository name instance
        # else if lib.hasAttr "azure" instance.repository then
        #   mkAzureRepository name instance
        # else
        #   throw "Unsupported repository type for Kopia instance ${name}";

        # (lib.attrsets.nameValuePair "kopia-repository-${name}" {
        #   description = "Kopia Azure repository service";
        #   wantedBy = [ "multi-user.target" ];
        #   serviceConfig = {
        #     Type = "simple";
        #     ExecStart = "${pkgs.kopia}/bin/kopia repository create azure";
        #     Restart = "on-failure";
        #   };
        # });

        mkRepositoryArgs =
          name: instance:
          (
            if lib.hasAttr "s3" instance.repository then
              [
                "--bucket"
                instance.repository.s3.bucket
                "--access-key"
                instance.repository.s3.accessKey
                "--secret-access-key"
                instance.repository.s3.secretKey
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
      in
      lib.recursiveUpdate { } (lib.attrsets.mapAttrs' mkRepository config.services.kopia.instances);
  };
}
