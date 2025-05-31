let
  pkgs = import <nixpkgs> { };
  evalConfig = import <nixpkgs/nixos/lib/eval-config.nix>;

  system = evalConfig {
    modules = [
      ./default.nix

      # Set `system.stateVersion` and dummy fileSystems
      (
        { config, ... }:
        {
          fileSystems."/" = {
            device = "fake";
            fsType = "tmpfs";
          };
          system.stateVersion = "24.11";
          nixpkgs.system = "x86_64-linux";
          nixpkgs.pkgs = pkgs;
        }
      )
    ];
  };
in
builtins.toJSON system.config.services.kopia
# builtins.toJSON system.config.systemd.services.kopia-repository-s3
