{
  pkgs,
  config,
  lib,
  ...
}:
let

  cfg = config.myNixOS.common-server;
in
{
  options = {
    myNixOS.common-server = {
      enable = lib.mkEnableOption "enable common-server configuration for all nixos";
    };
  };

  config = lib.mkIf cfg.enable {
    services.rsyncd.enable = true;
    programs.mosh = {
      enable = true;
      openFirewall = true;
    };

    environment.systemPackages = with pkgs; [
      rsync
    ];
  };
}
