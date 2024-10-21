{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    neovim
    yamllint
    nodejs # copilot
    terraform-ls
    pyright

    # based on ./suggested-pkgs.json
    gopls
    golangci-lint
    nodePackages.bash-language-server
    taplo-lsp
    marksman
    selene
    rust-analyzer
    yaml-language-server
    nil
    nixd
    shellcheck
    shfmt
    ruff
    ruff-lsp
    nixfmt-rfc-style
    terraform-ls
    clang-tools
    nodePackages.prettier
    stylua
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
