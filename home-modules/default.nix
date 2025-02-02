{
  config,
  lib,
  myLib,
  ...
}: let
  cfg = config.myHomeManager;
  # Taking all modules in ./features and adding enables to them
  features = myLib.extendModules (name: {
    extraOptions = {
      myHomeManager.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
    };

    configExtension = config: (lib.mkIf cfg.${name}.enable config);
  }) (myLib.filesIn ./features);

  bundlers = myLib.extendModules (name: {
    extraOptions = {
      myHomeManager.${name}.enable = lib.mkEnableOption "enable my ${name} configuration";
    };

    configExtension = config: (lib.mkIf cfg.${name}.enable config);
  }) (myLib.filesIn ./bundlers);
in {
  config = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.

    home.username = "efficacy38";
    home.homeDirectory = "/home/efficacy38";

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    # enable shells
    # programs.bash.enable = true;
    nixpkgs.config.allowUnfree = true;
  };

  imports = [] ++ features ++ bundlers;
}
