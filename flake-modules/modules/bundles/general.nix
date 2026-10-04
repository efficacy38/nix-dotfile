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
        enable = lib.mkEnableOption "general bundle (minimal + git pack, just, utilities, agents, podman, k8s)";
      };

      config = lib.mkIf cfg.enable {
        my = {
          bundles.minimal.enable = true;

          system.backup.enable = true;
          devpack = {
            enable = true;
            git.pack.enable = true;
            just.enable = true;
            utils.enable = true;
            agents.enable = true;
            podman.enable = true;
            k8s.enable = true;
          };
        };
      };
    };
}
