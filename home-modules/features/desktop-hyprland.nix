{
  pkgs,
  config,
  lib,
  ...
}:
let
  dotfilesDir = "${config.home.homeDirectory}/Projects/Personal/nix-dotfile/home-modules/dotfiles";
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
  config.xdg.configFile = lib.attrsets.mergeAttrsList (
    map mkLinkConfig [
      ../dotfiles/hypr/hypridle.conf
      ../dotfiles/hypr/hyprland.conf
      ../dotfiles/hypr/hyprlock.conf
      ../dotfiles/hypr/hyprpaper.conf
      ../dotfiles/hypr/mocha.conf
      ../dotfiles/kitty
      ../dotfiles/rofi
      ../dotfiles/waybar
    ]
  );
  config = {
    # FIXME: This is work-around of hm, check it periodically
    # https://github.com/nix-community/home-manager/issues/2064
    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [ "graphical-session-pre.target" ];
      };
    };

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
    };

    # to make nm-applet indicator show up
    xsession.preferStatusNotifierItems = true;

    services.hyprpaper.enable = true;
    services.hypridle.enable = true;
    services.network-manager-applet.enable = true;
    programs.waybar.enable = true;
    programs.waybar.systemd.enable = true;
    programs.waybar.systemd.target = "graphical-session.target";
    wayland.windowManager.hyprland.systemd.enable = false;
    home.packages = [
      pkgs.mate.mate-panel-with-applets
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
    ];
    stylix.targets.waybar.enable = false;
    stylix.targets.waybar.addCss = false;
    stylix.targets.hyprpaper.enable = false;
  };
}
