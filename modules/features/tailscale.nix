{
  lib,
  config,
  ...
}:
let
  cfg = config.myNixOS.tailscale;
in
{
  options.myNixOS.tailscale = {
    enable = lib.mkEnableOption "enable personal tailscale config module";
    asRouter = lib.mkEnableOption "set vpn intf rpfilter(1) and forwarding sysctl otherwise disable forwarding sysctl";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;

      # When set to `client` or `both`, reverse path filtering will be set to loose instead of strict.
      # When set to `server` or `both`, IP forwarding will be enabled.
      useRoutingFeatures = if cfg.asRouter then "both" else "client";
      openFirewall = true;
    };
  };
}
