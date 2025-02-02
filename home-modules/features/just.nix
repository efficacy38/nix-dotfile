{ pkgs, ... }:
{
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

  programs.zsh.initExtra = ''
    source <(just --completions zsh)
  '';
}
