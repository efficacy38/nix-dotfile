# Editor tools: nvim, git
{
  inputs,
  ...
}:
let
  secretpath = builtins.toString inputs.nix-secrets;
in
{
  # NixOS: deploy GitHub SSH keys via sops-nix
  flake.nixosModules.devpack-git =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.devpack;
    in
    {
      config = lib.mkIf cfg.enable {
        sops.secrets."github_ssh_key" = {
          sopsFile = "${secretpath}/secrets/common.yaml";
          owner = "efficacy38";
          mode = "0600";
          path = "/home/efficacy38/.ssh/keys/gh.id_ed25519";
        };
        sops.secrets."github_pub_ssh_key" = {
          sopsFile = "${secretpath}/secrets/common.yaml";
          owner = "efficacy38";
          mode = "0644";
          path = "/home/efficacy38/.ssh/keys/gh.id_ed25519.pub";
        };
      };
    };

  # NixOS: neovim persistence configuration
  flake.nixosModules.devpack-nvim =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.devpack;
    in
    {
      config = lib.mkIf (cfg.enable && config.my.system.impermanence.enable) {
        # Persist Neovim and Node.js package manager data
        environment.persistence."/persistent/system".users."efficacy38" = {
          directories = [
            ".local/share/nvim" # Neovim plugins and state
            ".local/share/pnpm" # pnpm package manager
            ".local/share/yarn" # yarn package manager
          ];
        };
      };
    };

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
      config = lib.mkIf (cfg.enable && cfg.nvim.enable) {
        home = {
          packages = with pkgs-unstable; [
            alejandra
            ansible-lint
            astro-language-server
            deadnix
            delve
            deno
            docker-compose-language-service
            docker-ls
            dockerfile-language-server
            edukai
            gcc
            ginkgo
            go
            gofumpt
            golangci-lint
            gomodifytags
            gopls
            gotests
            gotools
            govulncheck
            hadolint
            iferr
            impl
            jsonnet-language-server
            lua-language-server
            lynx
            marksman
            neovim
            nixd
            nixfmt
            nil
            nodePackages.bash-language-server
            nodePackages.prettier
            nodejs
            prettierd
            pyright
            reftools
            richgo
            ruff
            rust-analyzer
            selene
            shellcheck
            shfmt
            sqls
            stylua
            taplo
            terraform-ls
            texpresso
            tflint
            tfsec
            ttf-tw-moe
            typescript-language-server
            typos
            typos-lsp
            vtsls
            yaml-language-server
            yamllint
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
      config = lib.mkIf (cfg.enable && cfg.git.enable) {
        home.packages = with pkgs; [
          git
          glab
          lazygit
        ];

        programs = {
          gh.enable = true;

          diff-so-fancy = {
            enable = true;
            enableGitIntegration = true;
          };

          git = {
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
    };
}
