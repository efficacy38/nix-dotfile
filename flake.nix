{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    stylix.url = "github:danth/stylix/release-26.05";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nix-secrets.url = "git+ssh://git@github.com/efficacy38/nix-secret.git?ref=main&shallow=1";
    # nix-secrets.url = "git+ssh://git@gitlab.com/emergentmind/nix-secrets.git?ref=main&shallow=1";
    nix-secrets.inputs = { };
    nix-secrets.flake = false;

    home-manager-stable.url = "github:nix-community/home-manager/release-26.05";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs";
    solaar.url = "github:Svenum/Solaar-Flake";
    solaar.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-kopia.url = "github:efficacy38/nixpkgs/master";
    firefox-addons.url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
    firefox-addons.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";

    llm-agents.url = "github:numtide/llm-agents.nix";
    codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";
    codex-desktop-linux.inputs.nixpkgs.follows = "nixpkgs";
    academic-research-skills-codex.url = "github:Imbad0202/academic-research-skills-codex/900238ce1b04109bc3e11a4849f4be55122e5301";
    academic-research-skills-codex.flake = false;
    mattpocock-skills.url = "github:mattpocock/skills";
    mattpocock-skills.flake = false;
    nono.url = "github:nolabs-ai/nono";
    nono.inputs.nixpkgs.follows = "nixpkgs";
    # TODO: maybe build a pre build release and replace this pined version of zhtw-mcp
    zhtw-mcp.url = "github:sysprog21/zhtw-mcp/df4762639f8b079d94b1c97e07ecbfff468dfd3c";
    zhtw-mcp.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      import-tree = import inputs.import-tree;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { system, pkgs, ... }:
        {
          formatter = pkgs.nixfmt-tree;
        };

      imports = [
        # Home-manager's flake-parts module (provides homeModules option)
        inputs.home-manager-stable.flakeModules.home-manager
        ./flake-modules/nixos-modules.nix
        ./flake-modules/home-modules.nix
        ./flake-modules/hosts.nix
        # New flake-parts modules (features and bundles) via import-tree
        (import-tree ./flake-modules/modules)
      ];
    };
}
