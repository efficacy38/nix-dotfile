{
  config,
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      neovim
      yamllint
      nodejs # copilot
      terraform-ls
      pyright
      # treesitter needs an compiler
      gcc

      # based on ./suggested-pkgs.json
      lua-language-server
      terraform-ls
      yaml-language-server
      ansible-language-server
      gopls
      nodePackages.bash-language-server
      golangci-lint
      docker-compose-language-service
      docker-ls
      taplo-lsp
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
      clang-tools
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
      dockerfile-language-server-nodejs
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

}
