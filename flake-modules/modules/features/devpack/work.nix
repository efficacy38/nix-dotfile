# Work-related configurations: cscc-work, tailscale
{ ... }:
{
  # NixOS: CSCC work VPN configuration
  flake.nixosModules.devpack-cscc-work =
    {
      lib,
      config,
      pkgs,
      inputs,
      ...
    }:
    let
      cfg = config.my.devpack;
      secretpath = builtins.toString inputs.nix-secrets;
      nycuSecret = {
        sopsFile = "${secretpath}/secrets/desktop.yaml";
        format = "yaml";
      };
    in
    {
      config = lib.mkIf (cfg.enable && cfg.csccUtilEnable) {
        environment.systemPackages = with pkgs; [ openfortivpn ];

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
                pppd-use-peerdns = 0
                trusted-cert = d9921fc2c7702e215826ea75b17511f3d59b7d5ed328b92e29b79307e90c84f9
                pppd-ifname = ppp0
                password = ${config.sops.placeholder."cscc/password"}
              '';
            };

            "cscc_prod_vpn.conf" = {
              content = ''
                host = ${config.sops.placeholder."cscc/vpn_host"}
                port = 443
                realm = prod
                username = ${config.sops.placeholder."cscc/username"}
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
          };
        };
      };
    };

  # NixOS: Tailscale VPN configuration
  flake.nixosModules.devpack-tailscale =
    { lib, config, ... }:
    let
      cfg = config.my.devpack;
    in
    {
      options.my.devpack.tailscaleAsRouter = lib.mkEnableOption "Tailscale as router (enable IP forwarding)";

      config = lib.mkIf (cfg.enable && cfg.tailscaleEnable) {
        services.tailscale = {
          enable = true;
          useRoutingFeatures = if cfg.tailscaleAsRouter then "both" else "client";
          openFirewall = true;
        };
      };
    };
}
