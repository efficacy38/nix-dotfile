{ lib, ... }:
let
  s3RepositoryType = lib.types.submodule {
    options = {
      s3 = lib.mkOption {
        type = lib.types.str;
        default = "default-bar-value";
        description = "Bar option for S3 repository.";
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
}
