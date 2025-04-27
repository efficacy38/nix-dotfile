{
  options,
  pkgs,
  lib,
  ...
}:
{
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
}
