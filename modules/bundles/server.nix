{
  lib,
  config,
  ...
}:
let
  cfg = config.myNixOS.bundles.server;
in
{
  options.myNixOS.bundles.server = {
    enable = lib.mkEnableOption "enable server bundle";
  };

  config = lib.mkIf cfg.enable {
    myNixOS.bundles.common.enable = true;
    myNixOS.common-server.enable = true;
  };
}
