{ config, pkgs, ... }: {
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

    # dev tools
    podman
    podman-compose
    jsonnet

    # TODO: move this to DE folder
    wl-clipboard

    # TODO: direnv use home-manager to setup
    direnv
  ];
}
