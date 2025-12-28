_:
{
  flake.nixosModules.common-server =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      cfg = config.my.common-server;
    in
    {
      options.my.common-server = {
        enable = lib.mkEnableOption "enable common-server configuration for all nixos";
      };

      config = lib.mkIf cfg.enable {
        services.rsyncd.enable = true;
        programs.mosh = {
          enable = true;
          openFirewall = true;
        };

        environment.systemPackages = with pkgs; [
          rsync
        ];
      };
    };
}
