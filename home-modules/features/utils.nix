{ inputs, pkgs, ... }:
let
  gns3bin = (
    pkgs.gns3-gui.overrideAttrs (
      finalAttrs: previousAttrs: rec {
        pname = previousAttrs.pname + "-bar";
        version = "2.2.54";
        src = pkgs.fetchFromGitHub {
          hash = "sha256-rR7hrNX7BE86x51yaqvTKGfcc8ESnniFNOZ8Bu1Yzuc=";
          owner = "GNS3";
          repo = "gns3-gui";
          rev = "refs/tags/v${version}";
        };
      }
    )
  );
in
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
    s3cmd

    wl-clipboard
    # handle nix cache
    cachix
    entr

    # personal tools
    inputs.efficacy38.packages.x86_64-linux.personal-script
    inputs.efficacy38.packages.x86_64-linux.personal-fhs

    gns3bin
    inputs.mic92.packages.x86_64-linux.eapol_test
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
}
