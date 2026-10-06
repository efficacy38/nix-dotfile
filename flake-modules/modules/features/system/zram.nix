# zram swap and related VM tuning
_: {
  flake.nixosModules.system-zram =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.system;
    in
    {
      options.my.system.zram.enable = lib.mkEnableOption "zram swap";

      config = lib.mkIf cfg.zram.enable {
        zramSwap = {
          enable = true;
          memoryPercent = 50;
        };
        boot.kernel.sysctl = {
          "vm.swappiness" = 180;
          "vm.watermark_boost_factor" = 0;
          "vm.watermark_scale_factor" = 125;
          "vm.page-cluster" = 0;
        };
      };
    };
}
