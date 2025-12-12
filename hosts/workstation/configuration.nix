{
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    # Include the default lxd configuration.
    "${modulesPath}/virtualisation/incus-virtual-machine.nix"
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

  my = {
    common-server.enable = true;
    main-user = {
      enable = true;
      userName = "efficacy38";
      userConfig = ./home.nix;
    };
    devpack = {
      enable = true;
      csccUtil.enable = true;
      tailscale.enable = true;
    };
    system.systemdInitrd.enable = true;
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  # ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  system.stateVersion = "24.11";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
