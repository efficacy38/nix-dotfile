{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    neovim
    nodejs_22
    yamllint
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
