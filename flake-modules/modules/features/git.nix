{ ... }:
{
  flake.homeModules.git =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.git;
    in
    {
      options.my.git = {
        enable = lib.mkEnableOption "git configuration";
      };

      config = lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          # git related
          git
          glab
          gh
          lazygit
          git-credential-keepassxc
        ];

        programs.diff-so-fancy.enable = true;
        programs.diff-so-fancy.enableGitIntegration = true;
        programs.git = {
          enable = true;

          lfs.enable = true;

          settings = {
            user = {
              name = "efficacy38";
              email = "efficacy38@gmail.com";
            };
            aliases = {
              ci = "commit";
              co = "checkout";
              s = "status";
            };
            core = {
              whitespace = "trailing-space,space-before-tab";
            };
            credential = {
              helper = "cache --timeout 3600";
            };
          };

          includes =
            let
              cscc-git-config = {
                user = {
                  name = "Cai-Sian Jhuang";
                  email = "csjhuang@cs.nctu.edu.tw";
                  signingkey = "~/.ssh/keys/cscc.id_ed25519.pub";
                };
                commit.gpgsign = "true";
                gpg.format = "ssh";
              };
              gh-git-config = {
                user = {
                  name = "efficacy38";
                  email = "efficacy38@gmail.com";
                  signingkey = "~/.ssh/keys/gh.id_ed25519.pub";
                };
                commit.gpgsign = "true";
                gpg.format = "ssh";
              };
            in
            [
              {
                condition = "hasconfig:remote.*.url:ssh://git@gitlab.cc.cs.nctu.edu.tw:10022/**";
                contents = cscc-git-config;
              }
              {
                condition = "hasconfig:remote.*.url:https://gitlab.it.cs.nycu.edu.tw/**";
                contents = cscc-git-config;
              }
              {
                condition = "hasconfig:remote.*.url:https://github.com/**";
                contents = gh-git-config;
              }
              {
                path = ".config/git/99-local.conf";
              }
            ];
        };
      };
    };
}
