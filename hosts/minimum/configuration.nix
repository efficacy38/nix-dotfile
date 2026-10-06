{ lib, ... }:
{
  networking.hostName = lib.mkDefault "TEMPLATE_HOSTNAME";

  networking.firewall.enable = lib.mkForce false;

  system.stateVersion = "24.11";
}
