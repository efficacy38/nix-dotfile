{ ... }:
{
  flake.nixosModules.bundles-homelab =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.bundles.homelab;
    in
    {
      options.my.bundles.homelab = {
        enable = lib.mkEnableOption "homelab bundle (server + incus + secure DNS + nftables)";
      };

      config = lib.mkIf cfg.enable {
        my.bundles.server.enable = true;
        my.system.incusEnable = true;
        my.common.resolvedDnssec = true;
        my.system.nftablesEnable = true;
      };
    };
}
