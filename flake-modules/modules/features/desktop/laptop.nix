# Laptop-specific desktop features (fprintd, battery-health)
_: {
  # NixOS: Fingerprint authentication
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
        services.dbus.packages = with pkgs; [ fprintd ];
        environment.systemPackages = with pkgs; [ fprintd ];
        systemd.packages = with pkgs; [ fprintd ];
        systemd.services.fprintd.enable = true;

        # Keep pam_fprintd as the sufficient sudo auth step. A preceding
        # conditional wrapper must not consume the successful fingerprint.
        # ref: https://wiki.archlinux.org/title/Talk:Fprint
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

  # NixOS: Battery health management (TLP)
  flake.nixosModules.desktop-battery-health =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      options.my.desktop.batteryHealth.enable = lib.mkEnableOption "battery health management (TLP)";

      config = lib.mkIf (cfg.enable && cfg.batteryHealth.enable) {
        services.tlp = {
          enable = true;
          settings = {
            CPU_SCALING_GOVERNOR_ON_AC = "performance";
            CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

            CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
            CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

            CPU_MIN_PERF_ON_AC = 0;
            CPU_MAX_PERF_ON_AC = 100;
            CPU_MIN_PERF_ON_BAT = 0;
            CPU_MAX_PERF_ON_BAT = 60;

            # Optional helps save long term battery health
            START_CHARGE_THRESH_BAT0 = 40;
            STOP_CHARGE_THRESH_BAT0 = 80;
          };
        };
      };
    };
}
