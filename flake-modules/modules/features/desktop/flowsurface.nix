_: {
  flake.homeModules.desktop-flowsurface =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      options.my.desktop.flowsurface.enable = lib.mkEnableOption "flowsurface market data visualization";

      config = lib.mkIf (cfg.enable && cfg.flowsurface.enable) {
        home.packages = [ pkgs.flowsurface ];
      };
    };
}
