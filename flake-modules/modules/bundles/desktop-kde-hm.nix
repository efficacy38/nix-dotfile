{ ... }:
{
  flake.homeModules.bundles-desktop-kde =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.bundles.desktop-kde;
    in
    {
      options.my.bundles.desktop-kde = {
        enable = lib.mkEnableOption "KDE desktop bundle (minimal + kde, zen)";
      };

      config = lib.mkIf cfg.enable {
        my = {
          bundles.minimal.enable = true;
          desktop-common.enable = true;
          desktop-zen.enable = true;
          desktop-kde.enable = true;
        };
      };
    };
}
