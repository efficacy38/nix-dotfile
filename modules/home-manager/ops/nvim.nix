{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    neovim
    nodejs_22
    yamllint
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # home.file = {
  #   ".config/nvim" = {
  #     source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/dotfiles/nvim";
  #   };
  # };
}
