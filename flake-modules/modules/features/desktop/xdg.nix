# XDG portal configuration for desktop
{ ... }:
{
  flake.nixosModules.desktop-xdg =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      options.my.desktop.xdgEnable = lib.mkEnableOption "XDG portal configuration";

      config = lib.mkIf (cfg.enable && cfg.xdgEnable) {
        xdg.portal.enable = true;
        # for better compatibility, check https://wiki.archlinux.org/title/XDG_Desktop_Portal
        xdg.portal.extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ];

        xdg.portal.config = {
          hyprland = {
            default = [
              "hyprland"
              "gtk"
            ];
          };
        };
      };
    };
}
