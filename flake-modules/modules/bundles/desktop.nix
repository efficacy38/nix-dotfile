_:
let
  sessionChoices = [
    "hyprland"
    "kde"
    "none"
  ];
in
{
  # NixOS: desktop bundle. Enables the system desktop; the matching Home
  # Manager bundle is selected per user via `my.users.<name>.type` in
  # `features/system/main-user.nix`.
  flake.nixosModules.bundles-desktop =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.bundles.desktop;
    in
    {
      options.my.bundles.desktop = {
        enable = lib.mkEnableOption "desktop bundle (system + desktop users' home)";
        session = lib.mkOption {
          type = lib.types.enum sessionChoices;
          default = "hyprland";
          description = "Desktop session to enable.";
        };
        zram.enable = lib.mkEnableOption "zram swap for the desktop";
        zen.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable the Zen browser (home).";
        };
        ssh-tunnels.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable persistent SSH tunnels (home).";
        };
        nvim.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable the Neovim configuration (home).";
        };
        steam.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Steam gaming.";
        };
      };

      config = lib.mkIf cfg.enable {
        my = {
          desktop = {
            enable = true;
            hyprland.enable = lib.mkDefault (cfg.session == "hyprland");
            kde.enable = lib.mkDefault (cfg.session == "kde");
            steam = {
              enable = lib.mkDefault cfg.steam.enable;
              hidpi = lib.mkDefault false;
            };
          };
          system = {
            zram.enable = lib.mkDefault cfg.zram.enable;
            firmware.enable = lib.mkDefault true;
          };
        };
      };
    };

  # Home Manager: desktop bundle
  flake.homeModules.bundles-desktop =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.bundles.desktop;
    in
    {
      options.my.bundles.desktop = {
        enable = lib.mkEnableOption "desktop bundle (home)";
        session = lib.mkOption {
          type = lib.types.enum sessionChoices;
          default = "hyprland";
          description = "Desktop session to enable.";
        };
        zen.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable the Zen browser.";
        };
        ssh-tunnels.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable persistent SSH tunnels.";
        };
        nvim.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable the Neovim configuration.";
        };
      };

      config = lib.mkIf cfg.enable {
        my = {
          bundles.general.enable = true;
          system.incus.enable = true;
          dotfiles.inStore = lib.mkDefault true;
          desktop = {
            enable = true;
            hyprland.enable = lib.mkDefault (cfg.session == "hyprland");
            kde.enable = lib.mkDefault (cfg.session == "kde");
            zen.enable = lib.mkDefault cfg.zen.enable;
            ssh-tunnels.enable = lib.mkDefault cfg.ssh-tunnels.enable;
          };
          devpack = {
            gpg.enable = true;
            gui.enable = true;
            ai.enable = true;
            nvim.enable = lib.mkDefault cfg.nvim.enable;
            nvim.pack.enable = lib.mkDefault cfg.nvim.enable;
          };
        };
      };
    };
}
