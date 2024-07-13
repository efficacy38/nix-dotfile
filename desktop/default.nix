{ config, pkgs, ... }: {
  imports = [
    ./apps.nix
    ./scripts
    ./kde.nix
    # ./steam.nix
  ];
}
