{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
let
  secretpath = builtins.toString inputs.nix-secrets;
  cfSecret = {
    sopsFile = "${secretpath}/secrets/cf.yaml";
    format = "yaml";
  };

  # domain -> backend destination
  domains = {
    "kavita.homelab.csjhuang.net" = "http://127.0.0.1:5000";
  };

  mkReverseProxy = domain: destination: {
    routers.${domain} = {
      rule = "Host(`${domain}`)";
      service = domain;
      entryPoints = [ "websecure" ];
      tls.certResolver = "cloudflare";
    };
    services.${domain}.loadBalancer.servers = [ { url = destination; } ];
  };
in
{
  my = {
    users.efficacy38 = {
      type = "developing";
      isAdmin = true;
      extraHomeConfig = import ./home.nix;
    };
    devpack = {
      enable = true;
    };
  };

  sops = {
    secrets."cf_zone_edit" = cfSecret;
    templates.traefikSecretEnv.content = ''
      # lego (used by Traefik for the ACME DNS-01 challenge) reads this name.
      CF_DNS_API_TOKEN=${config.sops.placeholder."cf_zone_edit"}
    '';
  };

  systemd.tmpfiles.rules = [ "d /srv/kavita 0755 kavita kavita -" ];

  # TODO: Kavita manages its own config in /var/lib/kavita/config/appsettings.json
  # Current kavita module isn't good enough, it would override the
  # appsettings.json, maybe we can contribute the merge feature
  users.users.kavita = {
    isSystemUser = true;
    group = "kavita";
    home = "/var/lib/kavita";
  };
  users.groups.kavita = { };

  systemd.services.kavita = {
    description = "Kavita reading server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      User = "kavita";
      Group = "kavita";
      WorkingDirectory = "/var/lib/kavita";
      ExecStart = lib.getExe pkgs.kavita;
      Restart = "always";
      RestartSec = 5;
      KillMode = "process";
      TimeoutStopSec = 20;
      StateDirectory = "kavita";
      StateDirectoryMode = "0750";
    };
  };

  services.traefik = {
    enable = true;
    environmentFiles = [
      "${config.sops.templates."traefikSecretEnv".path}"
    ];
    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure = {
          address = ":443";
          http.tls.certResolver = "cloudflare";
        };
      };

      # Cloudflare ACME (DNS-01) resolver skeleton.
      # Fill in `email`, then point dynamic routers at it, e.g.:
      #   dynamicConfigOptions.http.routers.<name> = {
      #     rule = "Host(`example.com`)";
      #     service = "<name>";
      #     tls.certResolver = "cloudflare";
      #   };
      certificatesResolvers.cloudflare.acme = {
        email = "efficacy38@gmail.com";
        storage = "/var/lib/traefik/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = [
            "1.1.1.1:53"
            "8.8.8.8:53"
          ];
        };
      };
    };

    # Auto-generated reverse proxies from `domains`.
    dynamicConfigOptions.http = lib.foldl' lib.recursiveUpdate { } (
      lib.mapAttrsToList mkReverseProxy domains
    );
  };

  networking.firewall.allowedTCPPorts = [
    53
    80
    443
  ];

  networking.firewall.allowedUDPPorts = [ 53 ];
}
