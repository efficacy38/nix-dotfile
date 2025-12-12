{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (_final: _prev: {
      personal-script = pkgs.callPackage ./package.nix { };
    })
  ];
}
