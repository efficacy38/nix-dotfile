{ ... }:
{
  flake.homeModules.utils =
    {
      pkgs,
      pkgs-unstable,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.utils;
    in
    {
      options.my.utils = {
        enable = lib.mkEnableOption "utility packages";
      };

      config = lib.mkIf cfg.enable {
        home.packages = with pkgs-unstable; [
          curl
          wget
          ripgrep
          boxes
          ctags
          flatpak
          openssl
          cfssl
          dnsutils
          ansible
          mosh
          gemini-cli
          claude-code
          claude-monitor

          wl-clipboard
          cachix
          statix

          entr

          pkgs.personal-script

          nixos-shell
        ];

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
          enableZshIntegration = true;
        };

        programs.emacs.enable = true;
      };
    };
}
