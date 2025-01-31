{
  config,
  userName ? "efficacy38",
  desktopEnable ? false,
  devProgEnable ? false,
  ...
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

  # would generate alias script
  my-gpg = [
    {
      usage = "personal";
      keyCapacity = "enc";
      subkeyId = "1722121F0FB35C6CDA7ABF9E680078CD836172D6";
    }
    {
      usage = "personal";
      keyCapacity = "sign";
      subkeyId = "5EAB3A07B1B5078585C1C5E938DFF1897150C309";
    }
  ];

  imports =
    [
      ./shell
      ./ops
    ]
    ++ (if desktopEnable then [ ./desktop ] else [ ])
    ++ (if devProgEnable then [ ./programing ] else [ ]);
}
