{ ... }:
{
  flake.nixosModules.systemd-initrd =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.systemd-initrd;
    in
    {
      options.my.systemd-initrd = {
        enable = lib.mkEnableOption "enable systemd-initrd module";
        debugEnable = lib.mkEnableOption "enable debug for systemd-initrd";
      };

      config = lib.mkIf cfg.enable {
        boot.initrd.systemd = {
          enable = true;
          emergencyAccess = cfg.debugEnable;
        };
      };
    };
}
