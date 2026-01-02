_: {
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
        my = {
          bundles.server.enable = true;
          system = {
            incus.enable = true;
            nftables.enable = true;
          };
          common.resolvedDnssec = true;
        };
      };
    };
}
