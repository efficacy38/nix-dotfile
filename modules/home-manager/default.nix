{ config
, userName ? "efficacy38"
, desktopEnable ? false
, devProgEnable ? false
, ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "${userName}";
  home.homeDirectory = "/home/${userName}";
  home.stateVersion = "${config.system.stateVersion}";


  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # enable shells
  # programs.bash.enable = true;
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./shell
    ./ops
  ] ++ (if desktopEnable then [ ./desktop ] else [ ])
  ++ (if devProgEnable then [ ./programing ] else [ ]);
}
