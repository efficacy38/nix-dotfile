{
  config,
  pkgs,
  ...
}:
{
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
    ghostwriter
  ];
  # programs.kdeconnect.enable = true;
}
