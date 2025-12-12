{
  lib,
  config,
  ...
}:
let
  cfg = config.myHomeManager.bundles.desktop;
in
{
  options.myHomeManager.bundles.desktop = {
    enable = lib.mkEnableOption "desktop bundle (minimal + hyprland, zen, nvim)";
  };

  config = lib.mkIf cfg.enable {
    myHomeManager = {
      bundles.minimal.enable = true;
      desktop-common.enable = true;
      desktop-zen.enable = true;
      desktop-hyprland.enable = true;
      nvim.enable = true;
    };
  };
}
