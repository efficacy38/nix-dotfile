{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # git related
    git
    glab
    gh
    lazygit
  ];

  programs.git = {
    enable = true;
    userName = "efficacy38";
    userEmail = "efficacy38@gmail.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      s = "status";
    };
  };
}
