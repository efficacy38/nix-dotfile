{ lib, config, pkgs, ... }: {
  # enable nix flake
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
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
  # TODO: use variable to modify following code
  sops.age.keyFile = "/home/efficacy38/.config/sops/age/keys.txt";
  sops.defaultSopsFormat = "yaml";

  networking.firewall.enable = true;

  programs.zsh.enable = true;
  # add completion for zsh, links completion to $HOME/.nix-profile/share/zsh
  environment.pathsToLink = [ "/share/zsh" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
}
