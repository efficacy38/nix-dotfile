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

  # PowerDNS authoritative: writable sqlite backend + DDNS
  services.powerdns = {
    enable = true;
    extraConfig = ''
      launch=gsqlite3
      gsqlite3-database=/var/lib/pdns/pdns.sqlite3
      local-address=127.0.0.1
      local-port=5300
      dnsupdate=yes
      allow-dnsupdate-from=127.0.0.1,10.7.205.0/24
    '';
  };

  # pdnsutil (and the rest of the PowerDNS tools)
  environment.systemPackages = [ pkgs.pdns ];

  # Bootstrap the sqlite DB + schema on first start (runs as User=pdns)
  systemd.services.pdns.serviceConfig.StateDirectory = "pdns";
  systemd.services.pdns.preStart = ''
    if [ ! -e /var/lib/pdns/pdns.sqlite3 ]; then
      ${pkgs.sqlite}/bin/sqlite3 /var/lib/pdns/pdns.sqlite3 \
        < ${pkgs.pdns}/share/doc/pdns/schema.sqlite3.sql
    fi
  '';

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
