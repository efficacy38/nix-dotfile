{ inputs }:
let
  myLib = (import ./default.nix) { inherit inputs; };
  import-tree = import inputs.import-tree;

  mkSystemAtts = isStable: config: {
    specialArgs = {
      inherit myLib inputs;
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
      # common overlays
      ../overlays/personal-scripts/personal-scripts.nix
    ]
    ++ inputs.nixpkgs.lib.optionals isStable [
      inputs.home-manager-stable.nixosModules.default
    ]
    ++ inputs.nixpkgs.lib.optionals (!isStable) [
      inputs.home-manager.nixosModules.default
    ];
  };
in
{
  # ========================== Buildables ========================== #
  mkSystem = config: inputs.nixpkgs.lib.nixosSystem (mkSystemAtts false config);

  mkStableSystem = config: inputs.nixpkgs-stable.lib.nixosSystem (mkSystemAtts true config);

  mkIsoSystem = config: inputs.nixpkgs-stable.lib.nixosSystem { modules = [ config ]; };
}
