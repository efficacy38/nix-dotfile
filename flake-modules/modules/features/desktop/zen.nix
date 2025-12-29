# Zen browser configuration
_:
{
  # NixOS: Zen browser persistence
  flake.nixosModules.desktop-zen =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      config = lib.mkIf cfg.enable {
        # Persist Zen browser profile
        environment.persistence."/persistent/system".users."efficacy38" = {
          directories = [
            ".zen" # Browser profile directory
          ];
        };
      };
    };

  # Home-manager only: Zen browser config
  flake.homeModules.desktop-zen =
    {
      pkgs,
      lib,
      inputs,
      config,
      ...
    }:
    let
      cfg = config.my.desktop;
    in
    {
      config = lib.mkIf (cfg.enable && cfg.zen.enable) {
        xdg.mimeApps = lib.mkForce {
          enable = true;
          defaultApplications = {
            "x-scheme-handler/http" = [ "zen.desktop" ];
            "x-scheme-handler/https" = [ "zen.desktop" ];
            "text/html" = [ "zen.desktop" ];
            "application/pdf" = [ "zen.desktop" ];
          };
        };

        programs.firefox = {
          enable = true;
          package = inputs.zen-browser.packages."${pkgs.system}".default;
          configPath = ".zen";

          profiles.personal = {
            extensions.packages = with inputs.firefox-addons.packages."${pkgs.system}"; [
              keepassxc-browser
              ublock-origin
              sponsorblock
              darkreader
              vimium
              multi-account-containers
              youtube-shorts-block
              simple-tab-groups
              zotero-connector
            ];

            search.engines = {
              "Nix Packages" = {
                urls = [
                  {
                    template = "https://search.nixos.org/packages";
                    params = [
                      {
                        name = "type";
                        value = "packages";
                      }
                      {
                        name = "channel";
                        value = "unstable";
                      }
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@n" ];
              };
            };

            search.force = true;

            settings = {
              "browser.disableResetPrompt" = true;
              "browser.download.panel.shown" = true;
              "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
              "browser.shell.checkDefaultBrowser" = false;
              "browser.shell.defaultBrowserCheckCount" = 1;
              "browser.uiCustomization.state" =
                ''{"placements":{"widget-overflow-fixed-list":[],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","urlbar-container","downloads-button","library-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":18,"newElementCount":4}'';
              "identity.fxaccounts.enabled" = false;
              "privacy.trackingprotection.enabled" = true;
              "signon.rememberSignons" = false;
            };
          };
        };
      };
    };
}
