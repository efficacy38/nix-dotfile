{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gnupg
    sshfs
    openssl
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
}
