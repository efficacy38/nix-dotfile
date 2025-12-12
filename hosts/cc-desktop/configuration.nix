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
  my.bundles.common.enable = true;
  my.bundles.server.enable = true;
  my.bundles.desktop-hyprland.enable = true;
  my.incus.enable = true;
  my.common.resolvedDnssec = true;
  my.nftables.enable = true;
  my.tailscale.enable = true;
  my.tailscale.asRouter = true;

  # services
  services.openssh.enable = true;
  services.nfs.server.enable = true;
  # Enable networking related
  networking.hostName = "cc-desktop";

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
