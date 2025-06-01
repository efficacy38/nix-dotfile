{
  lib,
  ...
}:
let
  instanceType = lib.types.submodule {
    options = {
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
      user = lib.mkOption {
        type = lib.types.str;
        default = "root";
        description = "User under which the Kopia instance runs.";
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
