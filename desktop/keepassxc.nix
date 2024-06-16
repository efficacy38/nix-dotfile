{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    keepassxc
    # FIXME: don't forget to setup this credential
    git-credential-keepassxc
  ];
}
