{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.my-steam;
in
{
  options.my-steam = {
    enable = lib.mkEnableOption "enable steam";
    hidpi = lib.mkEnableOption "enable to scale steam due to hidpi";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };

    hardware.opengl.extraPackages = [ pkgs.vaapiVdpau ];
    hardware.steam-hardware.enable = true;

    environment.sessionVariables =
      if cfg.hidpi then
        {
          STEAM_FORCE_DESKTOPUI_SCALING = "2";
        }
      else
        { };
  };
}
