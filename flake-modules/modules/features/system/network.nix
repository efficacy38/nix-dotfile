# Network system configurations: nftables, tailscale (system-level)
{ ... }:
{
  # NixOS: nftables firewall configuration
  flake.nixosModules.system-nftables =
    { lib, config, ... }:
    let
      cfg = config.my.system;
    in
    {
      options.my.system.nftablesEnable = lib.mkEnableOption "nftables with firewall disabled (for custom rules)";

      config = lib.mkIf cfg.nftablesEnable {
        networking.nftables.enable = true;
        networking.firewall.enable = lib.mkForce false;
      };
    };
}
