{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myHomeManager.backup;
in
{
  options.myHomeManager.backup = {
    enable = lib.mkEnableOption "backup tools (rclone, kopia, syncthing)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      rclone
      kopia
    ];

    services.syncthing.enable = true;
  };
}
