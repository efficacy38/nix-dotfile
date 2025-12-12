{
  pkgs,
  options,
  lib,
  config,
  ...
}:
let
  cfg = config.myHomeManager.desktop-hyprland;
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
  options.myHomeManager.desktop-hyprland = {
    enable = lib.mkEnableOption "Hyprland desktop configuration";
  };

  config = lib.mkIf cfg.enable ({
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
        ../dotfiles/kanshi/config
      ]
    );

    # enable gnome keyring
    services = {
      gnome-keyring.enable = true;
      gnome-keyring.components = [ "secrets" ];
      kdeconnect = {
        enable = true;
        indicator = true;
      };
    };

    # enable kdeconnect
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

    # to make nm-applet indicator show up
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
      # programs.alacritty.enable = true;
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
        text = ''
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
  });
}
