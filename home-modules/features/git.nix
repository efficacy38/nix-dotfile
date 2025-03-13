{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # git related
    git
    glab
    gh
    lazygit
    git-credential-keepassxc
  ];

  programs.git = {
    enable = true;

    lfs.enable = true;
    diff-so-fancy.enable = true;

    # git-cliff = {
    #   enable = true;
    # };
    userName = "efficacy38";
    userEmail = "efficacy38@gmail.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      s = "status";
    };
    extraConfig = {
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
            signingkey = "~/.ssh/cscc.id_ed25519.pub";
          };
          commit.gpgsign = "true";
          gpg.format = "ssh";
        };
        gh-git-config = {
          user = {
            name = "efficacy38";
            email = "efficacy38@gmail.com";
            signingkey = "~/.ssh/gh.id_ed25519.pub";
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
}
