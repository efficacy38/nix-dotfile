{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    rclone
    kopia
  ];

  services.syncthing.enable = true;
}
