# Steam gaming configuration
_: {
  flake.nixosModules.desktop-steam =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      options.my.desktop.steam.enable = lib.mkEnableOption "Steam gaming";
      options.my.desktop.steamHidpi = lib.mkEnableOption "scale steam for HiDPI";

      config = lib.mkMerge [
        (lib.mkIf (cfg.enable && cfg.steam.enable) {
          programs.steam = {
            enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
            localNetworkGameTransfers.openFirewall = true;
          };

          hardware.graphics.extraPackages = [ pkgs.libva-vdpau-driver ];
          hardware.steam-hardware.enable = true;
          hardware.xpadneo.enable = true;

          environment.sessionVariables = lib.mkIf cfg.steamHidpi {
            STEAM_FORCE_DESKTOPUI_SCALING = "2";
          };
        })
        (lib.mkIf (cfg.enable && cfg.steam.enable && config.my.system.impermanence.enable) {
          # Persist gaming data at system level (for user efficacy38)
          # Note: Using system-level persistence since this is a NixOS-only module
          # TODO: Consider creating home-manager companion module for better username templating
          environment.persistence."/persistent/system" = {
            users."efficacy38" = {
              directories = [
                ".local/share/Steam" # Steam gaming platform
                ".local/share/PrismLauncher" # PrismLauncher (Minecraft)
              ];
            };
          };
        })
      ];
    };
}
