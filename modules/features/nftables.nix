{
  lib,
  config,
  ...
}:
let
  cfg = config.myNixOS.nftables;
in
{
  options.myNixOS.nftables = {
    enable = lib.mkEnableOption "nftables with firewall disabled (for custom rules)";
  };

  config = lib.mkIf cfg.enable {
    networking.nftables.enable = true;
    networking.firewall.enable = lib.mkForce false;
  };
}
