{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      personal-script = pkgs.callPackage ./package.nix { };
    })
  ];
}
