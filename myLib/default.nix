{ inputs }:
let
  import-tree = import inputs.import-tree;

  mkSystemAtts = config: {
    specialArgs = {
      inherit inputs;
    };
    modules = [
      config
      # import-tree for nixosModules
      (import-tree ../modules)
      inputs.sops-nix.nixosModules.sops
      { config.myNixOS.common.enable = true; }
      # use nix-index-database instead of run nix-index individually
      inputs.nix-index-database.nixosModules.nix-index
      { programs.nix-index-database.comma.enable = true; }
      inputs.stylix.nixosModules.stylix
      inputs.solaar.nixosModules.default
      inputs.impermanence.nixosModules.impermanence
      inputs.efficacy38-nur.nixosModules.kopia
      inputs.determinate.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.home-manager-stable.nixosModules.default
      # common overlays
      ../overlays/personal-scripts/personal-scripts.nix
    ];
  };
in
{
  # ========================== Buildables ========================== #
  mkSystem = config: inputs.nixpkgs-stable.lib.nixosSystem (mkSystemAtts config);

  mkIsoSystem = config: inputs.nixpkgs-stable.lib.nixosSystem { modules = [ config ]; };
}
