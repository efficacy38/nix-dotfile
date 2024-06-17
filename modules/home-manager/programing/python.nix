{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    python3
    python312Packages.pip
    python312Packages.molecule
    pipx
  ];
}
