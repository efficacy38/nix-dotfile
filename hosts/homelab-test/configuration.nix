{ pkgs, ... }:
{
  imports = [
    # custom modules
    ../../modules
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.supportedFilesystems = [ "bcachefs" "zfs" ];
  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.tmp.useTmpfs = true;

  # module related options
  main-user.enable = true;
  main-user.userName = "efficacy38";
  main-user.devProgEnable = false;
  main-user.desktopEnable = false;
  my-steam.enable = false;
  my-desktop.enable = false;
  my-desktop.zramEnable = false;
  cscc-work.enable = false;

  # systemd-resolved
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ];
    dnsovertls = "true";
  };

  # services
  services.openssh.enable = true;
  services.nfs.server.enable = true;
  # Enable networking related
  networking.hostName = "homelab-test"; # Define your hostname.
  networking.nftables.enable = true;
  networking.firewall.enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    man-db
    git
    vim
    wget
    curl
    htop
    openfortivpn
    incus-lts
    tcpdump

    bcachefs-tools
    nut
  ];
  environment.variables.EDITOR = "vim";

  programs.zsh.enable = true;
  virtualisation.incus = {
    enable = true;
    ui = {
      enable = true;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  system.stateVersion = "24.05";
}
