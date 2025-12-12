{
  config,
  lib,
  inputs,
  ...
}:
let
  import-tree = import inputs.import-tree;
in
{
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

  imports = [
    (import-tree ./features)
    (import-tree ./bundles)
  ];
}
