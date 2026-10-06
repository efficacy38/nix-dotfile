{
  # Enable networking: bridge br0 with eno1, DHCP on br0
  networking = {
    hostName = "homelab-1";
    useDHCP = false;
    dhcpcd.enable = false;
  };

  systemd.network = {
    enable = true;

    netdevs."10-br0" = {
      netdevConfig = {
        Name = "br0";
        Kind = "bridge";
      };
    };

    networks."20-eno1" = {
      matchConfig.Name = "eno1";
      networkConfig.Bridge = "br0";
      linkConfig.RequiredForOnline = "enslaved";
    };

    networks."20-br0" = {
      matchConfig.Name = "br0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  system.stateVersion = "24.05";
}
