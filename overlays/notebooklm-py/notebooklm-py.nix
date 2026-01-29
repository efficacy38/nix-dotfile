{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (_final: _prev: {
      notebooklm-py = pkgs.callPackage ./package.nix { };
    })
  ];
}
