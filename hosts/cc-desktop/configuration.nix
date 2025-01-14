{ ... }:
{
  imports = [
    # custom modules
    ../../modules
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  main-user.enable = true;
  main-user.userName = "efficacy38";
  main-user.devProgEnable = true;
  main-user.desktopEnable = true;
  my-steam.enable = true;
  my-steam.hidpi = true;
  my-desktop.enable = true;
  my-desktop.zramEnable = true;
  my-tailscale.enable = true;
  # can be used as exit node
  my-tailscale.asRouter = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking related
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.hostName = "cc-desktop"; # Define your hostname.

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  # ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # programs.ssh.enable = true;

  system.stateVersion = "24.11";
}
