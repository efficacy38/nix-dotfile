{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.myHomeManager.desktop-kde;
in
{
  options.myHomeManager.desktop-kde = {
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
    # programs.kdeconnect.enable = true;
  };
}
