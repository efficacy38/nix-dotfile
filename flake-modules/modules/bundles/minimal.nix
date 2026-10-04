_: {
  flake.homeModules.bundles-minimal =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.bundles.minimal;
    in
    {
      options.my.bundles.minimal = {
        enable = lib.mkEnableOption "minimal bundle (git, shell; vim from common)";
      };

      config = lib.mkIf cfg.enable {
        nixpkgs = {
          config = {
            experimental-features = "nix-command flakes";
          };
        };

        my = {
          dotfiles.inStore = lib.mkDefault true;

          devpack = {
            enable = true;
            git.enable = true;
            shell.enable = true;
          };
        };
      };
    };
}
