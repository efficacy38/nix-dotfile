let
  pkgs = import <nixpkgs> { };
  evaled = pkgs.lib.evalModules {
    modules = [
      (
        { config, ... }:
        {
          config._module.args = { inherit pkgs; };
        }
      )
      ./default.nix
    ];
  };
  cfg = evaled.config.services.kopia;
in
builtins.toJSON cfg
