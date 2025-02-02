{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.main-user;
in
{
  options.main-user = {
    desktopEnable = lib.mkEnableOption "enable desktop support(current only kde)";
    devProgEnable = lib.mkEnableOption "enable development programming language tool support";

    userName = lib.mkOption {
      default = "efficacy38";
      description = ''
        username, whose has sudo privilege of every command
      '';
    };
  };

  config = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.

    home.username = "${cfg.userName}";
    home.homeDirectory = "/home/${cfg.userName}";

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
      {
        usage = "personal";
        keyCapacity = "auth";
        subkeyId = "7964380B1866F94F09FBEE68F66D16FB0A1D33BB";
      }
    ];
  };

  imports = [
    ./shell
    ./ops
    # TODO: refactor not complete, still need toggle options
    ./desktop
    ./programing
  ];
}
