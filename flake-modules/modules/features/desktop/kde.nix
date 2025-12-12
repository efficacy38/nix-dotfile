# KDE Plasma desktop environment configuration
{ ... }:
{
  # NixOS: KDE system config
  flake.nixosModules.desktop-kde =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      config = lib.mkIf (cfg.enable && cfg.kdeEnable) {
        services.desktopManager.plasma6.enable = true;
        security.pam.services.sddm.enableKwallet = true;
      };
    };

  # Home-manager: KDE user packages
  flake.homeModules.desktop-kde =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      config = lib.mkIf (cfg.enable && cfg.kdeEnable) {
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
