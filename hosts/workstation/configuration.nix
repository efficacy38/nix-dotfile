{
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    # custom modules
    ../../modules
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

  myNixOS.main-user.enable = true;
  myNixOS.main-user.userName = "efficacy38";
  myNixOS.main-user.userConfig = ./home.nix;
  myNixOS.cscc-work.enable = true;
  programs.mosh = {
    enable = true;
    openFirewall = true;
  };

  myNixOS.systemd-initrd.enable = true;

  virtualisation.docker.enable = true;

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
