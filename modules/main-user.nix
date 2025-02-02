{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.main-user;
  secretpath = builtins.toString inputs.nix-secrets;
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
    sops.secrets."main_user_passwd_hash".neededForUsers = true;
    sops.secrets."main_user_passwd_hash".sopsFile = "${secretpath}/secrets/common.yaml";
    users.users.${cfg.userName} = {
      isNormalUser = true;
      description = "${cfg.userName}(admin)";
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = config.sops.secrets."main_user_passwd_hash".path;
    };

    home-manager = {
      extraSpecialArgs = { inherit inputs; };
      users."efficacy38" = {
        config = {
          home.stateVersion = "24.11";
        };

        imports = [
          inputs.self.outputs.homeModules.default
        ];
      };
    };

    security.sudo = {
      enable = true;
      extraRules = [
        {
          commands =
            map
              (systemd_cmd: {
                command = "${pkgs.systemd.out}/bin/${systemd_cmd}";
                options = [ "NOPASSWD" ];
              })
              [
                "systemctl"
                "reboot"
                "poweroff"
                "resolvectl"
              ]
            ++ [
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
        Defaults:${cfg.userName} secure_path="${
          lib.makeBinPath [
            systemd
          ]
        }:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
      '';
    };
  };
}
