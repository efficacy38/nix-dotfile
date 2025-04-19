{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "text/html" = [ "firefox.desktop" ];
      "application/pdf" = [ "firefox.desktop" ];
    };
  };

  programs.firefox = {
    enable = true;
    policies = {
      ExtensionSettings =
        let
          navExtIds = [
            "keepassxc-browser@keepassxc.org"
            "addon@darkreader.org"
            # rabby wallet
            "{743634b5-5b80-4035-a92b-e6aac3fc32ed}"
            "simple-tab-groups@drive4ik"
            # protonpass
            "{873e3fcc-d6d8-40e1-9606-80f6f5590887}"
            # zotero connector
            "zotero@chnm.gmu.edu"
          ];

          menuExtIds = [
            "uBlock0@raymondhill.net"
            "sponsorBlocker@ajay.app"
            # Vimium
            "{d7742d87-e61d-4b78-b8a1-b469842139fa}"
            # multi account
            "@testpilot-containers"
            # yourutbe short block
            "{34daeb50-c2d2-4f14-886a-7160b24d66a4}"
          ];

          posExtNav = extId: {
            ${extId} = {
              default_area = "navbar";
            };
          };

          posExtMenu = extId: {
            "${extId}" = {
              default_area = "menupanel";
            };
          };

          merged = lib.foldl' lib.recursiveUpdate { } (
            (map posExtNav navExtIds) ++ (map posExtMenu menuExtIds)
          );
        in
        merged;

    };
    profiles.personal = {
      extensions = with inputs.firefox-addons.packages."${pkgs.system}"; [
        keepassxc-browser
        sponsorblock
        darkreader
        vimium
        multi-account-containers
        youtube-shorts-block
        simple-tab-groups
        zotero-connector
        proton-pass
        ublock-origin
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
        # "browser.startup.homepage" = "https://start.duckduckgo.com";

        # taken from Misterio77's config
        "browser.uiCustomization.state" =
          ''{"placements":{"widget-overflow-fixed-list":[],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","urlbar-container","downloads-button","library-button","testpilot-containers-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":18,"newElementCount":4}'';
        "identity.fxaccounts.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "signon.rememberSignons" = false;
      };
    };
  };
}
