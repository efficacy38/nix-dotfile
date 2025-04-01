{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.myHomeManager.podman;

  wrappedPodman = pkgs.writeScriptBin "podman" ''
    ${lib.getExe pkgs.uwsm} app -- ${lib.getExe pkgs.podman} $@
  '';
in
{
  options.myHomeManager.podman = {
    uwsmEnable = lib.mkEnableOption "is wrap podman into uwsm";
  };

  config = {
    services.podman = {
      enable = true;
      package = lib.mkIf cfg.uwsmEnable wrappedPodman;
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
