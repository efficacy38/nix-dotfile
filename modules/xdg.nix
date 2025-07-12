{
  pkgs,
  ...
}:
{
  xdg.portal.enable = true;
  # for better compatibility, check https://wiki.archlinux.org/title/XDG_Desktop_Portal
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
}
