{ lib, ... }:
{
  boot.isContainer = true;

  my = {
    bundles.common.enable = true;
    users.efficacy38 = {
      type = "minimal";
    };
    devpack.enable = true;
  };

  # Containers use host resolv.conf, incompatible with systemd-resolved
  services.resolved.enable = lib.mkForce false;

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "stella-nspawn";

  system.stateVersion = "24.11";
}
