{
  lib,
  config,
  ...
}:
let
  instanceOption = {
    enable = lib.mkEnableOption "Enable Kopia instance";
    name = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = "Name of the Kopia instance.";
    };
  };

  mkRepositoryArgs =
    instance:
    let
      repotype = builtins.head (builtins.attrNames instance.repository);
      repoconf = instance.repository.${repotype};
      shellAddFlag =
        flag: value: cmd:
        if value == null then cmd else "${cmd} ${flag}=${value}";
      shellWrapSecret =
        secret: flag: env: cmd:
        if secret == null then
          cmd
        else if builtins.isString secret then
          "${cmd} ${flag}=${secret}"
        else
          "${env}=$(cat ${secret.file}) ${cmd}";

      genericBuilders = conf: [
        (shellWrapSecret conf.password "--password" "KOPIA_PASSWORD")
      ];
      s3Builders = conf: [
        (shellAddFlag "--bucket" conf.bucket)
        (shellAddFlag "--endpoint" conf.endpoint)
        (shellWrapSecret conf.access-key "--access-key" "AWS_ACCESS_KEY_ID")
        (shellWrapSecret conf.secret-access-key "--secret-access-key" "AWS_SECRET_ACCESS_KEY")
        (shellWrapSecret conf.session-token "--session-token" "AWS_SESSION_TOKEN")
      ];
      builderDispatch = {
        s3 = s3Builders;
      };
      specificBuilder = builderDispatch.${repotype};
      genericCmd = builtins.foldl' (acc: builder: builder acc) "" genericBuilders;
      specificCmd = builtins.foldl' (acc: builder: builder acc) genericCmd specificBuilder repoconf;
    in
    specificCmd;

  mkInstanceRepositoryScript = instance: {
    description = "Kopia repository setup";
    before = [ "kopia-${instance.name}.service" ];
    requiredBy = [ "kopia-${instance.name}.service" ];
    script = ''
      if ! ${instance.package}/bin/kopia repository connect ${mkRepositoryArgs instance}
        ${instance.package}/bin/kopia repository create ${mkRepositoryArgs instance}
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = instance.user;
      Group = instance.group;
      RemainAfterExit = true;
      StateDirectory = "kopia/${instance.name}";
      StateDirectoryMode = "0700";
    };
  };

  mkInstanceServices = instance: {
    "kopia-${instance.name}-repository" = mkInstanceRepositoryScript instance;
  };
in
{
  options = {
    instances = lib.types.attrsOf (lib.types.submodule instanceOption);
  };

  config = {
    systemd.servvices = mkInstanceServices config.service.kopia.instances;
  };
}
