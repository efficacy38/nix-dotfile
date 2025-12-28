# Boot system configurations: systemd-initrd, impermanence
_:
{
  # NixOS: systemd-initrd configuration
  flake.nixosModules.system-initrd =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.system;
    in
    {
      options.my.system.systemdInitrd.enable = lib.mkEnableOption "systemd-initrd";
      options.my.system.systemdInitrd.debug = lib.mkEnableOption "debug mode for systemd-initrd";

      config = lib.mkIf cfg.systemdInitrd.enable {
        boot.initrd.systemd = {
          enable = true;
          emergencyAccess = cfg.systemdInitrd.debug;
        };
      };
    };

  # NixOS: impermanence configuration
  flake.nixosModules.system-impermanence =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.system;
    in
    {
      options.my.system.impermanence.enable = lib.mkEnableOption "impermanence (btrfs snapshot rollback)";

      config =
        let
          common-impermanence = {
            environment.persistence."/persistent/system" = {
              enable = true;
              hideMounts = true;
              directories = [
                "/etc/NetworkManager/system-connections"
                "/etc/ssh/"
                "/etc/nixos"
                "/etc/wireguard/"
                "/var/db/sudo"
                "/var/log"
                "/var/lib/bluetooth"
                "/var/lib/fail2ban"
                "/var/lib/fprint"
                "/var/lib/nixos"
                "/var/lib/power-profiles-daemon"
                "/var/lib/sddm"
                "/var/lib/systemd/coredump"
                "/var/lib/tailscale/"
                "/var/lib/sops-nix"
              ];
              files = [
                "/etc/machine-id"
              ];

              users."efficacy38" = {
                directories = [
                  # User projects (explicitly kept per user request)
                  "Projects"

                  # System security
                  ".gnupg"
                  ".ssh"
                  ".nixops"

                  # Input methods (system-level configuration)
                  ".config/fcitx5"
                  ".local/share/fcitx5"
                  ".local/share/rime"

                  # Virtualization (no dedicated home-manager module)
                  ".config/incus"

                  # System state and keyrings
                  ".local/state"
                  ".local/share/keyring"

                  # Shell history and data
                  ".local/share/zsh"
                  ".local/share/fish"
                ];
              };
            };

            fileSystems."/etc/ssh".neededForBoot = true;
            programs.fuse.userAllowOther = true;

            systemd.tmpfiles.rules = [
              "d /mnt 0770 root root -"
            ];
          };

          reset-btrfs-impermanance-script = ''
            mkdir /btrfs_tmp
            mount /dev/disk/by-label/root /btrfs_tmp
            if [[ -e /btrfs_tmp/@ ]]; then
                mkdir -p /btrfs_tmp/old_roots
                timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/@)" "+%Y-%m-%-d_%H:%M:%S")
                mv /btrfs_tmp/@ "/btrfs_tmp/old_roots/$timestamp"
            fi

            delete_subvolume_recursively() {
                IFS=$'\n'
                for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                    delete_subvolume_recursively "/btrfs_tmp/$i"
                done
                btrfs subvolume delete "$1"
            }

            for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
                delete_subvolume_recursively "$i"
            done

            btrfs subvolume create /btrfs_tmp/@
            umount /btrfs_tmp
          '';

          udev-initrd = {
            boot.initrd.postDeviceCommands = lib.mkAfter reset-btrfs-impermanance-script;
          };

          systemd-initrd = {
            boot.initrd.systemd.services."rootfs-cleanup" = {
              wantedBy = [ "initrd.target" ];
              after = [ "initrd-root-device.target" ];
              before = [ "sysroot.mount" ];
              unitConfig.DefaultDependencies = "no";
              serviceConfig.Type = "oneshot";
              script = reset-btrfs-impermanance-script;
            };
          };
        in
        lib.mkIf cfg.impermanence.enable (
          lib.mkMerge [
            common-impermanence
            (lib.mkIf (!cfg.systemdInitrd.enable) udev-initrd)
            (lib.mkIf cfg.systemdInitrd.enable systemd-initrd)
          ]
        );
    };
}
