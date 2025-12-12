{ ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = {
    supportedFilesystems = [ "zfs" ];
    kernelModules = [ "kvm-intel" ];
    tmp.useTmpfs = true;
    extraModprobeConfig = ''
      # only allow 50% arc cache is enabled
      options zfs zfs_arc_max_percent=50
    '';
  };

  my = {
    bundles = {
      homelab.enable = true;
      desktop-hyprland.enable = true;
    };
    devpack = {
      tailscale.enable = true;
      tailscaleAsRouter = true;
    };
  };

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
