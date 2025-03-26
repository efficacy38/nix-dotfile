{
  pkgs,
  lib,
  ...
}:
let
  wrappedPodman = pkgs.writeScriptBin "podman" ''
    ${lib.getExe pkgs.uwsm} app -- ${lib.getExe pkgs.podman} $@
  '';
in
{
  services.podman = {
    enable = true;
    package = wrappedPodman;
  };
}
