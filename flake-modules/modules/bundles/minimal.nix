{ ... }:
{
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
        enable = lib.mkEnableOption "minimal bundle (git, gpg, incus, just, tmux, zsh)";
      };

      config = lib.mkIf cfg.enable {
        nixpkgs = {
          config = {
            experimental-features = "nix-command flakes";
          };
        };

        my = {
          devpack = {
            enable = true;
            gitEnable = true;
            gpgEnable = true;
            justEnable = true;
            tmuxEnable = true;
            zshEnable = true;
          };
          system.incusEnable = true;
        };
      };
    };
}
