{ ... }:
{
  flake.nixosModules.bundles-desktop-kde =
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
        enable = lib.mkEnableOption "enable desktop-kde bundle";
      };

      config = lib.mkIf cfg.enable {
        my.bundles.common.enable = true;

        my.desktop.enable = true;
        my.desktop.zram.enable = false;
        my.desktop.hyprland.enable = false;
        my.desktop.kde.enable = true;
      };
    };
}
