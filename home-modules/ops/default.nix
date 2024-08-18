{ config, pkgs, ... }: {
  imports = [
    ./k8s.nix
    ./nvim.nix
    ./common.nix
    ./incus.nix
    ./podman.nix
  ];
}
