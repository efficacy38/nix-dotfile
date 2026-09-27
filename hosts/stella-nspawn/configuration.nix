{ lib, ... }:
{
  boot.isContainer = true;

  # Containers use host resolv.conf, incompatible with systemd-resolved
  services.resolved.enable = lib.mkForce false;

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "stella-nspawn";

  system.stateVersion = "24.11";
}
