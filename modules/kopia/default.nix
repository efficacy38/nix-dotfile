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
      password = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Password for the Kopia instance.";
      };
      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "File containing the password for the Kopia instance, content in this file would override instance.<name>.password.";
      };
    };
  };
in
{
  imports = [
    ./repositories.nix
    ./snapshot.nix
  ];

  options.services.kopia = {
    enabled = lib.mkEnableOption "Enable Kopia backup";
    instances = lib.mkOption {
      type = lib.types.attrsOf instanceType;
    };
  };

  config = {
  };
}
