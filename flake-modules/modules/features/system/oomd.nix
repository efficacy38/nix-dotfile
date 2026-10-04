# systemd-oomd: userspace OOM killer, limited to user slices.
_: {
  flake.nixosModules.system-oomd =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.system.oomd;
    in
    {
      options.my.system.oomd = {
        enable = lib.mkEnableOption "systemd-oomd (user slices only)";
        desktop = lib.mkEnableOption "aggressive systemd-oomd tuning for interactive/desktop workloads";
      };

      config = lib.mkIf cfg.enable {
        # Default the aggressive suite to desktop hosts; overridable per host.
        my.system.oomd.desktop = lib.mkDefault (config.my.bundles.desktop.enable or false);

        systemd.oomd = {
          enable = true;
          # Upstream defaults; stated explicitly, no mkForce needed.
          enableRootSlice = false;
          enableSystemSlice = false;
          enableUserSlices = true;
        };

        # Plain priority beats nixpkgs' lib.mkDefault "80%"; gated on desktop.
        systemd.slices."user".sliceConfig = lib.mkIf cfg.desktop {
          ManagedOOMMemoryPressureLimit = "10%";
          ManagedOOMMemoryPressureDurationSec = "1s";
          SwapUsedLimit = "30%";
        };
      };
    };
}
