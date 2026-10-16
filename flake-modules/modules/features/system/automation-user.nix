_: {
  flake.nixosModules.system-automation-user =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.my.system.automation-user;

      # Central key list, shared by every host that enables the module.
      # Embedded here so hosts don't repeat it; overridable per host.
      defaultOpensshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINhlNaB+bsYV5T5toQ6LCreJH4DDrZX50aWQctkAvA9P efficacy38@stella"
      ];
    in
    {
      options.my.system.automation-user = {
        enable = lib.mkEnableOption "automation user (SSH-key login + passwordless sudo)";

        username = lib.mkOption {
          type = lib.types.str;
          default = "automation";
          description = "Name of the automation account.";
        };

        opensshKeys = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = defaultOpensshKeys;
          description = "SSH public keys authorized to log in as the automation user.";
        };
      };

      config = lib.mkIf cfg.enable {
        # Keep the account declarative even if my.users is unused on a host.
        users.mutableUsers = lib.mkDefault false;

        users.users.${cfg.username} = {
          isNormalUser = true;
          description = "Automation account";
          shell = pkgs.bash;
          extraGroups = [ "wheel" ];
          # No password: SSH-key-only login ("!" locks the shadow entry).
          hashedPassword = "!";
          openssh.authorizedKeys.keys = cfg.opensshKeys;
        };

        security.sudo = {
          enable = true;
          extraRules = [
            {
              users = [ cfg.username ];
              commands = [
                {
                  command = "ALL";
                  options = [ "NOPASSWD" ];
                }
              ];
            }
          ];
        };
      };
    };
}
