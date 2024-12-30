{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    neovim
    yamllint
    nodejs # copilot
    terraform-ls
    pyright

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
    ruff-lsp
    nixfmt-rfc-style
    clang-tools
    nodePackages.prettier
    stylua
    tflint
    tfsec
    prettierd
    ansible-lint
    hadolint
    deadnix
    alejandra
    typos
    typos-lsp
    jsonnet-language-server

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
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.file = {
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects/Personal/nix-dotfile/home-modules/dotfiles/nvim";
    };
  };
}
