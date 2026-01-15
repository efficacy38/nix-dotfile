# System observability and performance monitoring tools
_: {
  flake.nixosModules.system-observability =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.my.system;
    in
    {
      options.my.system.observability = {
        enable = lib.mkEnableOption "enable observability and performance monitoring tools";
      };

      config = lib.mkIf cfg.observability.enable {
        environment.systemPackages = with pkgs; [
          # Network monitoring
          tcpdump
          iftop
          nethogs

          # System performance
          htop
          btop
          iotop

          # CPU/Memory stress testing
          stress
          stress-ng

          # System statistics
          sysstat # sar, iostat, mpstat

          # Tracing and debugging
          strace
          ltrace

          # Process management
          lsof
          psmisc # killall, pstree, etc.
        ];
      };
    };
}
