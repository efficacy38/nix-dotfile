# Network system configurations: nftables, tailscale (system-level)
_:
{
  # NixOS: nftables firewall configuration
  flake.nixosModules.system-nftables =
    { lib, config, ... }:
    let
      cfg = config.my.system;
    in
    {
      options.my.system.nftables.enable =
        lib.mkEnableOption "nftables with firewall disabled (for custom rules)";

      config = lib.mkIf cfg.nftables.enable {
        networking.nftables.enable = true;
        networking.firewall.enable = lib.mkForce false;
      };
    };
}
