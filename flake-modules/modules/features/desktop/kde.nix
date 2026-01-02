# KDE Plasma desktop environment configuration
_: {
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
      config = lib.mkIf (cfg.enable && cfg.kde.enable) {
        services.desktopManager.plasma6.enable = true;
        security.pam.services.sddm.enableKwallet = true;

        # Persist KDE application data
        environment.persistence."/persistent/system".users."efficacy38" = {
          directories = [
            ".local/share/dolphin" # Dolphin file manager
            ".local/share/kate" # Kate text editor
            ".local/share/sddm" # SDDM display manager state
          ];
        };
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
      config = lib.mkIf (cfg.enable && cfg.kde.enable) {
        home.packages = with pkgs.kdePackages; [
          elisa
          ghostwriter
          kate
          kcalc
          kdeconnect-kde
          markdownpart
          yakuake
        ];
      };
    };
}
