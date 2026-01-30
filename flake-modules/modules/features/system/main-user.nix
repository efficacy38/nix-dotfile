_: {
  flake.nixosModules.users =
    {
      lib,
      config,
      pkgs,
      inputs,
      ...
    }:
    let
      cfg = config.my.users;
      secretpath = builtins.toString inputs.nix-secrets;

      # User type definitions
      userTypes = {
        minimal = {
          groups = [ ];
          homeDefaults = {
            my.bundles.minimal.enable = true;
          };
        };

        developing = {
          groups = [
            "docker"
            "wireshark"
          ];
          homeDefaults = {
            my.bundles.general.enable = true;
          };
        };

        desktop-user = {
          groups = [
            "wheel"
            "docker"
            "wireshark"
            "video"
            "audio"
          ];
          homeDefaults = {
            my.bundles.desktop.enable = true;
            my.bundles.general.enable = true;
          };
        };
      };

      # Get all users with admin privileges (desktop-user OR isAdmin)
      adminUsers = lib.filterAttrs (_: userCfg: userCfg.type == "desktop-user" || userCfg.isAdmin) cfg;
      adminUserNames = lib.attrNames adminUsers;

      # User submodule type
      userSubmodule = lib.types.submodule {
        options = {
          type = lib.mkOption {
            type = lib.types.enum [
              "minimal"
              "developing"
              "desktop-user"
            ];
            description = "User type preset (minimal, developing, desktop-user)";
          };

          isAdmin = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Grant wheel group and NOPASSWD sudo rules (automatically true for desktop-user)";
          };

          extraHomeConfig = lib.mkOption {
            type = lib.types.attrs;
            default = { };
            description = "Additional home-manager config to merge with type defaults";
          };
        };
      };

      # Compute groups for a user (type groups + wheel if isAdmin)
      getUserGroups =
        userCfg:
        userTypes.${userCfg.type}.groups
        ++ lib.optionals (userCfg.isAdmin && userCfg.type != "desktop-user") [ "wheel" ];
    in
    {
      options.my.users = lib.mkOption {
        type = lib.types.attrsOf userSubmodule;
        default = { };
        description = "Attribute set of users to create";
      };

      config = lib.mkIf (cfg != { }) {
        # Sops secret for shared password
        sops.secrets."main_user_passwd_hash" = {
          neededForUsers = true;
          sopsFile = "${secretpath}/secrets/common.yaml";
        };

        users.mutableUsers = false;

        # Generate system users
        users.users =
          lib.mapAttrs (name: userCfg: {
            isNormalUser = true;
            description = name;
            shell = pkgs.zsh;
            extraGroups = getUserGroups userCfg;
            hashedPasswordFile = config.sops.secrets."main_user_passwd_hash".path;
            linger = true;
          }) cfg
          // {
            root.hashedPasswordFile = config.sops.secrets."main_user_passwd_hash".path;
          };

        # Generate home-manager configs
        home-manager = {
          extraSpecialArgs = {
            inherit (inputs.self.outputs)
              pkgs-stable
              pkgs-unstable
              ;
            inherit inputs pkgs;
          };

          users = lib.mapAttrs (
            name: userCfg:
            {
              imports = [
                inputs.self.outputs.homeModules.default
              ];
              home.stateVersion = "24.11";
              home.username = name;
              home.homeDirectory = "/home/${name}";
            }
            // userTypes.${userCfg.type}.homeDefaults
            // userCfg.extraHomeConfig
          ) cfg;
        };

        # Sudo rules for admin users (desktop-user OR isAdmin)
        security.sudo = lib.mkIf (adminUserNames != [ ]) {
          enable = true;
          extraRules = [
            {
              users = adminUserNames;
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
                  {
                    command = "/run/current-system/sw/bin/tlp";
                  }
                ];
            }
          ];
          extraConfig = ''
            Defaults:${lib.concatStringsSep "," adminUserNames} secure_path="${
              lib.makeBinPath [
                pkgs.systemd
                pkgs.iproute2
                pkgs.networkmanager
              ]
            }:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
          '';
        };
      };
    };
}
