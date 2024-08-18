{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    # git related
    git
    glab
    gh
    lazygit
    git-credential-keepassxc
  ];

  programs.git = {
    enable = true;
    diff-so-fancy = {
      enable = true;
    };
    # git-cliff = {
    #   enable = true;
    # };
    userName = "efficacy38";
    userEmail = "efficacy38@gmail.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      s = "status";
    };
    extraConfig = {
      core = { whitespace = "trailing-space,space-before-tab"; };
      credential = {
        helper = "cache --timeout 3600";
      };
    };
  };
}
