_: {
  flake.nixosModules.system-netbird =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.system.netbird;
      clients = lib.attrValues config.services.netbird.clients;
      restartClients = lib.concatMapStringsSep "\n" (client: ''
        if [ "$DEVICE_IFACE" != "${client.interface}" ]; then
          ${pkgs.systemd}/bin/systemctl --no-block restart ${client.service.name}.service
        fi
      '') clients;
    in
    {
      options.my.system.netbird.enable = lib.mkEnableOption "NetBird client";

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            services.netbird.clients.default = {
              port = 51820;
              name = "netbird";
              interface = "wt0";
              hardened = false;
            };
          }

          (lib.mkIf config.networking.networkmanager.enable {
            networking.networkmanager.dispatcherScripts = [
              {
                type = "basic";
                source = pkgs.writeShellScript "restart-netbird" ''
                  [ "$2" = "up" ] || exit 0
                  ${restartClients}
                '';
              }
            ];
          })
        ]
      );
    };
}
