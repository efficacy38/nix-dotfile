{
  lib,
  config,
  ...
}:
let
  cfg = config.myNixOS.bundles.desktop-hyprland;
in
{
  options.myNixOS.bundles.desktop-hyprland = {
    enable = lib.mkEnableOption "enable desktop-hyprland bundle";
  };

  config = lib.mkIf cfg.enable {
    myNixOS.bundles.common.enable = true;

    myNixOS.desktop.enable = true;
    myNixOS.desktop.zramEnable = false;
    myNixOS.desktop.hyprlandEnable = true;
    myNixOS.desktop.kdeEnable = false;
  };
}
