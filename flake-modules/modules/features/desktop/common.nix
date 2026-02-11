# Common desktop configuration (shared by all desktop environments)
_: {
  # NixOS: common desktop system config
  flake.nixosModules.desktop =
    {
      lib,
      config,
      pkgs,
      inputs,
      ...
    }:
    let
      cfg = config.my.desktop;
      secretpath = builtins.toString inputs.nix-secrets;
    in
    {
      options.my.desktop = {
        enable = lib.mkEnableOption "enable desktop Environment";
        zram.enable = lib.mkEnableOption "enable zram";
        hyprland.enable = lib.mkEnableOption "enable hyprland(system)";
        kde.enable = lib.mkEnableOption "enable KDE(system)";
      };

      config = lib.mkIf cfg.enable (
        let
          common-config = {
            # enable networkmanager for desktop usage
            networking.networkmanager.enable = true;
            networking.firewall.enable = lib.mkDefault true;
            services = {
              fwupd.enable = true;

              # Enable the X11 windowing system.
              xserver.enable = true;
              displayManager.sddm = {
                enable = true;
                wayland.enable = true;
                theme = "catppuccin-mocha";
                enableHidpi = true;
                package = pkgs.kdePackages.sddm;
              };

              # Configure power key to lock screen instead of shutdown
              logind.settings.Login = {
                HandlePowerKey = "lock";
              };
            };

            # Configure keymap in X11
            services.xserver.xkb = {
              layout = "us";
              variant = "";
            };

            # Enable CUPS to print documents.
            services.printing.enable = true;
            services.avahi = {
              enable = true;
              nssmdns4 = true;
              openFirewall = true;
            };

            # Enable sound with pipewire.
            security.rtkit.enable = true;
            services.pipewire = {
              enable = true;
              alsa.enable = true;
              alsa.support32Bit = true;
              pulse.enable = true;
            };

            # Select internationalisation properties.
            i18n.inputMethod = {
              enable = true;
              type = "fcitx5";
              fcitx5.addons = with pkgs; [
                rime-data
                fcitx5-rime
                qt6Packages.fcitx5-chinese-addons
                librime
              ];
            };

            # Some programs need SUID wrappers
            programs = {
              gnupg.agent = {
                enable = true;
                enableSSHSupport = true;
              };
              yubikey-touch-detector.enable = true;
              wireshark.enable = true;
            };

            # enables support for Bluetooth
            hardware.bluetooth.enable = true;
            hardware.bluetooth.powerOnBoot = true;

            # use stylix to themeing whole DE
            stylix = {
              enable = true;
              base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
            };

            sops.secrets.suisei-january-wallpaper = {
              format = "binary";
              sopsFile = "${secretpath}/secrets/wallpapers/suisei-january-wallpaper.png";
              path = "/usr/share/wallpapers/suisei-january-wallpaper.png";
              mode = "444";
            };

            services.solaar.enable = true;
          };

          persistence-config = {
            # Persist user data directories and desktop applications
            environment.persistence."/persistent/system".users."efficacy38" = {
              directories = [
                # XDG user data directories
                "Music"
                "Downloads"
                "Pictures"
                "Documents"
                "Videos"
                "Sync"
                "Zotero" # Academic reference manager
                "Postman" # API development tool

                # Desktop applications
                ".thunderbird" # Email client
                ".config/keepassxc" # Password manager
                ".cache/keepassxc"
                ".local/share/remmina" # Remote desktop
                ".local/share/Trash" # System utilities
                ".config/Moonlight\\ Game\\ Streaming\\ Project" # Game streaming
                ".config/superProductivity" # Productivity app
                ".config/solaar" # Logitech device manager
              ];
            };
          };

          zram-config = {
            zramSwap = {
              enable = true;
              memoryPercent = 50;
            };
            boot.kernel.sysctl = {
              "vm.swappiness" = 180;
              "vm.watermark_boost_factor" = 0;
              "vm.watermark_scale_factor" = 125;
              "vm.page-cluster" = 0;
            };
          };
        in
        lib.mkMerge [
          common-config
          (lib.mkIf config.my.system.impermanence.enable persistence-config)
          (lib.mkIf cfg.zram.enable zram-config)
        ]
      );
    };

  # Home-manager: common desktop packages
  flake.homeModules.desktop =
    {
      pkgs,
      pkgs-unstable,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      options.my.desktop = {
        enable = lib.mkEnableOption "desktop home-manager configuration";
        hyprland.enable = lib.mkEnableOption "Hyprland home-manager configuration";
        kde.enable = lib.mkEnableOption "KDE home-manager packages";
        zen.enable = lib.mkEnableOption "Zen browser configuration";
      };

      config = lib.mkIf cfg.enable {
        fonts.fontconfig.enable = true;

        # Common XDG MIME type associations
        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            # Text files
            "text/plain" = [ "nvim.desktop" ];
            "text/markdown" = [ "nvim.desktop" ];

            # Images
            "image/png" = [ "org.gnome.eog.desktop" ];
            "image/jpeg" = [ "org.gnome.eog.desktop" ];
            "image/jpg" = [ "org.gnome.eog.desktop" ];
            "image/gif" = [ "org.gnome.eog.desktop" ];
            "image/webp" = [ "org.gnome.eog.desktop" ];
            "image/svg+xml" = [ "org.gnome.eog.desktop" ];
            "image/bmp" = [ "org.gnome.eog.desktop" ];

            # Videos
            "video/mp4" = [ "haruna.desktop" ];
            "video/x-matroska" = [ "haruna.desktop" ];
            "video/webm" = [ "haruna.desktop" ];
            "video/avi" = [ "haruna.desktop" ];
            "video/x-msvideo" = [ "haruna.desktop" ];
            "video/quicktime" = [ "haruna.desktop" ];

            # Audio
            "audio/mpeg" = [ "haruna.desktop" ];
            "audio/mp3" = [ "haruna.desktop" ];
            "audio/flac" = [ "haruna.desktop" ];
            "audio/x-flac" = [ "haruna.desktop" ];
            "audio/ogg" = [ "haruna.desktop" ];
            "audio/x-wav" = [ "haruna.desktop" ];

            # Archives
            "application/zip" = [ "org.kde.ark.desktop" ];
            "application/x-tar" = [ "org.kde.ark.desktop" ];
            "application/x-gzip" = [ "org.kde.ark.desktop" ];
            "application/x-bzip2" = [ "org.kde.ark.desktop" ];
            "application/x-7z-compressed" = [ "org.kde.ark.desktop" ];
            "application/x-rar" = [ "org.kde.ark.desktop" ];
            "application/x-xz" = [ "org.kde.ark.desktop" ];

            # Directories (file manager)
            "inode/directory" = [ "org.kde.dolphin.desktop" ];
          };
        };

        home.packages =
          (with pkgs-unstable; [
            # fonts
            nerd-fonts.hack
            nerd-fonts.fira-mono
            nerd-fonts.fira-code
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif

            # desktop apps
            thunderbird
            obs-studio
            chromium

            # utils
            remmina
            haruna

            # games
            prismlauncher
            moonlight-qt
            vscode

            zotero
            zotero-translation-server
            obsidian
            keepassxc
            eog
          ])
          ++ (with pkgs.kdePackages; [
            # Common desktop utilities (for MIME apps) - using stable
            dolphin
            # needed for dolphin to open some applications is terminal based
            konsole
            ark
            okular
          ]);
      };
    };
}
