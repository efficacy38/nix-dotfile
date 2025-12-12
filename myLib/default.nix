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
rec {
  # =========================== Helpers ============================ #
  # Get all files in a directory (still needed for home-modules)
  filesIn = dir: (map (fname: dir + "/${fname}") (builtins.attrNames (builtins.readDir dir)));

  # ========================== Buildables ========================== #
  mkSystem = config: inputs.nixpkgs.lib.nixosSystem (mkSystemAtts false config);

  mkStableSystem = config: inputs.nixpkgs-stable.lib.nixosSystem (mkSystemAtts true config);

  mkIsoSystem = config: inputs.nixpkgs-stable.lib.nixosSystem { modules = [ config ]; };

  # ========================== Extenders =========================== #

  # Evaluates nixos/home-manager module and extends it's options / config
  #  wrapper function that return extended Module
  extendModule =
    { path, ... }@args:
    margs:
    let
      # evaluated final result
      eval = if (builtins.isString path) || (builtins.isPath path) then import path margs else path margs;
      evalNoImports = builtins.removeAttrs eval [
        "imports"
        "options"
      ];

      # do extra* logic, act return value as another modules
      extra =
        if (builtins.hasAttr "extraOptions" args) || (builtins.hasAttr "extraConfig" args) then
          [
            (_: {
              options = args.extraOptions or { };
              config = args.extraConfig or { };
            })
          ]
        else
          [ ];
    in
    {
      imports = (eval.imports or [ ]) ++ extra;

      options =
        if builtins.hasAttr "optionsExtension" args then
          (args.optionsExtension (eval.options or { }))
        else
          (eval.options or { });

      config =
        if builtins.hasAttr "configExtension" args then
          (args.configExtension (eval.config or evalNoImports))
        else
          (eval.config or evalNoImports);
    };

  # Applies extendModules to all modules
  # modules can be defined in the same way
  # as regular imports, or taken from "filesIn"
  extendModules =
    extension: modules:
    map (
      f:
      let
        # Extract filename without extension (inlined fileNameOf)
        name = builtins.head (builtins.split "\\." (baseNameOf f));
      in
      extendModule ((extension name) // { path = f; })
    ) modules;
}
