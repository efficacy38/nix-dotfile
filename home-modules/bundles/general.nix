{
  lib,
  config,
  ...
}:
let
  cfg = config.myHomeManager.bundles.general;
in
{
  options.myHomeManager.bundles.general = {
    enable = lib.mkEnableOption "general bundle (minimal + backup, podman, utils, k8s)";
  };

  config = lib.mkIf cfg.enable {
    myHomeManager = {
      bundles.minimal.enable = true;

      backup.enable = true;
      podman.enable = true;
      utils.enable = true;
      zsh.enable = true;
      k8s.enable = true;
    };
  };
}
