# Firmware updates (fwupd)
_: {
  flake.nixosModules.system-firmware =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.system;
    in
    {
      options.my.system.firmware.enable = lib.mkEnableOption "firmware updates (fwupd)";

      config = lib.mkIf cfg.firmware.enable {
        services.fwupd.enable = true;
      };
    };
}
