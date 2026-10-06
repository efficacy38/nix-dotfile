{ lib, ... }:
{
  networking.hostName = lib.mkDefault "cc-container-vps";

  networking.interfaces.ens192 = {
    useDHCP = true;
  };
  networking.interfaces.ens224 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "140.113.168.232";
        prefixLength = 24;
      }
    ];
  };

  networking.defaultGateway = "140.113.168.254";
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  networking.firewall.enable = lib.mkForce false;

  system.stateVersion = "24.11";
}
