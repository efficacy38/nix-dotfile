{ ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = {
    supportedFilesystems = [ "zfs" ];
    tmp.useTmpfs = true;
    extraModprobeConfig = ''
      # only allow 50% arc cache is enabled
      options zfs zfs_arc_max_percent=50
    '';
  };

  my = {
    bundles = {
      common.enable = true;
      desktop-hyprland.enable = true;
      steam.enable = true;
    };
    desktop = {
      fprintd.enable = true;
      batteryHealth.enable = true;
    };
    users = {
      efficacy38 = {
        type = "desktop-user";
        extraHomeConfig = import ./home.nix;
      };
      gaming = {
        type = "minimal";
      };
    };
    devpack = {
      enable = true;
      csccUtil.enable = true;
      tailscale.enable = true;
    };
    system = {
      impermanence.enable = false;
      # backup.enable = true;
      systemdInitrd.enable = true;
      # systemdInitrd.debug = true;
    };
  };

  services.nfs.server.enable = true;

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
  environment.variables.EDITOR = "vim";

  programs.zsh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  system.stateVersion = "24.05";
}
