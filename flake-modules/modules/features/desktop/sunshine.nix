# Sunshine game streaming server
_: {
  flake.nixosModules.desktop-sunshine =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      options.my.desktop.sunshine.enable = lib.mkEnableOption "Sunshine game streaming server";

      config = lib.mkIf (cfg.enable && cfg.sunshine.enable) {
        services.sunshine = {
          enable = true;
          openFirewall = true;
          capSysAdmin = true;
          autoStart = true;
        };
      };
    };
}
