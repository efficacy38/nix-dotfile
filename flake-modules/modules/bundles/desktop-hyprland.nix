{ ... }:
{
  flake.nixosModules.bundles-desktop-hyprland =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.bundles.desktop-hyprland;
    in
    {
      options.my.bundles.desktop-hyprland = {
        enable = lib.mkEnableOption "enable desktop-hyprland bundle";
      };

      config = lib.mkIf cfg.enable {
        my.bundles.common.enable = true;

        my.desktop.enable = true;
        my.desktop.zram.enable = false;
        my.desktop.hyprland.enable = true;
        my.desktop.kde.enable = false;
      };
    };
}
