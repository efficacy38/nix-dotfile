{ ... }:
{
  flake.nixosModules.bundles-steam =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.bundles.steam;
    in
    {
      options.my.bundles.steam = {
        enable = lib.mkEnableOption "enable steam bundle";
      };

      config = lib.mkIf cfg.enable {
        my.bundles.common.enable = true;

        my.desktop.steam.enable = true;
        my.desktop.steamHidpi = false;
      };
    };
}
