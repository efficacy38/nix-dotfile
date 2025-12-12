{ ... }:
{
  flake.nixosModules.steam =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.my.steam;
    in
    {
      options.my.steam = {
        enable = lib.mkEnableOption "enable steam";
        hidpi = lib.mkEnableOption "enable to scale steam due to hidpi";
      };

      config = lib.mkIf cfg.enable {
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
        };

        hardware.graphics.extraPackages = [ pkgs.libva-vdpau-driver ];
        hardware.steam-hardware.enable = true;

        environment.sessionVariables =
          if cfg.hidpi then
            {
              STEAM_FORCE_DESKTOPUI_SCALING = "2";
            }
          else
            { };
      };
    };
}
