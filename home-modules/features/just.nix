{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.myHomeManager.just;
in
{
  options.myHomeManager.just = {
    enable = lib.mkEnableOption "just command runner";
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/just/justfile".text = ''
      list:
        just -gl
      test:
        nh os test
      deploy:
        nh os switch
      update:
        nix flake update
      history:
        nix profile history --profile /nix/var/nix/profiles/system
    '';

    home.packages = with pkgs; [
      just
    ];

    programs.zsh.shellAliases = {
      j = "just -g";
    };

    programs.zsh.initContent = ''
      source <(just --completions zsh)
    '';
  };
}
