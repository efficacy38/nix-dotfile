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
    mosh

    wl-clipboard
    # handle nix cache
    cachix

    entr

    # personal script
    personal-script

    nixos-shell
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
}
