{
  lib,
  config,
  ...
}:
let
  cfg = config.myNixOS.bundles.desktop-kde;
in
{
  options.myNixOS.bundles.desktop-kde = {
    enable = lib.mkEnableOption "enable desktop-kde bundle";
  };

  config = lib.mkIf cfg.enable {
    myNixOS.bundles.common.enable = true;

    myNixOS.desktop.enable = true;
    myNixOS.desktop.zramEnable = false;
    myNixOS.desktop.hyprlandEnable = false;
    myNixOS.desktop.kdeEnable = true;
  };
}
