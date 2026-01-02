_: {
  flake.nixosModules.bundles-server =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.bundles.server;
    in
    {
      options.my.bundles.server = {
        enable = lib.mkEnableOption "enable server bundle";
      };

      config = lib.mkIf cfg.enable {
        my.bundles.common.enable = true;
        my.common-server.enable = true;
      };
    };
}
