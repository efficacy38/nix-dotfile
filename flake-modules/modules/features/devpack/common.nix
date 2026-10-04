# Common devpack configuration (NixOS + home-manager options definition)
_: {
  # NixOS: devpack system config
  flake.nixosModules.devpack =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.my.devpack;
    in
    {
      options.my.devpack = {
        enable = lib.mkEnableOption "enable devpack configuration";
        podman.enable = lib.mkEnableOption "enable podman and docker container runtimes";
        csccUtil.enable = lib.mkEnableOption "enable cscc-util";
        tailscale.enable = lib.mkEnableOption "enable tailscale";
      };

      config = lib.mkIf (cfg.enable && cfg.podman.enable) {
        virtualisation.podman.enable = lib.mkDefault true;
        virtualisation.docker.enable = lib.mkDefault true;
      };
    };

  # Home-manager: devpack options definition
  flake.homeModules.devpack =
    { lib, ... }:
    {
      options.my.devpack = {
        enable = lib.mkEnableOption "devpack home-manager configuration";
        git = {
          enable = lib.mkEnableOption "git core configuration (git, ssh, signing)";
          pack.enable = lib.mkEnableOption "git tooling pack (gh, glab, lazygit, diff-so-fancy)";
        };
        nvim = {
          enable = lib.mkEnableOption "neovim as the default editor (no configuration)";
          pack.enable = lib.mkEnableOption "AstroNvim configuration and full language-server toolchain";
        };
        shell.enable = lib.mkEnableOption "shell environment (zsh, prompt, fuzzy finding, tmux)";
        gpg.enable = lib.mkEnableOption "GPG and Yubikey configuration";
        just.enable = lib.mkEnableOption "just command runner";
        k8s.enable = lib.mkEnableOption "Kubernetes tools";
        podman.enable = lib.mkEnableOption "podman container tools";
        utils.enable = lib.mkEnableOption "base utility packages";
        ai.enable = lib.mkEnableOption "AI/LLM tooling (agent CLIs, playwright)";
        gui.enable = lib.mkEnableOption "GUI/desktop tools (flatpak, emacs, clipboard)";
        agents.enable = lib.mkEnableOption "AI agent skills and dotfiles";
      };
    };
}
