{
  lib,
  config,
  ...
}:
let
  cfg = config.myNixOS.incus;
in
{
  options.myNixOS.incus = {
    enable = lib.mkEnableOption "Incus virtualization";
    uiEnable = lib.mkEnableOption "Incus web UI" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.incus = {
      enable = true;
      ui.enable = cfg.uiEnable;
    };
  };
}
