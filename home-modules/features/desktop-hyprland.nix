{
  pkgs,
  options,
  lib,
  config,
  ...
}:
let
  dotfilesDir = "/etc/nixos/nix-dotfile/home-modules/dotfiles";
  mkLinkConfig =
    path:
    let
      cleanPath = lib.path.removePrefix ../dotfiles path;
    in
    {
      "${cleanPath}".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/${cleanPath}";
    };

  MUTE_ICON_PATH = ../dotfiles/dunst/volume-off.png;
  LOW_ICON_PATH = ../dotfiles/dunst/volume-low.png;
  MEDIUM_ICON_PATH = ../dotfiles/dunst/volume-medium.png;
  HIGH_ICON_PATH = ../dotfiles/dunst/volume-high.png;
in
{
  config =
    {
      # FIXME: This is work-around of hm, check it periodically
      # https://github.com/nix-community/home-manager/issues/2064
      systemd.user.targets.tray = {
        Unit = {
          Description = "Home Manager System Tray";
          Requires = [ "graphical-session-pre.target" ];
        };
      };

      xdg.configFile = lib.attrsets.mergeAttrsList (
        map mkLinkConfig [
          ../dotfiles/hypr/hypridle.conf
          ../dotfiles/hypr/hyprland.conf
          ../dotfiles/hypr/hyprlock.conf
          ../dotfiles/hypr/hyprpaper.conf
          ../dotfiles/hypr/handle_lid_switch.sh
          ../dotfiles/hypr/mocha.conf
          ../dotfiles/rofi
          ../dotfiles/waybar
        ]
      );

      # enable gnome keyring
      services.gnome-keyring.enable = true;
      services.gnome-keyring.components = [ "secrets" ];

      # enable kdeconnect
      services.kdeconnect = {
        enable = true;
        indicator = true;
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

      # to make nm-applet indicator show up
      xsession.preferStatusNotifierItems = true;

      services.hyprpaper.enable = true;
      services.hypridle.enable = true;
      services.network-manager-applet.enable = true;
      programs.waybar.enable = true;
      programs.waybar.systemd.enable = true;
      programs.waybar.systemd.target = "graphical-session.target";
      # programs.alacritty.enable = true;
      programs.kitty.enable = true;
      programs.kitty.extraConfig = ''
        include /home/efficacy38/test-kitty.conf
      '';
      wayland.windowManager.hyprland.systemd.enable = false;
      home.packages = [
        pkgs.mate.mate-media
        pkgs.overskride
        (pkgs.writeShellApplication {
          name = "my-audio-control";
          text =
            ''
              MUTE_ICON_PATH="${MUTE_ICON_PATH}"
              LOW_ICON_PATH="${LOW_ICON_PATH}"
              MEDIUM_ICON_PATH="${MEDIUM_ICON_PATH}"
              HIGH_ICON_PATH="${HIGH_ICON_PATH}"
            ''
            + builtins.readFile ../dotfiles/dunst/audio-control.sh;
          runtimeInputs = with pkgs; [
            wireplumber
            coreutils
            dunst
            gnused
          ];
        })
        pkgs.overskride
        pkgs.rofi-calc
        pkgs.rofi-emoji-wayland
        pkgs.kdePackages.breeze
        pkgs.kdePackages.breeze-icons
        pkgs.kdePackages.qtsvg
        pkgs.gawk
      ];
    }
    // lib.optionalAttrs (builtins.hasAttr "stylix" options) {
      stylix.targets.waybar.enable = false;
      stylix.targets.waybar.addCss = false;
      stylix.targets.hyprpaper.enable = false;
      stylix.targets.firefox.enable = false;
      stylix.targets.kde.enable = false;
    };
}
