{
  config,
  pkgs,
  ...
}:
{
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
}
