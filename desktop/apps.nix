{ config, pkgs, ... }: {
  fonts.fontconfig.enable = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron"
  ];
  home.packages = with pkgs; [
    fcitx5-rime
    (nerdfonts.override { fonts = [ "Hack" ]; })
    libreoffice
    keepassxc
    git-credential-keepassxc
    thunderbird
    rclone
    kopia
    nextcloud-client
    ferdium
    discord
    protonmail-bridge
    protonmail-bridge-gui
    mattermost-desktop
    telegram-desktop
    protonmail-desktop
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    youtube-music
    # ### wallpaper-engine-plugin
    # wallpaper-engine-kde-plugin
    # qt5.qtwebsockets
    # (python3.withPackages (python-pkgs: [ python-pkgs.websockets ]))
    # ###
  ];

  programs.ssh = {
    addKeysToAgent = "yes";
  };

  services.nextcloud-client.enable = true;
  services.nextcloud-client.startInBackground = true;
}
