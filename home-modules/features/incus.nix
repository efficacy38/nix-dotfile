{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.myHomeManager.incus;
in
{
  options.myHomeManager.incus = {
    enable = lib.mkEnableOption "incus CLI tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      incus
      virt-viewer
    ];
  };
}
