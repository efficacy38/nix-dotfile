{ lib, config, pkgs, ... }: {
  # enable nix flake
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "@wheel" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  environment.variables.EDITOR = "vim";

  # enable sshd
  services.openssh.enable = true;
  services.fail2ban.enable = true;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "none";
    openFirewall = true;
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
    nix-index

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
  ];
}
