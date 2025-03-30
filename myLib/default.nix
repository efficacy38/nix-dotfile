{ inputs }:
let
  myLib = (import ./default.nix) { inherit inputs; };
  outputs = inputs.self.outputs;
  pkgs-stable = import inputs.nixpkgs-stable {
    system = "x86_64-linux";
  };
  mkSystemAtts = isStable: config: {
    specialArgs = {
      inherit
        myLib
        inputs
        outputs
        pkgs-stable
        ;
    };
    modules =
      [
        config
        outputs.nixosModules.default
        # use nix-index-database instead of run nix-index individually
        inputs.nix-index-database.nixosModules.nix-index
        # optional to also wrap and install comma
        { programs.nix-index-database.comma.enable = true; }
        inputs.stylix.nixosModules.stylix

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
  filesIn = dir: (map (fname: dir + "/${fname}") (builtins.attrNames (builtins.readDir dir)));

  dirsIn =
    dir: inputs.nixpkgs.lib.filterAttrs (_: value: value == "directory") (builtins.readDir dir);

  fileNameOf = path: (builtins.head (builtins.split "\\." (baseNameOf path)));

  # ========================== Buildables ========================== #
  mkSystem = config: inputs.nixpkgs.lib.nixosSystem (mkSystemAtts false config);

  mkStableSystem = config: inputs.nixpkgs-stable.lib.nixosSystem (mkSystemAtts true config);

  # ========================== Extenders =========================== #

  # Evaluates nixos/home-manager module and extends it's options / config
  #  wrapper function that return extended Module
  extendModule =
    { path, ... }@args:
    { ... }@margs:
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
            (
              { ... }:
              {
                options = args.extraOptions or { };
                config = args.extraConfig or { };
              }
            )
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
        name = fileNameOf f;
      in
      (extendModule ((extension name) // { path = f; }))
    ) modules;
}
