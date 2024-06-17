{ config, pkgs, ... }: {
  imports = [
    ./c-cpp.nix
    ./rust.nix
    ./git.nix
    ./python.nix
    ./tmux.nix
    ./others.nix
    ./go.nix
  ];
}
