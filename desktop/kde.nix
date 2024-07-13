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
  ];
  # programs.kdeconnect.enable = true;
}
