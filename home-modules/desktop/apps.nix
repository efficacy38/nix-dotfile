{
  config,
  pkgs,
  ...
}:
{
  fonts.fontconfig.enable = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron"
  ];
  home.packages = with pkgs; [
    fcitx5-rime
    nerd-fonts.hack
    nerd-fonts.fira-mono
    nerd-fonts.fira-code
    keepassxc
    git-credential-keepassxc
    thunderbird
    rclone
    kopia
    nextcloud-client
    protonmail-bridge
    protonmail-bridge-gui
    protonmail-desktop
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    youtube-music
    obs-studio
    chromium
    rambox
    # ### wallpaper-engine-plugin
    # wallpaper-engine-kde-plugin
    # qt5.qtwebsockets
    # (python3.withPackages (python-pkgs: [ python-pkgs.websockets ]))
    # ###
    yubikey-manager
    syncthing
    remmina
    haruna
    firefox

    prismlauncher
  ];

  services.nextcloud-client.enable = true;
  services.nextcloud-client.startInBackground = true;
  services.syncthing.enable = true;
}
