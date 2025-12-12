{
  lib,
  config,
  ...
}:
let
  cfg = config.myNixOS.bundles.homelab;
in
{
  options.myNixOS.bundles.homelab = {
    enable = lib.mkEnableOption "homelab bundle (server + incus + secure DNS + nftables)";
  };

  config = lib.mkIf cfg.enable {
    myNixOS.bundles.server.enable = true;
    myNixOS.incus.enable = true;
    myNixOS.common.resolvedDnssec = true;
    myNixOS.nftables.enable = true;
  };
}
