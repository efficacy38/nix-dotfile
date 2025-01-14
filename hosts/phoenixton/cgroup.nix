{
  lib,
  config,
  pkgs,
  pkgs-stable,
  ...
}:
{
  ssystemPackages = [
    pkgs-stable.protonmail-desktop
    pkgs-stable.protonmail-bridge
    pkgs-stable.protonmail-bridge-gui
  ];

  # systemd.services."openfortivpn@" = {
  #   enable = true;
  #   description = "OpenFortiVPN for %I";
  #   after = [ "network-online.target" ];
  #   wants = [
  #     "network-online.target"
  #     "systemd-networkd-wait-online.service"
  #   ];
  #
  #   serviceConfig = {
  #     ExecStart = ''
  #       ${pkgs.openfortivpn}/bin/openfortivpn -c /etc/openfortivpn/%I.conf --password=''${PASSWD}
  #     '';
  #     EnvironmentFile = "${config.sops.templates."cscc_password".path}";
  #     # TODO: limit the privilege of openfortivpn
  #     # User = "openfortivpn";
  #     # AmbientCapabilities = "cap_net_admin";
  #   };
  # };
}
