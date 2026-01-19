_: {
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
        my = {
          common.enable = true;
          users.efficacy38 = {
            type = lib.mkDefault "minimal";
            isAdmin = lib.mkDefault true;
          };
        };
      };
    };
}
