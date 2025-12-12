{
  lib,
  config,
  ...
}:
let
  cfg = config.myHomeManager.bundles.desktop-kde;
in
{
  options.myHomeManager.bundles.desktop-kde = {
    enable = lib.mkEnableOption "KDE desktop bundle (minimal + kde, zen)";
  };

  config = lib.mkIf cfg.enable {
    myHomeManager = {
      bundles.minimal.enable = true;
      desktop-common.enable = true;
      desktop-zen.enable = true;
      desktop-kde.enable = true;
    };
  };
}
