{
  pkgs,
  ...
}:
{
  xdg.portal.enable = true;
  # for better compatibility, check https://wiki.archlinux.org/title/XDG_Desktop_Portal
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "zen.desktop" ];
      "x-scheme-handler/https" = [ "zen.desktop" ];
      "text/html" = [ "zen.desktop" ];
      "application/pdf" = [ "zen.desktop" ];
    };
  };
}
