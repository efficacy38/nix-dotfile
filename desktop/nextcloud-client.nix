{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    nextcloud-client
  ];
  services.nextcloud-client.enable = true;
  services.nextcloud-client.startInBackground = true;
}
