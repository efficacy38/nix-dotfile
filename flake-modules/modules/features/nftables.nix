{ ... }:
{
  flake.nixosModules.nftables =
    { lib, config, ... }:
    let
      cfg = config.my.nftables;
    in
    {
      options.my.nftables = {
        enable = lib.mkEnableOption "nftables with firewall disabled (for custom rules)";
      };

      config = lib.mkIf cfg.enable {
        networking.nftables.enable = true;
        networking.firewall.enable = lib.mkForce false;
      };
    };
}
