{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";
    impermanence.url = "github:nix-community/impermanence";
    stylix.url = "github:danth/stylix/release-25.11";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nix-secrets = {
      url = "git+ssh://git@github.com/efficacy38/nix-secret.git?ref=main&shallow=1";
      # url = "git+ssh://git@gitlab.com/emergentmind/nix-secrets.git?ref=main&shallow=1";
      inputs = { };
      flake = false;
    };

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    home-manager-stable.url = "github:nix-community/home-manager/release-25.11";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs";

    solaar.url = "github:Svenum/Solaar-Flake";
    solaar.inputs.nixpkgs.follows = "nixpkgs";

    efficacy38-nur.url = "github:efficacy38/nur-packages";
    efficacy38-nur.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";

    import-tree.url = "github:vic/import-tree";
  };

  outputs =
    inputs:
    let
      import-tree = import inputs.import-tree;

      pkgs-stable = import inputs.nixpkgs-stable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      pkgs-unstable = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      mkSystem =
        config:
        inputs.nixpkgs-stable.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            config
            # import-tree for nixosModules
            (import-tree ./modules)
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
            ./overlays/personal-scripts/personal-scripts.nix
          ];
        };

      mkIsoSystem = config: inputs.nixpkgs-stable.lib.nixosSystem { modules = [ config ]; };
    in
    {
      inherit pkgs-stable pkgs-unstable;
      homeModules.default = ./home-modules/default.nix;
      nixosConfigurations = {
        workstation = mkSystem ./hosts/workstation/configuration.nix;
        homelab-1 = mkSystem ./hosts/homelab-1/configuration.nix;
        homelab-test = mkSystem ./hosts/homelab-test/configuration.nix;
        stella = mkSystem ./hosts/stella/configuration.nix;
        cc-desktop = mkSystem ./hosts/cc-desktop/configuration.nix;
        cc-container-vps = mkSystem ./hosts/cc-container-vps/configuration.nix;
        iso = mkIsoSystem ./hosts/iso/configuration.nix;
      };
      homeConfigurations = {
        "efficacy38@stealla" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./home-modules/default.nix
            ./hosts/stella/home.nix
          ];
          extraSpecialArgs = {
            inherit pkgs-stable pkgs-unstable;
          };
        };
      };
    };
}
