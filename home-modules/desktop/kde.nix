{ config, pkgs, ... }: {
  fonts.fontconfig.enable = true;

  home.packages = with pkgs.kdePackages; [
    okular
    kdeconnect-kde
    elisa
    markdownpart
    kate
    # markdown preview plugin of kate
    markdownpart
    yakuake
    kcalc
    kate
    yakuake
  ];
  # programs.kdeconnect.enable = true;
}
