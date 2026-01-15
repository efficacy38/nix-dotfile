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
    main-user.userConfig = ./home.nix;
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

  # NetworkManager is enabled by desktop bundle and will manage all interfaces with DHCP by default
  # Explicitly configure enp5s0 to use DHCP
  networking.interfaces.enp5s0.useDHCP = true;

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
