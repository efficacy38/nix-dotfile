_: {
  flake.homeModules.bundles-general =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.bundles.general;
    in
    {
      options.my.bundles.general = {
        enable = lib.mkEnableOption "general bundle (minimal + backup, podman, utils, k8s)";
      };

      config = lib.mkIf cfg.enable {
        my = {
          bundles.minimal.enable = true;

          system.backup.enable = true;
          devpack = {
            enable = true;
            podman.enable = true;
            utils.enable = true;
            k8s.enable = true;
          };
        };
      };
    };
}
