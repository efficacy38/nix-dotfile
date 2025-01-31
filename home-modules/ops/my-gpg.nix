{
  pkgs,
  lib,
  config,
  ...
}:
let
  mkGPGScript =
    usage: keyCapacity: subkeyId:
    let
      script = pkgs.writeShellScriptBin "gpg-${keyCapacity}-${usage}" ''
        gpg -r ${subkeyId}! $*
      '';
    in
    script;

  myGpgUtilOpts = with lib; {
    options.usage = mkOption { type = types.str; };
    options.keyCapacity = mkOption {
      type = types.enum [
        "sign"
        "enc"
        "auth"
      ];
    };
    options.subkeyId = mkOption { type = types.str; };
  };

  aliasScript = lib.lists.forEach config.my-gpg (
    conf: mkGPGScript "${conf.usage}" "${conf.keyCapacity}" "${conf.subkeyId}"
  );
in
with lib;
{
  options.my-gpg = mkOption {
    type = types.listOf (types.submodule myGpgUtilOpts);
    default = [ ];
  };
  config.home.packages = aliasScript;
  config.programs.zsh.initExtra = lib.mkAfter (
    lib.concatStrings (lib.lists.forEach aliasScript (script: "compdef ${script.name}=gpg\n"))
  );
}
