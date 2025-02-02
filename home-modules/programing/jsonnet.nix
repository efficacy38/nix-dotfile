{ pkgs, ... }:
{
  home.packages = with pkgs; [
    curl
    wget
    git
    tmux
    ripgrep
    boxes
    man-db
    ctags
    flatpak
    openssl
    cfssl
    dnsutils
    ansible

    # dev tools
    jsonnet

    # TODO: move this to DE folder
    wl-clipboard
    # handle nix cache
    cachix
  ];
}
