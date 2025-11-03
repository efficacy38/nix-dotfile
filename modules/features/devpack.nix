{
  config,
  lib,
  ...
}:
let

  cfg = config.myNixOS.devpack;
in
{
  options = {
    myNixOS.devpack = {
      enable = lib.mkEnableOption "enable devpack configuration for all nixos";
      csccUtilEnable = lib.mkEnableOption "enable cscc-util";
      tailscaleEnable = lib.mkEnableOption "enable tailscale";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        # enable podman
        virtualisation.podman.enable = lib.mkDefault true;
        virtualisation.docker.enable = lib.mkDefault true;
      }
      (lib.mkIf cfg.csccUtilEnable {
        myNixOS.cscc-work.enable = lib.mkDefault true;
      })
      (lib.mkIf cfg.tailscaleEnable {
        myNixOS.tailscale.enable = lib.mkDefault true;
        myNixOS.tailscale.asRouter = lib.mkDefault false;
      })
    ]
  );
}
