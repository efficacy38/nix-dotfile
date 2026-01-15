# XDG portal configuration for desktop
_: {
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
      options.my.desktop.xdg.enable = lib.mkEnableOption "XDG portal configuration";

      config = lib.mkIf (cfg.enable && cfg.xdg.enable) {
        # compatiability with KDE applications
        environment.etc."/xdg/menus/plasma-applications.menu".text =
          builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

        # for better compatibility, check https://wiki.archlinux.org/title/XDG_Desktop_Portal
        xdg.portal = {
          enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-hyprland
            xdg-desktop-portal-gnome
            xdg-desktop-portal-gtk
            kdePackages.xdg-desktop-portal-kde
          ];
          config = {
            hyprland = {
              default = [
                "hyprland"
                "gtk"
              ];
            };
          };
        };
      };
    };
}
