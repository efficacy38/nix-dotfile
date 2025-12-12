# Steam gaming configuration
{ ... }:
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
      options.my.desktop.steamEnable = lib.mkEnableOption "Steam gaming";
      options.my.desktop.steamHidpi = lib.mkEnableOption "scale steam for HiDPI";

      config = lib.mkIf (cfg.enable && cfg.steamEnable) {
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
