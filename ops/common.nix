{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    ctags
    flatpak
    openssl
  ];
}
