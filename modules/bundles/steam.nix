{
  lib,
  config,
  ...
}:
let
  cfg = config.myNixOS.bundles.steam;
in
{
  options.myNixOS.bundles.steam = {
    enable = lib.mkEnableOption "enable steam bundle";
  };

  config = lib.mkIf cfg.enable {
    myNixOS.bundles.common.enable = true;

    myNixOS.steam.enable = true;
    myNixOS.steam.hidpi = false;
  };
}
