{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    nix-secrets = {
      url = "git+ssh://git@github.com/efficacy38/nix-secret.git?ref=main&shallow=1";
      # url = "git+ssh://git@gitlab.com/emergentmind/nix-secrets.git?ref=main&shallow=1";
      inputs = { };
      flake = false;
    };

    solaar = {
      url = "github:Svenum/Solaar-Flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix/release-25.05";

    zen-browser.url = "github:youwen5/zen-browser-flake";
  };

  outputs =
    { ... }@inputs:
    let
      myLib = import ./myLib/default.nix { inherit inputs; };
    in
    {
      inherit myLib;
      homeModules.default = ./home-modules/default.nix;
      nixosModules.default = ./modules/default.nix;
      nixosConfigurations = {
        phoenixton = myLib.mkSystem ./hosts/phoenixton/configuration.nix;
        workstation = myLib.mkSystem ./hosts/workstation/configuration.nix;
        homelab-1 = myLib.mkStableSystem ./hosts/homelab-1/configuration.nix;
        homelab-test = myLib.mkStableSystem ./hosts/homelab-test/configuration.nix;
        stella = myLib.mkStableSystem ./hosts/stella/configuration.nix;
      };
    };
}
