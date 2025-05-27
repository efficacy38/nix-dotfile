let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  options = { };
  config = { };
  callPackage = pkgs.callPackage pkgs;
in
pkgs.callPackage ./kopia { }
