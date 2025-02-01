{ pkgs, ... }:
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
  my-steam.hidpi = false;
  my-desktop.enable = true;
  my-desktop.zramEnable = false;
  cscc-work.enable = true;
  my-tailscale.enable = true;
  my-tailscale.asRouter = false;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "reboot=bios"
    "amdgpu.sg_display=0"
  ];
  boot.tmp.useTmpfs = true;

  # Enable networking related
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.hostName = "phoenixton"; # Define your hostname.
  networking.extraHosts = ''
    10.1.0.131   imap.cs.nycu.edu.tw
  '';

  services.udev.extraRules = ''
    # make amdgpu card don't display some artifact
        KERNEL=="card1", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="high"
  '';

  services.solaar.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  system.stateVersion = "24.11";
}
