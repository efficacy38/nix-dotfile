{ ... }:
{
  flake.nixosModules.fprintd =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.my.fprintd;
    in
    {
      options.my.fprintd = {
        enable = lib.mkEnableOption "enable fingerprint authentication module";
      };

      config = lib.mkIf cfg.enable {
        # enable fprintd
        services.dbus.packages = with pkgs; [ fprintd ];
        environment.systemPackages = with pkgs; [ fprintd ];
        systemd.packages = with pkgs; [ fprintd ];
        systemd.services.fprintd.enable = true;
        # only allow tty to consume fingerprint auth
        security.pam.services.sudo.rules.auth.fprintd-tty-only = {
          enable = true;
          order = config.security.pam.services.sudo.rules.auth.fprintd-personalize.order - 10;
          control = "[success=1 default=ignore]";
          modulePath = "${pkgs.linux-pam}/lib/security/pam_fprintd.so";
          args = [ "service in sudo:su:su-l tty in :tty" ];
        };

        security.pam.services.sudo.rules.auth.fprintd-personalize = {
          enable = true;
          order = config.security.pam.services.sudo.rules.auth.unix.order - 10;
          control = "sufficient";
          modulePath = "${pkgs.fprintd}/lib/security/pam_fprintd.so";
          args = [
            "timeout=2"
          ];
        };
      };
    };
}
