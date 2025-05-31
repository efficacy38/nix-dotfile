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
        type = lib.types.str;
        default = "default-password";
        description = "Password for the Kopia instance.";
      };
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
  };
}
