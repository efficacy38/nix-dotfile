{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my-desktop;
  secretpath = builtins.toString inputs.nix-secrets;
in
{
  options.my-desktop = {
    enable = lib.mkEnableOption "enable desktop Environment";
    zramEnable = lib.mkEnableOption "enable zram";
    hyprlandEnable = lib.mkEnableOption "enable hyprland(system)";
    kdeEnable = lib.mkEnableOption "enable KDE(system)";
  };

  config = lib.mkIf cfg.enable (
    let
      common-desktop-config = {
        # enable networkmanager for desktop usage
        networking.networkmanager.enable = true;
        networking.firewall.enable = true;
        services = {
          fwupd.enable = true;

          # Enable the X11 windowing system.
          # You can disable this if you're only using the Wayland session.
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
          # If you want to use JACK applications, uncomment this
          #jack.enable = true;

          # use the example session manager (no others are packaged yet so this is enabled by default,
          # no need to redefine it in your config for now)
          #media-session.enable = true;
        };

        # Enable touchpad support (enabled default in most desktopManager).
        # services.xserver.libinput.enable = true;

        # Select internationalisation properties.
        i18n.inputMethod = {
          enable = true;
          type = "fcitx5";
          fcitx5.addons = with pkgs; [
            rime-data
            fcitx5-rime
            fcitx5-chinese-addons
            librime
          ];
        };

        # Some programs need SUID wrappers, can be configured further or are
        # started in user sessions.
        programs = {
          gnupg.agent = {
            enable = true;
            enableSSHSupport = true;
          };

          # make yubikey touch popup notification shown
          yubikey-touch-detector.enable = true;

          # enable wireshark on every desktop
          wireshark.enable = true;
        };

        # unlock gnome keyring when logined(hyprland)
        # security.pam.services.login.enableGnomeKeyring = true;

        # enables support for Bluetooth
        hardware.bluetooth.enable = true;
        # powers up the default Bluetooth controller on boot
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

        # enable podman
        virtualisation.podman.enable = true;
      };

      kde-config = {
        # Enable the KDE Plasma Desktop Environment.
        services.desktopManager.plasma6.enable = true;
        # enable kwallet when sddm start the session
        security.pam.services.sddm.enableKwallet = true;
      };

      hyprland-config = {
        # Enable hyprland config
        programs.hyprland = {
          enable = true;
          withUWSM = true;
        };

        hardware.graphics.enable = true;
        environment.systemPackages = with pkgs; [
          # hyprland default terminal
          alacritty

          # maybe other is good also
          # NOTE: remove following terminal emulator if not necessary
          wezterm
          networkmanagerapplet

          waybar

          # customize widges
          eww

          # for notification
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

          # wayland launcher
          rofi-wayland

          # lock
          hyprlock

          # idle
          hypridle

          # kde application
          pkgs.kdePackages.dolphin
          pkgs.kdePackages.ark

          catppuccin-sddm
          wireshark
        ];

        security.pam.services.sddm.enableGnomeKeyring = true;
        services.gnome.gnome-keyring.enable = true;

        systemd.sleep.extraConfig = ''
          AllowSuspend=no
          AllowHibernation=no
          AllowHybridSleep=no
          AllowSuspendThenHibernate=no
        '';
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
      common-desktop-config
      (lib.mkIf cfg.kdeEnable kde-config)
      (lib.mkIf cfg.hyprlandEnable hyprland-config)
      (lib.mkIf cfg.zramEnable zram-config)
    ]
  );
}
