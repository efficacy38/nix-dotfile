{ inputs, config, ... }:
let
  mkSystem =
    hostConfig:
    inputs.nixpkgs-stable.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = [
        hostConfig
        # Flake-parts nixosModules (dendritic pattern)
        config.flake.nixosModules.default
        # External modules
        inputs.sops-nix.nixosModules.sops
        inputs.nix-index-database.nixosModules.nix-index
        inputs.stylix.nixosModules.stylix
        inputs.solaar.nixosModules.default
        inputs.impermanence.nixosModules.impermanence
        "${inputs.nixpkgs-kopia}/nixos/modules/services/backup/kopia"
        inputs.determinate.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.home-manager-stable.nixosModules.default
        # Default enables
        { config.my.common.enable = true; }
        { programs.nix-index-database.comma.enable = true; }
        # Overlays
        ../overlays/personal-scripts/personal-scripts.nix
        ../overlays/flowsurface/flowsurface.nix
        ../overlays/notebooklm-py/notebooklm-py.nix
      ];
    };

  mkIsoSystem =
    hostConfig:
    inputs.nixpkgs-stable.lib.nixosSystem {
      modules = [ hostConfig ];
    };

  pkgs-stable = import inputs.nixpkgs-stable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  pkgs-unstable = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
  flake = {
    inherit pkgs-stable pkgs-unstable;

    nixosConfigurations = {
      workstation = mkSystem ../hosts/workstation/configuration.nix;
      homelab-1 = mkSystem ../hosts/homelab-1/configuration.nix;
      homelab-test = mkSystem ../hosts/homelab-test/configuration.nix;
      stella = mkSystem ../hosts/stella/configuration.nix;
      cc-desktop = mkSystem ../hosts/cc-desktop/configuration.nix;
      cc-container-vps = mkSystem ../hosts/cc-container-vps/configuration.nix;
      iso = mkIsoSystem ../hosts/iso/configuration.nix;
    };
  };
}
