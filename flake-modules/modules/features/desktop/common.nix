# Common desktop configuration (shared by all desktop environments)
{ ... }:
{
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
        zramEnable = lib.mkEnableOption "enable zram";
        hyprlandEnable = lib.mkEnableOption "enable hyprland(system)";
        kdeEnable = lib.mkEnableOption "enable KDE(system)";
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
          (lib.mkIf cfg.zramEnable zram-config)
        ]
      );
    };

  # Home-manager: common desktop packages
  flake.homeModules.desktop =
    {
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
        hyprlandEnable = lib.mkEnableOption "Hyprland home-manager configuration";
        kdeEnable = lib.mkEnableOption "KDE home-manager packages";
        zenEnable = lib.mkEnableOption "Zen browser configuration";
      };

      config = lib.mkIf cfg.enable {
        fonts.fontconfig.enable = true;

        home.packages = with pkgs-unstable; [
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
          keepassxc
        ];
      };
    };
}
