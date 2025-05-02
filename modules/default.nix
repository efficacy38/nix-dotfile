{
  inputs,
  config,
  lib,
  myLib,
  ...
}:
let

  cfg = config.myNixos;
  # Taking all modules in ./features and adding enables to them
  features = myLib.extendModules (name: {
    extraOptions = {
      myNixos.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
    };

    configExtension = config: (lib.mkIf cfg.${name}.enable config);
  }) (myLib.filesIn ./features);

  bundles = myLib.extendModules (name: {
    extraOptions = {
      myNixos.bundles.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
    };

    configExtension = config: (lib.mkIf cfg.bundles.${name}.enable config);
  }) (myLib.filesIn ./bundles);
in
{

  config = {
    # enable shells
    # programs.bash.enable = true;
    nixpkgs.config.allowUnfree = true;
  };

  imports =
    [
      inputs.sops-nix.nixosModules.sops
    ]
    ++ features
    ++ bundles;
}
