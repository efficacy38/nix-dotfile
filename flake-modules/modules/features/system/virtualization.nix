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
      options.my.system.incusEnable = lib.mkEnableOption "Incus virtualization";
      options.my.system.incusUiEnable = lib.mkEnableOption "Incus web UI" // { default = true; };

      config = lib.mkIf cfg.incusEnable {
        virtualisation.incus = {
          enable = true;
          ui.enable = cfg.incusUiEnable;
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
      options.my.system.incusEnable = lib.mkEnableOption "incus CLI tools";

      config = lib.mkIf cfg.incusEnable {
        home.packages = with pkgs; [
          incus
          virt-viewer
        ];
      };
    };
}
