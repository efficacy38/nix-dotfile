{ ... }:
{
  flake.homeModules.desktop-kde =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.my.desktop-kde;
    in
    {
      options.my.desktop-kde = {
        enable = lib.mkEnableOption "KDE desktop packages";
      };

      config = lib.mkIf cfg.enable {
        home.packages = with pkgs.kdePackages; [
          okular
          kdeconnect-kde
          elisa
          markdownpart
          kate
          yakuake
          kcalc
          ghostwriter
        ];
      };
    };
}
