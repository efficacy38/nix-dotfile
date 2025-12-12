{ ... }:
{
  flake.nixosModules.bundles-common =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.bundles.common;
    in
    {
      options.my.bundles.common = {
        enable = lib.mkEnableOption "enable common bundle";
      };

      config = lib.mkIf cfg.enable {
        my.common.enable = true;

        my.main-user.enable = true;
        my.main-user.userName = "efficacy38";
      };
    };
}
