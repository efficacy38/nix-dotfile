{ modulesPath, ... }:
{
  imports = [
    # custom modules
    ../../modules
    # Include the default lxd configuration.
    "${modulesPath}/virtualisation/lxd-virtual-machine.nix"
  ];

  networking = {
    hostName = "workstation";
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
  };

  systemd.network = {
    enable = true;
    networks."50-enp5s0" = {
      matchConfig.Name = "enp5s0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  main-user.enable = true;
  main-user.userName = "efficacy38";
  main-user.devProgEnable = true;
  main-user.desktopEnable = false;
  my-desktop.enable = true;
  cscc-work.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  # ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  system.stateVersion = "24.11";
}
