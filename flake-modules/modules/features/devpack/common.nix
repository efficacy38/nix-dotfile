# Common devpack configuration (NixOS + home-manager options definition)
_:
{
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
        csccUtil.enable = lib.mkEnableOption "enable cscc-util";
        tailscale.enable = lib.mkEnableOption "enable tailscale";
      };

      config = lib.mkIf cfg.enable {
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
        git.enable = lib.mkEnableOption "git configuration";
        nvim.enable = lib.mkEnableOption "neovim configuration";
        tmux.enable = lib.mkEnableOption "tmux terminal multiplexer";
        zsh.enable = lib.mkEnableOption "zsh configuration";
        gpg.enable = lib.mkEnableOption "GPG and Yubikey configuration";
        just.enable = lib.mkEnableOption "just command runner";
        k8s.enable = lib.mkEnableOption "Kubernetes tools";
        podman.enable = lib.mkEnableOption "podman container tools";
        utils.enable = lib.mkEnableOption "utility packages";
      };
    };
}
