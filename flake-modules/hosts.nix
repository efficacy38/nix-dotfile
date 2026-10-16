{ inputs, config, ... }:
let
  mkSystem =
    hostConfig:
    inputs.nixpkgs.lib.nixosSystem {
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
        "${inputs.nixpkgs-kopia}/nixos/modules/services/backup/kopia/default.nix"
        "${inputs.nixpkgs-kopia}/nixos/modules/services/backup/kopia/policy-service.nix"
        "${inputs.nixpkgs-kopia}/nixos/modules/services/backup/kopia/repository-service.nix"
        "${inputs.nixpkgs-kopia}/nixos/modules/services/backup/kopia/snapshot-service.nix"
        "${inputs.nixpkgs-kopia}/nixos/modules/services/backup/kopia/web-service.nix"
        inputs.determinate.nixosModules.default
        inputs.home-manager-stable.nixosModules.default
        # Default enables
        { config.my.common.enable = true; }
        { programs.nix-index-database.comma.enable = true; }
        # Overlays
        ../overlays/personal-scripts/personal-scripts.nix
        ../overlays/flowsurface/flowsurface.nix
        ../overlays/notebooklm-py/notebooklm-py.nix
        ../overlays/hyprmon/hyprmon.nix

        # inline nixpkgs overlay
        (
          { ... }:
          {
            nixpkgs.overlays = [
              (_final: _prev: {
                zhtw-mcp = inputs.zhtw-mcp.packages.${_prev.system}.default;
                codex-desktop = inputs.codex-desktop-linux.packages.${_prev.stdenv.hostPlatform.system}.default;
              })
            ];
          }
        )
      ];
    };

  mkIsoSystem =
    hostConfig:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [ hostConfig ];
    };

  pkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
  flake = {
    inherit pkgs;

    nixosConfigurations = {
      workstation = mkSystem ../hosts/workstation;
      homelab-1 = mkSystem ../hosts/homelab-1;
      homelab-test = mkSystem ../hosts/homelab-test;
      stella = mkSystem ../hosts/stella;
      cc-desktop = mkSystem ../hosts/cc-desktop;
      cc-container-vps = mkSystem ../hosts/cc-container-vps;
      stella-nspawn = mkSystem ../hosts/stella-nspawn;
      iso = mkIsoSystem ../hosts/iso/configuration.nix;
      ns1 = mkSystem ../hosts/ns1;
    };
  };
}
