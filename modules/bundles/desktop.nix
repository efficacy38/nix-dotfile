{ lib, ... }:
{
  myNixos.bundle.minimal.enable = true;
  myNixos.cscc-work.enable = true;

  # desktop setup
  myNixos.desktop.enable = true;
  myNixos.desktop.hyprlandEnable = true;

  # steam
  myNixos.steam.enable = lib.mkDefault true;

  # xdg
  myNixos.xdg.enable = true;
}
