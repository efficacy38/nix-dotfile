# Fingerprint authentication (fprintd + PAM)
_: {
  flake.nixosModules.desktop-fprintd =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      options.my.desktop.fprintd.enable = lib.mkEnableOption "fingerprint authentication";

      config = lib.mkIf (cfg.enable && cfg.fprintd.enable) {
        services.fprintd.enable = true;

        # Skip fingerprint authentication when sudo has no controlling TTY.
        # On success, pam_succeed_if skips the immediately following rule.
        security.pam.services.sudo.rules.auth.fprintd-skip-without-tty = {
          enable = true;
          order = config.security.pam.services.sudo.rules.auth.fprintd-personalize.order - 1;
          control = "[success=1 default=ignore]";
          modulePath = "${config.security.pam.package}/lib/security/pam_succeed_if.so";
          args = [
            "service"
            "in"
            "sudo:su:su-l"
            "tty"
            "in"
            ":unknown"
          ];
        };

        # Keep pam_fprintd as the sufficient sudo auth step.
        security.pam.services.sudo.rules.auth.fprintd-personalize = {
          enable = true;
          order = config.security.pam.services.sudo.rules.auth.unix.order - 10;
          control = "sufficient";
          modulePath = "${pkgs.fprintd}/lib/security/pam_fprintd.so";
          args = [ "timeout=5" ];
        };

        # Allow fingerprint authentication on SDDM login screen
        # The SDDM NixOS module hardcodes pam.services.sddm.text, so .rules
        # additions are ignored. We must override .text directly.
        # ref: https://wiki.archlinuxcn.org/zh-tw/SDDM
        security.pam.services.sddm.text = lib.mkForce ''
          auth      sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so
          auth      substack   login
          account   include    login
          password  substack   login
          session   include    login
        '';
      };
    };
}
