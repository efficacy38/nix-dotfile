{ ... }:
{
  flake.homeModules.bundles-desktop =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.bundles.desktop;
    in
    {
      options.my.bundles.desktop = {
        enable = lib.mkEnableOption "desktop bundle (minimal + hyprland, zen, nvim)";
      };

      config = lib.mkIf cfg.enable {
        my = {
          bundles.minimal.enable = true;
          desktop-common.enable = true;
          desktop-zen.enable = true;
          desktop-hyprland.enable = true;
          nvim.enable = true;
        };
      };
    };
}
