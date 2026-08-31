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
        sops.secrets = {
          "github_ssh_key" = {
            sopsFile = "${secretpath}/secrets/common.yaml";
            owner = "efficacy38";
            mode = "0600";
            path = "/home/efficacy38/.ssh/keys/gh.id_ed25519";
          };
          "github_pub_ssh_key" = {
            sopsFile = "${secretpath}/secrets/common.yaml";
            owner = "efficacy38";
            mode = "0644";
            path = "/home/efficacy38/.ssh/keys/gh.id_ed25519.pub";
          };
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
            ansible-language-server
            astro-language-server
            basedpyright
            bash-language-server
            black
            clang-tools # clangd
            cuelsp
            deadnix
            delve
            deno
            docker-compose-language-service
            docker-language-server
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
            isort
            jsonnet-language-server
            lua-language-server
            lynx
            marksman
            neovim
            nixd
            nixfmt
            nil
            # nodePackages.prettier
            nodejs
            prettierd
            pyright
            pyrefly
            python3Packages.debugpy
            reftools
            richgo
            ruff
            rust-analyzer
            selene
            shellcheck
            shfmt
            sqlfluff
            sqls
            stylua
            taplo
            terraform-ls
            texpresso
            tflint
            tfsec
            ttf-tw-moe
            ty
            typescript-language-server
            typos
            typos-lsp
            vtsls
            vscode-extensions.vadimcn.vscode-lldb.adapter # codelldb
            vscode-js-debug # js-debug-adapter
            vscode-langservers-extracted # json-lsp
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
          ssh = {
            enable = true;
            enableDefaultConfig = false;
            settings = {
              "github.com" = {
                IdentityFile = "~/.ssh/keys/gh.id_ed25519";
                IdentitiesOnly = true;
              };
              "*" = {
                ForwardAgent = lib.mkDefault false;
                AddKeysToAgent = lib.mkDefault "no";
                Compression = lib.mkDefault false;
                ServerAliveInterval = lib.mkDefault 0;
                ServerAliveCountMax = lib.mkDefault 3;
                HashKnownHosts = lib.mkDefault false;
                UserKnownHostsFile = lib.mkDefault "~/.ssh/known_hosts";
                ControlMaster = lib.mkDefault "no";
                ControlPath = lib.mkDefault "~/.ssh/master-%r@%n:%p";
                ControlPersist = lib.mkDefault "no";
              };
            };
            includes = [
              "config.d/*.conf"
            ];
          };

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
                  condition = "hasconfig:remote.*.url:ssh://git@github.com:*/**";
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
