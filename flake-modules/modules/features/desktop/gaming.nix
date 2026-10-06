# Gaming configuration: Steam and Sunshine.
_: {
  # NixOS: Steam gaming
  flake.nixosModules.desktop-steam =
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
      options.my.desktop.steam.enable = lib.mkEnableOption "Steam gaming";
      options.my.desktop.steam.hidpi = lib.mkEnableOption "scale steam for HiDPI";

      config = lib.mkMerge [
        (lib.mkIf (cfg.enable && cfg.steam.enable) {
          programs.steam = {
            enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
            localNetworkGameTransfers.openFirewall = true;
          };

          hardware.graphics.extraPackages = [ pkgs.libva-vdpau-driver ];
          hardware.steam-hardware.enable = true;

          # Bluetooth tuning for Xbox controllers. The base
          # hardware.bluetooth (enable + powerOnBoot) is set by
          # desktop/common.nix.
          hardware.bluetooth.settings.General = {
            experimental = true; # show battery

            # https://www.reddit.com/r/NixOS/comments/1ch5d2p/comment/lkbabax/
            # for pairing bluetooth controller
            Privacy = "device";
            JustWorksRepairing = "always";
            Class = "0x000100";
            FastConnectable = true;
          };
          hardware.xpadneo.enable = true; # xpadneo driver for Xbox One wireless controllers
          boot = {
            extraModulePackages = with config.boot.kernelPackages; [ xpadneo ];
            extraModprobeConfig = ''
              options bluetooth disable_ertm=Y
            '';
            # connect xbox controller
          };

          environment.sessionVariables = lib.mkIf cfg.steam.hidpi {
            STEAM_FORCE_DESKTOPUI_SCALING = "2";
          };
        })
        (lib.mkIf (cfg.enable && cfg.steam.enable && config.my.system.impermanence.enable) {
          # Persist gaming data at system level (for user efficacy38)
          # Note: Using system-level persistence since this is a NixOS-only module
          # TODO: Consider creating home-manager companion module for better username templating
          environment.persistence."/persistent/system" = {
            users."efficacy38" = {
              directories = [
                ".local/share/Steam" # Steam gaming platform
                ".local/share/PrismLauncher" # PrismLauncher (Minecraft)
              ];
            };
          };
        })
      ];
    };

  # NixOS: Sunshine game streaming server
  flake.nixosModules.desktop-sunshine =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      options.my.desktop.sunshine.enable = lib.mkEnableOption "Sunshine game streaming server";

      config = lib.mkIf (cfg.enable && cfg.sunshine.enable) {
        services.sunshine = {
          enable = true;
          openFirewall = true;
          capSysAdmin = true;
          autoStart = true;
        };
      };
    };
}
