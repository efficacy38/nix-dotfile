# Hyprland desktop environment configuration
_:
let
  dotfilesBasePath = ../../../../dotfiles;
in
{
  # NixOS: Hyprland system config
  flake.nixosModules.desktop-hyprland =
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
      config = lib.mkIf (cfg.enable && cfg.hyprland.enable) {
        programs.hyprland = {
          enable = true;
          withUWSM = true;
        };

        hardware.graphics.enable = true;
        environment.systemPackages = with pkgs; [
          # terminals
          alacritty
          wezterm
          networkmanagerapplet

          waybar
          eww

          # notification
          dunst
          libnotify

          # wallpaper
          hyprpaper
          hyprshot
          swaybg
          wpaperd
          mpvpaper
          swww
          brightnessctl

          # launcher
          rofi

          # lock & idle
          hyprlock
          hypridle

          catppuccin-sddm
          wireshark
          super-productivity
          # tradingview
        ];

        security.pam.services.sddm.enableGnomeKeyring = true;
        services.gnome.gnome-keyring.enable = true;

        systemd.sleep.settings.Sleep = {
          AllowSuspend = "yes";
          AllowHibernation = "no";
          AllowHybridSleep = "no";
          AllowSuspendThenHibernate = "no";
        };
      };
    };

  # Home-manager: Hyprland user config
  flake.homeModules.desktop-hyprland =
    {
      pkgs,
      options,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
      dotfilesDir = "/etc/nixos/nix-dotfile/dotfiles";

      mkLinkConfig = relativePath: {
        "${relativePath}".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/${relativePath}";
      };

      MUTE_ICON_PATH = dotfilesBasePath + /dunst/volume-off.png;
      LOW_ICON_PATH = dotfilesBasePath + /dunst/volume-low.png;
      MEDIUM_ICON_PATH = dotfilesBasePath + /dunst/volume-medium.png;
      HIGH_ICON_PATH = dotfilesBasePath + /dunst/volume-high.png;
    in
    {
      config = lib.mkIf (cfg.enable && cfg.hyprland.enable) (
        {
          # FIXME: work-around for hm
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
              "hypr/hyprland.lua"
              "hypr/hyprlock.conf"
              "hypr/hyprpaper.conf"
              "hypr/handle_lid_switch.sh"
              "hypr/mocha.lua"
              "rofi"
              "waybar"
              "alacritty/alacritty.toml"
              "alacritty/catppuccin-mocha.toml"
              "hyprmon/profiles"
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
            settings.global.follow = "mouse";
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
            alacritty.enable = true;
          };

          wayland.windowManager.hyprland.systemd.enable = false;

          home.packages = [
            pkgs.mate-media
            (pkgs.writeShellApplication {
              name = "my-audio-control";
              text = ''
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
            pkgs.blueman
            pkgs.rofi-calc
            pkgs.rofi-emoji
            pkgs.kdePackages.breeze
            pkgs.kdePackages.breeze-icons
            pkgs.kdePackages.qtsvg
            pkgs.gawk
            pkgs.hyprmon
            pkgs.libreoffice

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
              emacs.enable = lib.mkDefault true;
              kde.enable = lib.mkDefault false;
            };
          };
        }
      );
    };
}
