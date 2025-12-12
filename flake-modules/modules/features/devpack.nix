{ ... }:
{
  flake.nixosModules.devpack =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.my.devpack;
    in
    {
      options.my.devpack = {
        enable = lib.mkEnableOption "enable devpack configuration for all nixos";
        csccUtilEnable = lib.mkEnableOption "enable cscc-util";
        tailscaleEnable = lib.mkEnableOption "enable tailscale";
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            # enable podman
            virtualisation.podman.enable = lib.mkDefault true;
            virtualisation.docker.enable = lib.mkDefault true;
          }
          (lib.mkIf cfg.csccUtilEnable {
            my.cscc-work.enable = lib.mkDefault true;
          })
          (lib.mkIf cfg.tailscaleEnable {
            my.tailscale.enable = lib.mkDefault true;
            my.tailscale.asRouter = lib.mkDefault false;
          })
        ]
      );
    };
}
