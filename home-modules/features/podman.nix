{
  options,
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.myHomeManager.podman;
in
{
  options.myHomeManager.podman = {
    enable = lib.mkEnableOption "podman container tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      podman-compose
    ];
    services.podman =
      {
        enable = true;
      }
      // lib.optionalAttrs (builtins.hasAttr "settings" options.services.podman) {
        settings = {
          policy = {
            "default" = [
              { "type" = "insecureAcceptAnything"; }
            ];
          };

          registries = {
            search = [
              "docker.io"
              "quay.io"
              "gcr.io"
            ];
          };
        };
      };
  };
}
