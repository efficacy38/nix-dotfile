{ ... }:
let
  # Base path to dotfiles - used for both symlinks and Nix store imports
  # From flake-modules/modules/features/ -> dotfiles/
  dotfilesBasePath = ../../../dotfiles;
in
{
  flake.homeModules.desktop-hyprland =
    {
      pkgs,
      options,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop-hyprland;
      # Absolute path for runtime symlinks
      dotfilesDir = "/etc/nixos/nix-dotfile/dotfiles";

      # Helper to create symlink config entries
      # Takes a relative path string (e.g., "hypr/hypridle.conf") and creates the xdg.configFile entry
      mkLinkConfig = relativePath: {
        "${relativePath}".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/${relativePath}";
      };

      # Icon paths for audio control script (these get copied to Nix store)
      MUTE_ICON_PATH = dotfilesBasePath + /dunst/volume-off.png;
      LOW_ICON_PATH = dotfilesBasePath + /dunst/volume-low.png;
      MEDIUM_ICON_PATH = dotfilesBasePath + /dunst/volume-medium.png;
      HIGH_ICON_PATH = dotfilesBasePath + /dunst/volume-high.png;
    in
    {
      options.my.desktop-hyprland = {
        enable = lib.mkEnableOption "Hyprland desktop configuration";
      };

      config = lib.mkIf cfg.enable (
        {
          # FIXME: This is work-around of hm
          # https://github.com/nix-community/home-manager/issues/2064
          systemd.user.targets.tray = {
            Unit = {
              Description = "Home Manager System Tray";
              Requires = [ "graphical-session-pre.target" ];
            };
          };

          xdg.configFile = lib.attrsets.mergeAttrsList (
            map mkLinkConfig [
              "hypr/hypridle.conf"
              "hypr/hyprland.conf"
              "hypr/hyprlock.conf"
              "hypr/hyprpaper.conf"
              "hypr/handle_lid_switch.sh"
              "hypr/mocha.conf"
              "rofi"
              "waybar"
              "kanshi/config"
            ]
          );

          services = {
            gnome-keyring.enable = true;
            gnome-keyring.components = [ "secrets" ];
            kdeconnect = {
              enable = true;
              indicator = true;
            };
          };

          systemd.user.services = {
            kdeconnect.Unit.After = lib.mkForce [ "graphical-session.target" ];
            kdeconnect-indicator.Unit.After = lib.mkForce [ "graphical-session.target" ];
          };

          services.dunst = {
            enable = true;
            settings = {
              global = {
                follow = "mouse";
              };
            };
          };

          services.kanshi = {
            enable = true;
          };

          xsession.preferStatusNotifierItems = true;

          services = {
            hyprpaper.enable = true;
            hypridle.enable = true;
            network-manager-applet.enable = true;
          };
          programs = {
            waybar = {
              enable = true;
              systemd.enable = true;
              systemd.target = "graphical-session.target";
            };
            kitty = {
              enable = true;
              extraConfig = ''
                include /home/efficacy38/test-kitty.conf
              '';
            };
          };
          wayland.windowManager.hyprland.systemd.enable = false;
          home.packages = [
            pkgs.mate.mate-media
            (pkgs.writeShellApplication {
              name = "my-audio-control";
              text =
                ''
                  MUTE_ICON_PATH="${MUTE_ICON_PATH}"
                  LOW_ICON_PATH="${LOW_ICON_PATH}"
                  MEDIUM_ICON_PATH="${MEDIUM_ICON_PATH}"
                  HIGH_ICON_PATH="${HIGH_ICON_PATH}"
                ''
                + builtins.readFile (dotfilesBasePath + /dunst/audio-control.sh);
              runtimeInputs = with pkgs; [
                wireplumber
                coreutils
                dunst
                gnused
              ];
            })
            pkgs.blueberry
            pkgs.rofi-calc
            pkgs.rofi-emoji
            pkgs.kdePackages.breeze
            pkgs.kdePackages.breeze-icons
            pkgs.kdePackages.qtsvg
            pkgs.gawk
          ];
        }
        // lib.optionalAttrs (builtins.hasAttr "stylix" options) {
          stylix = {
            autoEnable = false;
            targets = {
              gtk.enable = lib.mkDefault true;
              dunst.enable = lib.mkDefault true;
              fcitx5.enable = lib.mkDefault true;
              fzf.enable = lib.mkDefault true;
              gedit.enable = lib.mkDefault true;
              kitty.enable = lib.mkDefault true;
              emacs.enable = lib.mkDefault true;
            };
          };
        }
      );
    };
}
