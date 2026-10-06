{
  # Enable networking related
  networking.hostName = "cc-desktop";
  networking.extraHosts = ''
    127.0.0.1   ipa.cs.nctu.edu.tw keycloak.cs.nctu.edu.tw
  '';

  # NetworkManager is enabled by desktop bundle
  # Configure static IP for enp5s0
  networking.interfaces.enp5s0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "10.4.1.136";
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = "10.4.1.254";
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [ ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  system.stateVersion = "24.05";
}
