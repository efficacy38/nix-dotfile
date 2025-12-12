{
  config,
  pkgs-unstable,
  pkgs-stable,
  lib,
  ...
}:
let
  cfg = config.myHomeManager.nvim;
in
{
  options.myHomeManager.nvim = {
    enable = lib.mkEnableOption "neovim configuration";
  };

  config = lib.mkIf cfg.enable {
    home = {
    packages = with pkgs-unstable; [
      neovim
      yamllint
      nodejs # copilot
      terraform-ls
      pyright
      # treesitter needs an compiler
      gcc
      texpresso
      edukai
      ttf-tw-moe

        # based on ./suggested-pkgs.json
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
        # clang-tools
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
        # eslint
        deno

        # based on https://github.com/ray-x/go.nvim#go-binaries-install-and-update
        go
        gofumpt
        gomodifytags
        gotools
        delve
        # golines
        gomodifytags
        gotests
        iferr
        impl
        reftools
        ginkgo
        richgo
        govulncheck

        # better prompt of copilot
        lynx
      ];
      sessionVariables = {
        EDITOR = "nvim";
      };

      file = {
        ".config/nvim" = {
          source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/nix-dotfile/home-modules/dotfiles/nvim";
        };
      };
    };
  };
}
