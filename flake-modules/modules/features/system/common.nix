_: {
  flake.nixosModules.common =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.my.common;
    in
    {
      options.my.common = {
        enable = lib.mkEnableOption "enable common configuration for all nixos";
        resolvedDnssec = lib.mkEnableOption "enable strict DNSSEC and DNS-over-TLS";
      };

      config = lib.mkIf cfg.enable {
        # Enable observability tools by default
        my.system.observability.enable = lib.mkDefault true;

        # enable nix flake
        nix = {
          settings = {
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            trusted-users = [ "@wheel" ];
            substituters = [
              "https://nix-community.cachix.org"
              "https://cache.nixos.org/"
            ];
            # 40 is the default value of cache, cache.nixos.org is 30
            # use 0 as personal cache
            extra-substituters = [
              # "https://nix-cache.csjhuang.net?priority=0"
              "https://cache.numtide.com"
            ];
            extra-trusted-public-keys = [
              "nix-cache.csjhuang.net-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
            ];
            trusted-public-keys = [
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            ];

            lazy-trees = true;
            eval-cores = 0;
          };

          extraOptions = ''
            binary-caches-parallel-connections = 24

            # Ensure we can still build when missing-server is not accessible
            fallback = true
          '';
        };

        stylix.enable = lib.mkDefault false;

        # Bootloader.
        boot = {
          loader = {
            systemd-boot.enable = lib.mkDefault true;
            efi.canTouchEfiVariables = lib.mkDefault true;
          };
          tmp.useTmpfs = lib.mkDefault true;
        };

        # enable sshd
        services = {
          pcscd.enable = true;
          openssh.enable = true;
          # fail2ban would consume logs from rsyslog(/var/log/auth.log)
          rsyslogd.enable = true;
          rsyslogd.extraConfig = ''
            auth,authpriv.* /var/log/auth.log
          '';
          fail2ban = {
            enable = true;
            ignoreIP = [
              # local
              "192.168.0.0/16"

              # personal vpn
              "100.64.0.0/24"

              # NCTU ip range
              "140.113.0.0/16"
            ];
          };
          envfs.enable = true;
        };

        # Set your time zone.
        time.timeZone = "Asia/Taipei";

        # Select internationalisation properties.
        i18n.defaultLocale = "en_US.UTF-8";

        i18n.extraLocaleSettings = {
          LC_ADDRESS = "zh_TW.UTF-8";
          LC_IDENTIFICATION = "zh_TW.UTF-8";
          LC_MEASUREMENT = "zh_TW.UTF-8";
          LC_MONETARY = "zh_TW.UTF-8";
          LC_NAME = "zh_TW.UTF-8";
          LC_NUMERIC = "zh_TW.UTF-8";
          LC_PAPER = "zh_TW.UTF-8";
          LC_TELEPHONE = "zh_TW.UTF-8";
          LC_TIME = "zh_TW.UTF-8";
        };

        # systemd resolved
        services.resolved = {
          enable = true;
          dnssec = if cfg.resolvedDnssec then "true" else lib.mkDefault "false";
          domains = lib.mkIf cfg.resolvedDnssec [ "~." ];
          dnsovertls = if cfg.resolvedDnssec then "true" else lib.mkDefault "opportunistic";
        };

        # Allow unfree packages
        nixpkgs.config.allowUnfree = true;
        hardware.enableAllFirmware = true;

        environment = {
          # add completion for zsh, links completion to $HOME/.nix-profile/share/zsh
          pathsToLink = [ "/share/zsh" ];
          variables.EDITOR = "vim";
          variables.ENVFS_RESOLVE_ALWAYS = 1;
          systemPackages = with pkgs; [
            # management utils
            curl
            git
            neovim
            vim
            wget

            # compression
            gnutar
            unzip

            # system utils
            man-db
            nftables
            wireguard-tools

            # sops
            age
            gnupg
            sops

            # vpn
            openfortivpn
          ];
        };

        sops = {
          defaultSopsFile = ../../../../modules/secrets/default.yaml;
          defaultSopsFormat = "yaml";
          age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        };

        networking.nftables.enable = true;
        networking.firewall.enable = lib.mkDefault true;

        programs = {
          zsh.enable = true;
          # Some programs need SUID wrappers, can be configured further or are
          # started in user sessions.
          mtr.enable = true;
          nix-ld = {
            enable = true;
            libraries = with pkgs; [
              stdenv.cc.cc
            ];
          };
          nh = {
            enable = true;
            clean = {
              enable = true;
              dates = "weekly";
              extraArgs = "--keep 14 --keep-since 14d";
            };
            flake = "/etc/nixos/nix-dotfile";
          };
        };

        # my rootca
        security.pki.certificates = [
          # personal CA
          ''
            -----BEGIN CERTIFICATE-----
            MIIGcTCCBFmgAwIBAgIUSJABWck58e5IIe/sO/hbJguXj78wDQYJKoZIhvcNAQEL
            BQAwgb8xJDAiBgNVBAMMG3Jvb3QuaG9tZWxhYi0xLmNzamh1YW5nLm5ldDELMAkG
            A1UEBhMCVFcxDzANBgNVBAgMBlRhaXdhbjEUMBIGA1UEBwwLVGFpbmFuIENpdHkx
            IDAeBgNVBAoMF0NhaS1TaWFuIEpodWFuZyBIb21lbGFiMRwwGgYDVQQLDBNob21l
            bGFiLTEsIGtleXN0b3JlMSMwIQYJKoZIhvcNAQkBFhRlZmZpY2FjeTM4QHByb3Rv
            bi5tZTAeFw0yNTAyMTUyMTI3MTZaFw00NTAyMTAyMTI3MTZaMIG/MSQwIgYDVQQD
            DBtyb290LmhvbWVsYWItMS5jc2podWFuZy5uZXQxCzAJBgNVBAYTAlRXMQ8wDQYD
            VQQIDAZUYWl3YW4xFDASBgNVBAcMC1RhaW5hbiBDaXR5MSAwHgYDVQQKDBdDYWkt
            U2lhbiBKaHVhbmcgSG9tZWxhYjEcMBoGA1UECwwTaG9tZWxhYi0xLCBrZXlzdG9y
            ZTEjMCEGCSqGSIb3DQEJARYUZWZmaWNhY3kzOEBwcm90b24ubWUwggIiMA0GCSqG
            SIb3DQEBAQUAA4ICDwAwggIKAoICAQC2E0HHCU7MjAbFZx1KxkZS5i7Hb1r12Ekk
            R/0zKg9++Nyxs4vF55AdfF2J7IEgLpNEH+p6ueLgpugtaLYF3UQgIDPZEJinjWmh
            V8V/obFrVfMl68vkMkA/DXq7SktYb6NwsNirg6E5F4++ES5+6h4noHLOl1hxIcXN
            dRddq6U2Pp7dIi/qqtnohlbnm92tH0+UUE3riPRbFKMmHKKr77eYliqUfJ+0bS5D
            G6afhKpnEi3QMuS0Kv8DbyxwjI6X53B8KYk73pEH6S8dCirHL5Tb+ovKu5I0Stej
            4OYZXbYxdvXXHdPBmxzsJzK0dYEGMrrF7WO07U8pRkruEeH2VzubabRdTyEcKi14
            rwOe4i/vaPmuEuCfIWXD1CcTsjGZygbJmSPpnECWMMxhmpUC7aeoGod2Y/Oojtea
            SCAIuI2xj8Ol45ddSQYCT45EZ0zaPxpSh1nPlGgL1Fv81qXPjy7iIOh7Zxu2PE5J
            ZiLWH6MNwVzIcrx5kpY8/0OL8GUPLqK2rXaLlStxsapea+JJiEVuIGUCZyksg98M
            0kxFPbMDyp8IVOBp9goEoRRHNNt8Z7aF4/9Rn5AyDF1wU1kwEHhgPD9e5WHc/J5C
            3CFHt6y2CE4WDtB1zln+9hFJeGoFgnhUwLeCpd1BaA4w7quB3EqkW1BVkfS9cW2p
            T4CJ+EAghQIDAQABo2MwYTAdBgNVHQ4EFgQUADc2XmeNL2zh5JX7TOEKyr/9hSgw
            HwYDVR0jBBgwFoAUADc2XmeNL2zh5JX7TOEKyr/9hSgwDwYDVR0TAQH/BAUwAwEB
            /zAOBgNVHQ8BAf8EBAMCAYYwDQYJKoZIhvcNAQELBQADggIBAC9Su7GZmIJs1n53
            9iOmFM93H4XP2FCBT+xz1IXR9ZRoW3ozilG9sE34I5c3B783CwSyHrXYtYfh+zpH
            F3HXJjFbcjSbE0sxxW4mTjUNCg1kBGb1lgdjp2uWaHE4qoOv8Az4CElKX4x2ofVb
            1C1/J/9coouDLv44bKHiEDtthHswcsdXAvKzSqtkLphquU33Y+bPgg5kj5iR3UkW
            Hu6Y+pWzBJG3AAkLQGypKHjQ6JXZQJ0uVz3XU5y926e8i4htQ1bGiCKxMM+1iEKE
            FnLvy7/Rse6/sBiRu0S+HFjUDTgdyHPW/f+2l9FnCCxES5s1CzaDhhQUqTtxgStt
            2Ys5DXsWBudpczVtz7uWhsXpofPSl8NbRMtWFjTq86s4LWV+4yMjA1d8W6PVA1i2
            Wx0cpnFFO8AFSQy/AuSDZjqBZq85Kqna42diJioRpk9TKEQVQHjWplzs4KsNWjnk
            5yuEbaUuiWctO2+EsGCvZUkDbhbmqfg/zEGb/6ZliojK9KXiHwNS++LdIJx1BFHv
            jCk6Uq2kT8HGAmj9k1VEDZNxlaCVY/95OZBa3Jlgvt4Z2ckig+aRg0sLtx/r0v+N
            NiSy3S0n2sjl1JXW1yVMZ8sdbRPrfqjEn05kpJhzHOv8/e5wzUyhW1xxYQWFT7Qp
            wZCb/WxQ55tpV38MVojsUDuWcS8A
            -----END CERTIFICATE-----
          ''
        ];
      };
    };
}
