{ lib, pkgs, ... }:
let
  zone = "homelab.csjhuang.net";
in
{
  # systemd-resolved is unnecessary here; the host resolves through AdGuardHome.
  # Manage /etc/resolv.conf directly: openresolv would otherwise try to write
  # through the stale systemd-resolved stub symlink and fail.
  services.resolved.enable = lib.mkForce false;
  networking.resolvconf.enable = lib.mkForce false;
  environment.etc."resolv.conf".text = ''
    nameserver 127.0.0.1
  '';

  my = {
    common-server.enable = true;
    users.efficacy38 = {
      type = "developing";
      isAdmin = true;
      extraHomeConfig = import ./home.nix;
    };
    devpack = {
      enable = true;
    };
    system.netbird.enable = true;
  };

  # BIND: authoritative secondary (slave) for the homelab zone. The primary
  # (10.7.205.1) only permits zone transfers on port 5300, so this host pulls
  # a copy over AXFR and answers queries for the zone locally.
  services.bind = {
    enable = true;
    listenOn = [ "127.0.0.1" ]; # AdGuardHome owns :53
    listenOnPort = 5300;
    # Without this BIND also binds IPv6 :53, which the firewall opens.
    listenOnIpv6 = [ ];
    directory = "/var/lib/bind";
    zones."${zone}" = {
      master = false; # named `type slave`
      file = "/var/lib/bind/db.${zone}";
      masters = [ "10.7.205.1 port 5300" ]; # AXFR-only source
      allowQuery = [ "127.0.0.1" ];
    };
    # Authoritative only; AdGuardHome is the recursive resolver.
    extraOptions = "recursion no;";
  };

  # BIND tooling: named-checkconf/rndc from bind, dig from dnsutils.
  environment.systemPackages = [
    pkgs.bind
    pkgs.dnsutils
  ];

  # AdGuardHome: minimal forwarding front-end
  services.adguardhome = {
    enable = true;
    mutableSettings = true;
    settings = {
      dns = {
        port = 53;
        bind_hosts = [
          "0.0.0.0"
        ];
        upstream_dns = [
          "[/${zone}/]127.0.0.1:5300"
          "1.1.1.1"
          "1.0.0.1"
        ];
        bootstrap_dns = [
          "9.9.9.10"
          "149.112.112.10"
        ];
      };
      # filtering.filtering_enabled = false;
      # querylog.enabled = false;
      # statistics.enabled = false;
    };
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
