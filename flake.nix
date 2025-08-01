{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";
    impermanence.url = "github:nix-community/impermanence";
    stylix.url = "github:danth/stylix/release-25.05";
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

    home-manager-stable.url = "github:nix-community/home-manager/release-25.05";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs";

    solaar.url = "github:Svenum/Solaar-Flake";
    solaar.inputs.nixpkgs.follows = "nixpkgs";

    efficacy38-nur.url = "github:efficacy38/nur-packages";
    efficacy38-nur.inputs.nixpkgs.follows = "nixpkgs";

    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
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
        iso = myLib.mkIsoSystem ./hosts/iso/configuration.nix;
      };
    };
}
