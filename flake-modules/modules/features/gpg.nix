{ ... }:
{
  flake.homeModules.gpg =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.gpg;
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
      mkGPGScript =
        usage: keyCapacity: subkeyId:
        let
          script = pkgs.writeShellScriptBin "gpg-${keyCapacity}-${usage}" ''
            gpg -r ${subkeyId}! $*
          '';
        in
        script;

      myGpgUtilOpts = with lib; {
        options = {
          usage = mkOption { type = types.str; };
          keyCapacity = mkOption {
            type = types.enum [
              "sign"
              "enc"
              "auth"
            ];
          };
          subkeyId = mkOption { type = types.str; };
        };
      };

      aliasScript = lib.lists.forEach my-gpg (
        conf: mkGPGScript "${conf.usage}" "${conf.keyCapacity}" "${conf.subkeyId}"
      );
    in
    with lib;
    {
      options.my.gpg = {
        enable = lib.mkEnableOption "GPG and Yubikey configuration";
      };

      options.my-gpg = mkOption {
        type = types.listOf (types.submodule myGpgUtilOpts);
        default = [ ];
      };

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.yubikey-manager ] ++ aliasScript;
        programs.zsh.initContent = lib.mkAfter (
          lib.concatStrings (lib.lists.forEach aliasScript (script: "compdef ${script.name}=gpg\n"))
        );
      };
    };
}
