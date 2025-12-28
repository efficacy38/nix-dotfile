# Steam gaming configuration
_:
{
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

      config = lib.mkIf (cfg.enable && cfg.steam.enable) {
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
        };

        hardware.graphics.extraPackages = [ pkgs.libva-vdpau-driver ];
        hardware.steam-hardware.enable = true;

        environment.sessionVariables = lib.mkIf cfg.steamHidpi {
          STEAM_FORCE_DESKTOPUI_SCALING = "2";
        };
      };
    };
}
