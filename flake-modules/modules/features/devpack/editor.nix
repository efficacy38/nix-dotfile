# Editor tools: nvim, git
{ ... }:
{
  # Home-manager: neovim configuration
  flake.homeModules.devpack-nvim =
    {
      config,
      pkgs-unstable,
      lib,
      ...
    }:
    let
      cfg = config.my.devpack;
    in
    {
      config = lib.mkIf (cfg.enable && cfg.nvimEnable) {
        home = {
          packages = with pkgs-unstable; [
            neovim
            yamllint
            nodejs
            terraform-ls
            pyright
            gcc
            texpresso
            edukai
            ttf-tw-moe

            lua-language-server
            terraform-ls
            yaml-language-server
            gopls
            nodePackages.bash-language-server
            golangci-lint
            docker-compose-language-service
            docker-ls
            taplo
            sqls
            marksman
            selene
            rust-analyzer
            nil
            nixd
            shellcheck
            shfmt
            ruff
            nixfmt-rfc-style
            nodePackages.prettier
            stylua
            tflint
            tfsec
            typescript-language-server
            prettierd
            ansible-lint
            hadolint
            deadnix
            alejandra
            typos
            typos-lsp
            jsonnet-language-server
            dockerfile-language-server
            docker-compose-language-service
            astro-language-server
            vtsls
            delve
            deno

            go
            gofumpt
            gomodifytags
            gotools
            delve
            gomodifytags
            gotests
            iferr
            impl
            reftools
            ginkgo
            richgo
            govulncheck

            lynx
          ];
          sessionVariables = {
            EDITOR = "nvim";
          };

          file = {
            ".config/nvim" = {
              source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/nix-dotfile/dotfiles/nvim";
            };
          };
        };
      };
    };

  # Home-manager: git configuration
  flake.homeModules.devpack-git =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.devpack;
    in
    {
      config = lib.mkIf (cfg.enable && cfg.gitEnable) {
        home.packages = with pkgs; [
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
