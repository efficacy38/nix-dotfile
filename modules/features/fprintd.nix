{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.myNixOS.fprintd;
in
{
  options.myNixOS.fprintd = {
    enable = lib.mkEnableOption "enable cscc change vpn script module";
  };

  config = lib.mkIf cfg.enable {
    # enable fprintd
    services.dbus.packages = with pkgs; [ fprintd ];
    environment.systemPackages = with pkgs; [ fprintd ];
    systemd.packages = with pkgs; [ fprintd ];
    systemd.services.fprintd.enable = true;
    # security.pam.services.sudo.fprintAuth = true;
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
}
