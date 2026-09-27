{ lib, ... }:
{
  my = {
    bundles = {
      desktop-hyprland.enable = true;
      steam.enable = true;
    };
    system = {
      impermanence.enable = true;
      systemdInitrd.enable = true;
      netbird.enable = true;
      # systemdInitrd.debug = true;
      backup.enable = true;
    };
  };

  # Enable networking related
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking = {
    hostName = "stella"; # Define your hostname.
    extraHosts = ''
      10.2.2.99   minio-backup.test.cc.cs.nctu.edu.tw
      127.0.0.1   ipa.cs.nctu.edu.tw keycloak.cs.nctu.edu.tw
    '';
    firewall.enable = lib.mkForce false;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  system.stateVersion = "24.11";
}
