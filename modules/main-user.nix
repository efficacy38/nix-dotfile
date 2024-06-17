{ lib, config, pkgs, ... }:
let
  cfg = config.main-user;
in
{
  options.main-user = {
    enable = lib.mkEnableOption "enable user module";

    desktopEnable = lib.mkEnableOption "enable desktop support(current only kde)";
    devProgEnable = lib.mkEnableOption "enable development programming language tool support";

    userName = lib.mkOption {
      default = "efficacy38";
      description = ''
        username, whose has sudo privilege of every command
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.userName} = {
      isNormalUser = true;
      description = "${cfg.userName}(admin)";
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
    };

    home-manager.users.${cfg.userName} = with cfg;
      import ./home-manager {
        inherit config pkgs desktopEnable devProgEnable userName;
      };

    security.sudo = {
      enable = true;
      extraRules = [
        {
          commands = map
            (
              systemd_cmd: {
                command = "${pkgs.systemd.out}/bin/${systemd_cmd}";
                options = [ "NOPASSWD" ];
              }
            ) [
            "systemctl"
            "reboot"
            "poweroff"
            "resolvectl"
          ] ++ [
            {
              command = "${pkgs.iproute2.out}/bin/ip";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/ip";
              options = [ "NOPASSWD" ];
            }
          ];
          users = [ "${cfg.userName}" ];
        }
      ];
      extraConfig = with pkgs; ''
        Defaults:${cfg.userName} secure_path="${lib.makeBinPath [
          systemd
        ]}:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
      '';
    };
  };
}
