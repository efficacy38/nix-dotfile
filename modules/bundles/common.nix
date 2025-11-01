{
  lib,
  config,
  ...
}:
let
  cfg = config.myNixOS.bundles.common;
in
{
  options.myNixOS.bundles.common = {
    enable = lib.mkEnableOption "enable common bundle";
  };

  config = lib.mkIf cfg.enable {
    myNixOS.common.enable = true;

    myNixOS.main-user.enable = true;
    myNixOS.main-user.userName = "efficacy38";
  };
}
