{ lib, ... }:
{
  myNixos.common.enable = true;

  # enable main-user, still need to configure username...
  myNixos.main-user.enable = true;
  myNixos.desktop.enable = true;

  # enable tailscale
  myNixos.tailscale.enable = lib.mkDefault true;
}
