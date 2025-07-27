{
  pkgs,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    # Include the default lxd configuration.
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
  ];

  networking = {
    hostName = "personal-iso";
  };

  environment.systemPackages = with pkgs; [
    neovim
    git
    parted
    gparted
  ];

  system.stateVersion = "24.11";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
