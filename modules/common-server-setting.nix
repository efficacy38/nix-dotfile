{
  lib,
  config,
  pkgs,
  pkgs-stable,
  ...
}:
{
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
        "http://nix-cache.homelab-1.csjhuang.net"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-cache.homelab-1.csjhuang.net-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    extraOptions = ''
      binary-caches-parallel-connections = 24
    '';
  };

  environment.variables.EDITOR = "vim";

  # enable sshd
  services.openssh.enable = true;
  services.fail2ban.enable = true;

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
    dnsovertls = "opportunistic";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # this is for nix-helper(nh)
  environment.sessionVariables = {
    # TODO: use main user module to control this
    FLAKE = "/home/efficacy38/Projects/Personal/nix-dotfile";
  };

  environment.systemPackages = with pkgs; [
    # nix helper
    nh
    nix-output-monitor
    nvd

    # management utils
    vim
    neovim
    git
    wget
    curl
    htop

    # compression
    unzip
    gnutar

    # system utils
    man-db
    wireguard-tools
    tcpdump
    nftables

    # sops
    sops
    gnupg
    age

    # vpn
    openfortivpn
    wireguard-tools
  ];
  sops.defaultSopsFile = ../secrets/default.yaml;
  sops.defaultSopsFormat = "yaml";
  # sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  networking.nftables.enable = true;
  networking.firewall.enable = true;

  programs.zsh.enable = true;
  # add completion for zsh, links completion to $HOME/.nix-profile/share/zsh
  environment.pathsToLink = [ "/share/zsh" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  services.pcscd.enable = true;

  # my rootca
  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIGITCCBAmgAwIBAgIUL4rJG5NS4E4kf1BevI6vIeAsSO8wDQYJKoZIhvcNAQEL
      BQAwgZ8xCzAJBgNVBAYTAlRXMQ8wDQYDVQQIDAZUYWl3YW4xFjAUBgNVBAcMDUhz
      aW4tY2h1IENpdHkxGTAXBgNVBAoMEGNzamh1YW5nIGhvbWVsYWIxFDASBgNVBAsM
      C1BlcnNvbmFsIENBMREwDwYDVQQDDAhqZXJyeS5oczEjMCEGCSqGSIb3DQEJARYU
      ZWZmaWNhY3kzOEBnbWFpbC5jb20wHhcNMjQwOTAzMTY0MTM0WhcNMjcwNjI0MTY0
      MTM0WjCBnzELMAkGA1UEBhMCVFcxDzANBgNVBAgMBlRhaXdhbjEWMBQGA1UEBwwN
      SHNpbi1jaHUgQ2l0eTEZMBcGA1UECgwQY3NqaHVhbmcgaG9tZWxhYjEUMBIGA1UE
      CwwLUGVyc29uYWwgQ0ExETAPBgNVBAMMCGplcnJ5LmhzMSMwIQYJKoZIhvcNAQkB
      FhRlZmZpY2FjeTM4QGdtYWlsLmNvbTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCC
      AgoCggIBAL2JVM9go4mbm/RHqLotvoCjp9GBD/LyIh1sB545VTk3jOdbTXmprFcm
      ZABYWM/Ufiu1vDmfKxKS7LCYrFX+C9TfZ/85F1vKnTw2KiRY8zpI8RbhFlj3aB6U
      iTu/FbJSo8DiU3RRIW7qQ4j8KkOFUMy9KdA+CG62wx7pJ0jR1DY34N7LsXj3UEGk
      IqMnKuWJuNCwMEGZB5OeV7ReN9ZUAzEyUZ8sInPaTJzHiu9VFjDjhtIylYN7lxL5
      beTBqtsbXQS2svtNoVj9/0VxfSVE5o3LWqgFF8ifB5svCpR0KHdkRnR9kbSiftIM
      EnaPZGoiD9WHZUHXVzBcZLQHPE9aPIV5brnHbkPYa/5OPTEkZ9QwrZmXHlDahxmj
      wyX1lJT3gkJLvajufGZ6GHVDvUwcKC9yfpNJMZU6xeCnVjXUMQnDN5bEYn1AqyZZ
      +FgcT1dp1T82lfET5zyyBO/K6N+w+Sbc+EvNYlatbc4SE/hLvBgIoIXpQNZQpOMU
      0WQk40dNu6lsnOwDQ8nl4bFyxNvXqsHFbx8MXdIbwJF5AqAPNJNUXdzakNQ88C1c
      5YN3hX8fAQaReF+88zctRzA6OiDIqhTwGpCxz2hncbySUZeBZwL3YRS+eRBp0ZM9
      JNQFuKtsY0F+AxFZYDQ2OZLcmdivZrAc7FkEewBMFbD8O4d0OMyRAgMBAAGjUzBR
      MB0GA1UdDgQWBBTnpMT3mkCvg5qKZvKzqGXhQTH5ljAfBgNVHSMEGDAWgBTnpMT3
      mkCvg5qKZvKzqGXhQTH5ljAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUA
      A4ICAQBIVz7cHVvqYHyWmX/W1jgsvCBXgFcHT3doDguiMz5+c24VSyrWA6bQ6Kjb
      +w/KAmpRMg/COK7zwpN7pWdi8N0p74GkWajy3hg9fmaVZhURApgoWkO26fCFiUbq
      hRd7qXuGWckLNL2uepV4mQ/GFPu/RmxZQy2v9JJgpN6M6FwiIzreN3k5vyaWMI3L
      yBDsDQjZznYJSvM/dx6o0lVIp/6YZFYqhQuH9vqxShCmucxdf/nLbm7hPKzKuYIK
      7ZqMTRyfUMBGKwDG/vQAbfn/abudgJ43e6uDr4JraJ7lZDnUXAM0BC1JMFPSZ8nA
      d5/2v6oaXa/I9oAnsIxzklsOngCM4NMhr0KWkMjoFruybSLpgmjmcjOMY8TMqeyW
      3SlrfiWlbAValLJ34t1Wx9rrlmD1S7q7jHEXsjPZoU6cPJJCKNaDUvCvRbX45ylm
      UObTl5c1Y57+Y7GuAYQzjkZO3RcukY2WzwDh18OOjUo4f3qdHOqlDjUH6B6kKvkr
      Z28qVmKtDPnRN57Ve+/M1MekQld//C04kSGsSovMCFYXKfuW6vPmZZy2UiNTtD0k
      CLaR/mj4RSYX+gXiM6+a1Dh7JYA5L6rB3Y64/9VIWKc4D25z/vwEXqB/KlzIgxPP
      13Il6iJselUShUIPVlk5zss1b8L1UjicNPuH9+Er5JsK4gQ3yw==
      -----END CERTIFICATE-----
    ''
    # cscc root ca
    ''
      -----BEGIN CERTIFICATE-----
      MIIGfTCCBGWgAwIBAgIJANtNHd4pchD1MA0GCSqGSIb3DQEBDQUAMIHUMQswCQYD
      VQQGEwJUVzEPMA0GA1UECAwGVGFpd2FuMRYwFAYDVQQHDA1Ic2luLUNodSBDaXR5
      MScwJQYDVQQKDB5OYXRpb25hbCBDaGlhby1UdW5nIFVuaXZlcnNpdHkxJzAlBgNV
      BAsMHkRlcGFydG1lbnQgb2YgQ29tcHV0ZXIgU2NpZW5jZTEmMCQGA1UEAwwdTkNU
      VSBDUyBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkxIjAgBgkqhkiG9w0BCQEWE2hlbHBA
      Y3MubmN0dS5lZHUudHcwHhcNMTcxMjA2MTc0MzE2WhcNMjcxMjA0MTc0MzE2WjCB
      1DELMAkGA1UEBhMCVFcxDzANBgNVBAgMBlRhaXdhbjEWMBQGA1UEBwwNSHNpbi1D
      aHUgQ2l0eTEnMCUGA1UECgweTmF0aW9uYWwgQ2hpYW8tVHVuZyBVbml2ZXJzaXR5
      MScwJQYDVQQLDB5EZXBhcnRtZW50IG9mIENvbXB1dGVyIFNjaWVuY2UxJjAkBgNV
      BAMMHU5DVFUgQ1MgQ2VydGlmaWNhdGUgQXV0aG9yaXR5MSIwIAYJKoZIhvcNAQkB
      FhNoZWxwQGNzLm5jdHUuZWR1LnR3MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
      CgKCAgEAvOZF59xipyzkRVbWTqMCf94ucr4ze6mTtctDnqpFFRfFC0ksXKVFZbhf
      /N9dSTw+i8WJQY/RZc5jHNx7E+fnNdURBQniyuiXBTTicoVYp1Uef56CAYbEZDfp
      VQmmovcGv8gEuZ4L/CFMwsFFFab2epS7A7u7wk0dnhFBpvC0RigqQIwtlBc/M0WA
      a8C9cwBzxpblpa0TY3pMbI3KPxLnflTrlPqCrlcWCuChen3Z1Lzu5C9EgavPJsYU
      bmGwOayP4cie59dVYzCrmi6/XHMsfWuJ4vAHVOJqV1JeKbS65MfOVE+UVNKAGaLO
      a6RaVcy0M5IAhTGSi+kZeBgVC0c5yoNZ7NHyG1EOOBg6CoNsWW4B8F2780s6ofRG
      Ukl2+HGf6nvqgUsU3cyyZ09OFk4gDTPAj24VSG5uAdCUst1aaTxwl2yr1jNHSy3R
      pxjGkx7DGWBveRwFl9sTxAyD+k/7eJ+ygJk4D5JxaMsOM334aBwsYoqhzwePL7SC
      LXcj92qj4DFasCmQSFUpKkT7YLJvTi16RwGM2qGklSTfxm5jWCI6XXNTkgyPZXZd
      76QnyCkT3w224M/g5MziPFyMrHfYnJl2tX2AKq6qS32uk6UQw1FH4lpxPuLc5F//
      yXG4/5j3+apMm3jhFcIQ3vuqZV3kz88HeeuBPbRwajkrhPxS/BcCAwEAAaNQME4w
      HQYDVR0OBBYEFNPLn9RQJ0u6prsffVi3a0QGxSgjMB8GA1UdIwQYMBaAFNPLn9RQ
      J0u6prsffVi3a0QGxSgjMAwGA1UdEwQFMAMBAf8wDQYJKoZIhvcNAQENBQADggIB
      AGd5PjBAeWqpAM7kaGrKHY/d+kS1tKPH/c9HJcIsrZGNImKyuJ0KXLhmwIBMrARQ
      9Ly2km8FZEo1LKPd6EYzKzru/xUdY/vz2UO/4aouOyNn6rI9umXaahPKElSN6gka
      NIPY7DpGcaCmtMzE13e7wbh9IkqwWPrzRNwaZKybWyWp6/AJCSc6PoqqW0+3plBA
      XuCDlM6XJF8duqWcdJKBcdCwdYdrHtb0xcwEG4XF+G04R6uEA0AfCIylvwjOAKN/
      5AeiYJ+hz837XE3i1CZmsNR5uo1erijVuyMN8DD/9pr2QwYP/4b7nCSDMckTrHez
      um7gMtYIoy4OnLvSddjUboRpor/iaE1H/3LK1gvnMbII45EhUdPKIN2/nlfY0g5T
      jx9OW2UXl33WlZT7oA1II87CV2H6k72TnH6fDjGFepWPsnJQ+Fk7+zHSbJEIFJzr
      49rK+dahSjt3C9GB7aJu/NOhGA1W8iaWEyYPO/FOfmvJZwMlZgbeN0utWyJ1zsi5
      DWaofN3JwjaAD4nJfIbTF1iINJ3NhjIRETTQ31G/AWhV8H8ZCK+4iE+rQ3OuWzYU
      vd5u4z/jaVcUnJKukM0e9VAgxEC7A8rRFgko5XjKXrCZgkzbhQWA0uzYvx0ghIMe
      x8AH/WxuNFhZq3OmgppgVaGeuOvN7xSEbLACAOekJWp1
      -----END CERTIFICATE-----
    ''
  ];
}
