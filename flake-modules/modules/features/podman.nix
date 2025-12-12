{ ... }:
{
  flake.homeModules.podman =
    {
      options,
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.podman;
    in
    {
      options.my.podman = {
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
    };
}
