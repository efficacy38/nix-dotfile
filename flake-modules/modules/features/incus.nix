{ ... }:
{
  # NixOS module
  flake.nixosModules.incus = { config, lib, ... }:
    let
      cfg = config.my.incus;
    in
    {
      options.my.incus = {
        enable = lib.mkEnableOption "Incus virtualization";
        uiEnable = lib.mkEnableOption "Incus web UI" // { default = true; };
      };

      config = lib.mkIf cfg.enable {
        virtualisation.incus = {
          enable = true;
          ui.enable = cfg.uiEnable;
        };
      };
    };

  # Home-manager module
  flake.homeModules.incus = { config, lib, pkgs, ... }:
    let
      cfg = config.my.incus;
    in
    {
      options.my.incus = {
        enable = lib.mkEnableOption "incus CLI tools";
      };

      config = lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          incus
          virt-viewer
        ];
      };
    };
}
