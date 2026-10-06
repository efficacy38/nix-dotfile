# Desktop session managers: Hyprland, KDE Plasma, and the shared XDG portal.
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
      options.my.desktop.hyprland.enable = lib.mkEnableOption "Hyprland (system)";

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
          awww
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

  # NixOS: KDE Plasma system config
  flake.nixosModules.desktop-kde =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      options.my.desktop.kde.enable = lib.mkEnableOption "KDE Plasma (system)";

      config = lib.mkMerge [
        (lib.mkIf (cfg.enable && cfg.kde.enable) {
          services.desktopManager.plasma6.enable = true;
          security.pam.services.sddm.enableKwallet = true;
        })
        (lib.mkIf (cfg.enable && cfg.kde.enable && config.my.system.impermanence.enable) {
          # Persist KDE application data
          environment.persistence."/persistent/system".users."efficacy38" = {
            directories = [
              ".local/share/dolphin" # Dolphin file manager
              ".local/share/kate" # Kate text editor
              ".local/share/sddm" # SDDM display manager state
            ];
          };
        })
      ];
    };

  # NixOS: XDG portal configuration (auto-enabled with the desktop)
  flake.nixosModules.desktop-xdg =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      config = lib.mkIf cfg.enable {
        # compatibility with KDE applications
        environment.etc."/xdg/menus/plasma-applications.menu".text =
          builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

        # for better compatibility, check https://wiki.archlinux.org/title/XDG_Desktop_Portal
        xdg.portal = {
          enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-hyprland
            xdg-desktop-portal-gnome
            xdg-desktop-portal-gtk
            kdePackages.xdg-desktop-portal-kde
          ];
          config = {
            hyprland = {
              default = [
                "hyprland"
                "gtk"
              ];
            };
          };
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
      inStore = config.my.dotfiles.inStore;

      mkLinkConfig = relativePath: {
        "${relativePath}".source =
          if inStore then
            dotfilesBasePath + "/${relativePath}"
          else
            config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/${relativePath}";
      };

      MUTE_ICON_PATH = dotfilesBasePath + /dunst/volume-off.png;
      LOW_ICON_PATH = dotfilesBasePath + /dunst/volume-low.png;
      MEDIUM_ICON_PATH = dotfilesBasePath + /dunst/volume-medium.png;
      HIGH_ICON_PATH = dotfilesBasePath + /dunst/volume-high.png;
    in
    {
      options.my.desktop.hyprland.enable = lib.mkEnableOption "Hyprland home-manager configuration";

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
            dunst = {
              enable = true;
              settings.global.follow = "mouse";
            };
            hyprpaper.enable = true;
            hypridle.enable = true;
            network-manager-applet.enable = true;
          };

          systemd.user.services = {
            kdeconnect.Unit.After = lib.mkForce [ "graphical-session.target" ];
            kdeconnect-indicator.Unit.After = lib.mkForce [ "graphical-session.target" ];
          };

          xsession.preferStatusNotifierItems = true;

          programs = {
            waybar = {
              enable = true;
              systemd.enable = true;
              systemd.targets = [ "graphical-session.target" ];
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

  # Home-manager: KDE user packages
  flake.homeModules.desktop-kde =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      options.my.desktop.kde.enable = lib.mkEnableOption "KDE Plasma home-manager packages";

      config = lib.mkIf (cfg.enable && cfg.kde.enable) {
        home.packages = with pkgs.kdePackages; [
          elisa
          ghostwriter
          kate
          kcalc
          kdeconnect-kde
          markdownpart
          yakuake
        ];
      };
    };
}
