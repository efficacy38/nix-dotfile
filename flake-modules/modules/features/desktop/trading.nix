# Trading applications (home). Opt-in via my.desktop.trading.enable.
_:
{
  flake.homeModules.desktop-trading =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      options.my.desktop.trading.enable = lib.mkEnableOption "trading applications (home)";

      config = lib.mkIf (cfg.enable && cfg.trading.enable) {
        home.packages = lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
          pkgs.flowsurface
          pkgs.tradingview
        ];
      };
    };
}
