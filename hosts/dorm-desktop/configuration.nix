{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # custom modules
    ../../modules
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # nixos-hardware
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-hidpi
  ];

  main-user.enable = true;
  main-user.userName = "efficacy38";
  main-user.userConfig = ./home.nix;
  my-steam.enable = true;
  my-steam.hidpi = false;
  my-desktop.enable = true;
  my-desktop.zramEnable = true;
  my-desktop.kdeEnable = true;
  my-tailscale.enable = true;
  # can be used as exit node
  my-tailscale.asRouter = true;

  # for B580
  hardware.intel-gpu-tools.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.kernelPackages = pkgs.linuxPackages_testing;

  # Enable networking related
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking.hostName = "dorm-desktop"; # Define your hostname.

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  # ];

  networking.firewall = {
    enable = true;
    extraInputRules = ''
      ip saddr 140.113.0.0/16 tcp dport 25565 accept
      ip saddr !=140.113.0.0/16 tcp dport 25565 drop

      ip saddr 140.113.0.0/16 tcp dport 25566 accept
      ip saddr !=140.113.0.0/16 tcp dport 25566 drop
    '';

    # Open ports in the firewall.
    allowedTCPPorts = [
      # ssh
      22
      # sunshine
      47984
      47989
      47990
      48010
    ];
    allowedUDPPortRanges = [
      # sunshine
      {
        from = 47998;
        to = 48000;
      }
      {
        from = 8000;
        to = 8010;
      }
    ];
  };

  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # programs.ssh.enable = true;

  # enable gaming
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  system.stateVersion = "24.11";
}
