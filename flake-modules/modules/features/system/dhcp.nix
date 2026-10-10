# Network system configurations: systemd-networkd DHCP on ethernet interfaces
_: {
  flake.nixosModules.system-dhcp =
    { lib, config, ... }:
    let
      cfg = config.my.system.dhcp;
    in
    {
      options.my.system.dhcp.enable =
        lib.mkEnableOption "systemd-networkd DHCP on ethernet (non-bridge) interfaces";

      config = lib.mkIf cfg.enable {
        networking = {
          useNetworkd = true;
          # Suppress NixOS's default wired+wireless DHCP networks; the
          # interfaces are matched explicitly below (no wireless client).
          useDHCP = false;
          useHostResolvConf = false;
        };

        systemd.network.networks."50-dhcp" = {
          matchConfig = {
            Type = "ether";
            Kind = "!bridge";
          };
          networkConfig = {
            DHCP = "ipv4";
            IPv6AcceptRA = true;
          };
          linkConfig.RequiredForOnline = "routable";
        };
      };
    };
}
