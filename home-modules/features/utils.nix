{ pkgs, ... }:
{
  home.packages = with pkgs; [
    curl
    wget
    ripgrep
    boxes
    ctags
    flatpak
    openssl
    cfssl
    dnsutils
    ansible

    wl-clipboard
    # handle nix cache
    cachix
  ];
}
