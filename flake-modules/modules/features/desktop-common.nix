{ ... }:
{
  flake.homeModules.desktop-common =
    {
      pkgs-unstable,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop-common;
    in
    {
      options.my.desktop-common = {
        enable = lib.mkEnableOption "common desktop packages";
      };

      config = lib.mkIf cfg.enable {
        fonts.fontconfig.enable = true;

        home.packages = with pkgs-unstable; [
          # input methods and fonts
          nerd-fonts.hack
          nerd-fonts.fira-mono
          nerd-fonts.fira-code
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif

          # desktop apps
          thunderbird
          obs-studio
          chromium

          # utils
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
      };
    };
}
