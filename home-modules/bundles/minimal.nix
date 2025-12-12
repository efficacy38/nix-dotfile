{
  lib,
  config,
  ...
}:
let
  cfg = config.myHomeManager.bundles.minimal;
in
{
  options.myHomeManager.bundles.minimal = {
    enable = lib.mkEnableOption "minimal bundle (git, gpg, incus, just, tmux, zsh)";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs = {
      config = {
        experimental-features = "nix-command flakes";
      };
    };

    myHomeManager = {
      git.enable = true;
      gpg.enable = true;
      incus.enable = true;
      just.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };
  };
}
