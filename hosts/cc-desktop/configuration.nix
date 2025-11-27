{
  inputs,
  config,
  pkgs,
  ...
}:
let
  secretpath = builtins.toString inputs.nix-secrets;

  common-secret = {
    sopsFile = "${secretpath}/secrets/common.yaml";
    format = "yaml";
  };
in
{
  imports = [
    # custom modules
    ../../modules
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # boot.supportedFilesystems = [ "bcachefs" "zfs" ];
  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.tmp.useTmpfs = true;
  boot.extraModprobeConfig = ''
    # only allow 50% arc cache is enabled
    options zfs zfs_arc_max_percent=50
  '';

  # module related options
  myNixOS.bundles.common.enable = true;
  myNixOS.bundles.server.enable = true;
  myNixOS.bundles.desktop-hyprland.enable = true;
  myNixOS.tailscale.enable = true;
  myNixOS.tailscale.asRouter = true;
  # services.kopia.enable = false;

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
  networking.hostName = "cc-desktop";
  networking.nftables.enable = true;
  networking.firewall.enable = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [ ];
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
