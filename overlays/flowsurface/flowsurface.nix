{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (_final: _prev: {
      flowsurface = pkgs.callPackage ./package.nix { };
    })
  ];
}
