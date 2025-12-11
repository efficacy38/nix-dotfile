{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.myNixOS.xdg;
in
{
  options.myNixOS.xdg = {
    enable = lib.mkEnableOption "Enable xdg module";
  };

  config = lib.mkIf cfg.enable {
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
}
