{ config, pkgs, ... }: {
  imports = [
    ./c-cpp.nix
    ./rust.nix
    ./git.nix
  ];
}
