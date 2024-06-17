{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    gnupg
    sshfs
    openssl
  ];
}
