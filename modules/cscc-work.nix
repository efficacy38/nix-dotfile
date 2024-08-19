{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.cscc-work;
  # csccSecret.sopsFile = "../secrets/cscc.yaml";
  # 
in
{
  options.cscc-work = {
    enable = lib.mkEnableOption "enable cscc change vpn script module";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      openfortivpn
    ];

    # vpn connection secrets
    sops.secrets."cscc.username" = { };
    sops.secrets."cscc.passowrd" = { };
    sops.secrets."cscc.vpn_host" = { };

    # TODO: maybe map can handle those boilerplate code
    environment.etc."/etc/openfortivpn/cscc_test.conf" = ''
      host = ${config.sops.secrets.cscc.vpn_host}
      port = 443
      realm = test
      username = ${config.sops.secrets.username}
      # use-resolvconf = 1
      # set-dns = 1
      pppd-use-peerdns = 0
      trusted-cert = d986835a97df3d16cad088a22c6ac8de5a9f80aef1d2c1cde873d068867a03a6
      pppd-ifname = ppp0
    '';

    environment.etc."/etc/openfortivpn/cscc_prod.conf" = ''
      host = ${config.sops.secrets.cscc.vpn_host}
      port = 443
      realm = prod
      username = ${config.sops.secrets.username}
      # use-resolvconf = 1
      # set-dns = 1
      pppd-use-peerdns = 0
      trusted-cert = d986835a97df3d16cad088a22c6ac8de5a9f80aef1d2c1cde873d068867a03a6
      pppd-ifname = ppp0
    '';

    systemd.services."openfortivpn@" = {
      enable = true;
      description = "OpenFortiVPN for %I";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" "systemd-networkd-wait-online.service" ];

      serviceConfig = {
        ExecStart = "${pkgs.openfortivpn}/bin/openfortivpn -c /etc/openfortivpn/%I.conf --password = ''$(cat ${config.sops.secrets.password})";
        EnvironmentFile = "/etc/default/openfortivpn";
      };
    };
  };
}
