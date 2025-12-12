# Virtualization system configurations: incus
{ ... }:
{
  # NixOS: Incus virtualization
  flake.nixosModules.system-incus =
    { config, lib, ... }:
    let
      cfg = config.my.system;
    in
    {
      options.my.system.incus.enable = lib.mkEnableOption "Incus virtualization";
      options.my.system.incus.ui.enable = lib.mkEnableOption "Incus web UI" // {
        default = true;
      };

      config = lib.mkIf cfg.incus.enable {
        virtualisation.incus = {
          enable = true;
          ui.enable = cfg.incus.ui.enable;
        };
      };
    };

  # Home-manager: Incus CLI tools
  flake.homeModules.system-incus =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.system;
    in
    {
      options.my.system.incus.enable = lib.mkEnableOption "incus CLI tools";

      config = lib.mkIf cfg.incus.enable {
        home.packages = with pkgs; [
          incus
          virt-viewer
        ];
      };
    };
}
