{ inputs }:
let
  myLib = (import ./default.nix) { inherit inputs; };
  outputs = inputs.self.outputs;
  pkgs-stable = import inputs.nixpkgs-stable {
    system = "x86_64-linux";
  };
  mkSystemAtts = config: {
    specialArgs = {
      inherit
        myLib
        inputs
        outputs
        pkgs-stable
        ;
    };
    modules = [
      config
      outputs.nixosModules.default
      inputs.home-manager.nixosModules.default
      # use nix-index-database instead of run nix-index individually
      inputs.nix-index-database.nixosModules.nix-index
      # optional to also wrap and install comma
      { programs.nix-index-database.comma.enable = true; }
    ];
  };
in
rec {
  # ========================== Buildables ========================== #
  mkSystem = config: inputs.nixpkgs.lib.nixosSystem (mkSystemAtts config);
  mkStableSystem = config: inputs.nixpkgs-stable.lib.nixosSystem (mkSystemAtts config);
}
