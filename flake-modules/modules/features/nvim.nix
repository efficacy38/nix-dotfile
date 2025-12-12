{ ... }:
{
  flake.homeModules.nvim =
    {
      config,
      pkgs-unstable,
      lib,
      ...
    }:
    let
      cfg = config.my.nvim;
    in
    {
      options.my.nvim = {
        enable = lib.mkEnableOption "neovim configuration";
      };

      config = lib.mkIf cfg.enable {
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
}
