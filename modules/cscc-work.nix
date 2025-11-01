{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.myNixOS.cscc-work;
  secretpath = builtins.toString inputs.nix-secrets;
  nycuSecret = {
    sopsFile = "${secretpath}/secrets/desktop.yaml";
    format = "yaml";
  };
in
{
  options.myNixOS.cscc-work = {
    enable = lib.mkEnableOption "enable cscc change vpn script module";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      openfortivpn
    ];

    # users.users.openfortivpn = {
    #   isSystemUser = true;
    #   description = "do openfortivpn operations";
    #   group = "openfortivpn";
    # };
    # users.groups.openfortivpn = { };

    # vpn connection secrets
    sops = {
      secrets = {
        "cscc/username" = nycuSecret;
        "cscc/password" = nycuSecret;
        "cscc/vpn_host" = nycuSecret;
        "nycu/username" = nycuSecret;
        "nycu/password" = nycuSecret;
        "nycu/vpn_host" = nycuSecret;
      };

      templates = {
        "cscc_test_vpn.conf" = {
          content = ''
            host = ${config.sops.placeholder."cscc/vpn_host"}
            port = 443
            realm = test
            username = ${config.sops.placeholder."cscc/username"}
            # use-resolvconf = 1
            # set-dns = 1
            pppd-use-peerdns = 0
            trusted-cert = d9921fc2c7702e215826ea75b17511f3d59b7d5ed328b92e29b79307e90c84f9
            pppd-ifname = ppp0
            password = ${config.sops.placeholder."cscc/password"}
          '';
          # owner = "openfortivpn";
        };

        "cscc_prod_vpn.conf" = {
          content = ''
            host = ${config.sops.placeholder."cscc/vpn_host"}
            port = 443
            realm = prod
            username = ${config.sops.placeholder."cscc/username"}
            # use-resolvconf = 1
            # set-dns = 1
            pppd-use-peerdns = 0
            trusted-cert = d9921fc2c7702e215826ea75b17511f3d59b7d5ed328b92e29b79307e90c84f9
            pppd-ifname = ppp1
            password = ${config.sops.placeholder."cscc/password"}
          '';
        };

        "nycu_vpn.conf" = {
          content = ''
            host = ${config.sops.placeholder."nycu/vpn_host"}
            port = 443
            username = ${config.sops.placeholder."nycu/username"}
            # use-resolvconf = 1
            # set-dns = 1
            # pppd-use-peerdns = 0
            pppd-ifname = ppp2
            password = ${config.sops.placeholder."nycu/password"}
          '';
        };
      };
    };

    environment.etc = {
      "openfortivpn/cscc_test.conf".source = "${config.sops.templates."cscc_test_vpn.conf".path}";
      "openfortivpn/cscc_prod.conf".source = "${config.sops.templates."cscc_prod_vpn.conf".path}";
      "openfortivpn/nycu_vpn.conf".source = "${config.sops.templates."nycu_vpn.conf".path}";
    };

    systemd.services."openfortivpn@" = {
      enable = true;
      description = "OpenFortiVPN for %I";
      after = [ "network-online.target" ];
      wants = [
        "network-online.target"
        "systemd-networkd-wait-online.service"
      ];

      serviceConfig = {
        ExecStart = "${pkgs.openfortivpn}/bin/openfortivpn -c /etc/openfortivpn/%I.conf";
        # TODO: limit the privilege of openfortivpn
        # User = "openfortivpn";
        # AmbientCapabilities = "cap_net_admin";
      };
    };
  };
}
