{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;
  # programs.keepassxc = {
  #   enable = true;
  # };

  home.packages = with pkgs; [
    # input methods and fonts
    fcitx5-rime
    nerd-fonts.hack
    nerd-fonts.fira-mono
    nerd-fonts.fira-code
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif

    # desktop apps
    thunderbird
    # protonmail-bridge
    # protonmail-bridge-gui
    # protonmail-desktop
    # youtube-music
    obs-studio
    chromium

    # utils
    # ### wallpaper-engine-plugin
    # wallpaper-engine-kde-plugin
    # qt5.qtwebsockets
    # (python3.withPackages (python-pkgs: [ python-pkgs.websockets ]))
    # ###
    remmina
    haruna

    # minecraft
    prismlauncher
    moonlight-qt
    vscode

    zotero
    zotero-translation-server
    keepassxc
  ];
}
