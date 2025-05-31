{
  lib,
  ...
}:
let
  instanceType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "default";
        description = "Name of the Kopia instance.";
      };
      enabled = lib.mkEnableOption "Enable Kopia instance";
    };
  };
in
{
  imports = [
    ./repositories.nix
  ];

  options.services.kopia = {
    enabled = lib.mkEnableOption "Enable Kopia backup";
    instances = lib.mkOption {
      type = lib.types.attrsOf instanceType;
    };
  };

  config = {
    services.kopia = {
      enabled = true;
      instances = {
        s3 = {
          name = "default";
          enabled = true;
          repository = {
            # s3.s3 = "default-bar-value";
            azure.azure = "default-azure-value";
          };
        };
      };
    };
  };
}
