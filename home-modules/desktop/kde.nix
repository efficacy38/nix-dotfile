{ config, pkgs, ... }: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs.kdePackages; [
    okular
    kdeconnect-kde
    elisa
    knotes
    markdownpart
    # kcommit
    # kexi
    kate
    yakuake
    kcalc
    kate
    yakuake
  ];
  # programs.kdeconnect.enable = true;
}
