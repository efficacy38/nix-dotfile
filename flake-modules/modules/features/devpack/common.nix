# Common devpack configuration (NixOS + home-manager options definition)
{ ... }:
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
        csccUtilEnable = lib.mkEnableOption "enable cscc-util";
        tailscaleEnable = lib.mkEnableOption "enable tailscale";
      };

      config = lib.mkIf cfg.enable {
        virtualisation.podman.enable = lib.mkDefault true;
        virtualisation.docker.enable = lib.mkDefault true;
      };
    };

  # Home-manager: devpack options definition
  flake.homeModules.devpack =
    { lib, config, ... }:
    let
      cfg = config.my.devpack;
    in
    {
      options.my.devpack = {
        enable = lib.mkEnableOption "devpack home-manager configuration";
        gitEnable = lib.mkEnableOption "git configuration";
        nvimEnable = lib.mkEnableOption "neovim configuration";
        tmuxEnable = lib.mkEnableOption "tmux terminal multiplexer";
        zshEnable = lib.mkEnableOption "zsh configuration";
        gpgEnable = lib.mkEnableOption "GPG and Yubikey configuration";
        justEnable = lib.mkEnableOption "just command runner";
        k8sEnable = lib.mkEnableOption "Kubernetes tools";
        podmanEnable = lib.mkEnableOption "podman container tools";
        utilsEnable = lib.mkEnableOption "utility packages";
      };
    };
}
