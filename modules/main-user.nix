{
  lib,
  config,
  pkgs,
  inputs,
  myLib,
  ...
}:
let
  cfg = config.main-user;
  secretpath = builtins.toString inputs.nix-secrets;
in
{
  options.main-user = {
    enable = lib.mkEnableOption "enable user module";

    userName = lib.mkOption {
      default = "efficacy38";
      description = ''
        username, whose has sudo privilege of every command
      '';
    };

    userConfig = lib.mkOption {
      default = ../hosts/homelab-1/home.nix;
      description = ''
        main user's home configuration, include both myHomeManager and
        home-manager module, default user homelab-1's userConfig, it should be
        farily small and no desktop support.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets."main_user_passwd_hash".neededForUsers = true;
    sops.secrets."main_user_passwd_hash".sopsFile = "${secretpath}/secrets/common.yaml";
    users.mutableUsers = false;
    users.users.${cfg.userName} = {
      isNormalUser = true;
      description = "${cfg.userName}(admin)";
      shell = pkgs.zsh;
      extraGroups = [ "wheel" ];
      hashedPasswordFile = config.sops.secrets."main_user_passwd_hash".path;
      linger = true;
    };

    home-manager = {
      extraSpecialArgs = { inherit inputs myLib pkgs; };
      users."${cfg.userName}" = {
        imports = [
          (import cfg.userConfig)
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
                command = "${pkgs.systemd}/bin/${systemd_cmd}";
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
                command = "${pkgs.iproute2}/bin/ip";
                options = [ "NOPASSWD" ];
              }
              {
                command = "${pkgs.networkmanager}/bin/nmtui";
              }
            ];
          users = [ "${cfg.userName}" ];
        }
      ];
      extraConfig = with pkgs; ''
        Defaults:${cfg.userName} secure_path="${
          lib.makeBinPath [
            systemd
            iproute2
            networkmanager
          ]
        }:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
      '';
    };
  };
}
