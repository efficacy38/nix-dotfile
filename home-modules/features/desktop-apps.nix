{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    # input methods and fonts
    fcitx5-rime
    nerd-fonts.hack
    nerd-fonts.fira-mono
    nerd-fonts.fira-code
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif

    # desktop apps
    keepassxc
    thunderbird
    nextcloud-client
    protonmail-bridge
    protonmail-bridge-gui
    protonmail-desktop
    youtube-music
    obs-studio
    chromium

    # utils
    rambox
    # ### wallpaper-engine-plugin
    # wallpaper-engine-kde-plugin
    # qt5.qtwebsockets
    # (python3.withPackages (python-pkgs: [ python-pkgs.websockets ]))
    # ###
    syncthing
    remmina
    haruna

    # minecraft
    prismlauncher
  ];

  services.nextcloud-client.enable = true;
  services.nextcloud-client.startInBackground = true;
  services.syncthing.enable = true;
}
