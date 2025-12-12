# Boot system configurations: systemd-initrd, impermanence
{ ... }:
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
      options.my.system.systemdInitrdEnable = lib.mkEnableOption "systemd-initrd";
      options.my.system.systemdInitrdDebug = lib.mkEnableOption "debug mode for systemd-initrd";

      config = lib.mkIf cfg.systemdInitrdEnable {
        boot.initrd.systemd = {
          enable = true;
          emergencyAccess = cfg.systemdInitrdDebug;
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
      options.my.system.impermanenceEnable = lib.mkEnableOption "impermanence (btrfs snapshot rollback)";

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
                  "Music"
                  "Downloads"
                  "Pictures"
                  "Projects"
                  "Documents"
                  "Videos"
                  "Sync"
                  "Zotero"
                  "Postman"
                  ".gnupg"
                  ".ssh"
                  ".zen"
                  ".nixops"
                  ".krew"
                  ".kube"

                  ".config/Moonlight\\ Game\\ Streaming\\ Project"
                  ".config/superProductivity"
                  ".config/incus"
                  ".config/keepassxc"
                  ".config/lazygit"
                  ".config/fcitx5"
                  ".config/solaar"
                  ".config/github-copilot"

                  ".local/state"
                  ".local/share/fcitx5"
                  ".local/share/keyring"
                  ".local/share/zoxide"
                  ".local/share/zsh"
                  ".local/share/PrismLauncher"
                  ".local/share/Steam"
                  ".local/share/Trash"
                  ".local/share/containers"
                  ".local/share/direnv"
                  ".local/share/dolphin"
                  ".local/share/fish"
                  ".local/share/kate"
                  ".local/share/k9s"
                  ".local/share/lazygit"
                  ".local/share/mc"
                  ".local/share/nvim"
                  ".local/share/pnpm"
                  ".local/share/podman"
                  ".local/share/sddm"
                  ".local/share/tldr"
                  ".local/share/rime"
                  ".local/share/remmina"
                  ".local/share/yarn"
                  ".mc"
                  ".thunderbird"

                  ".cache/keepassxc"
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
        lib.mkIf cfg.impermanenceEnable (
          lib.mkMerge [
            common-impermanence
            (lib.mkIf (!cfg.systemdInitrdEnable) udev-initrd)
            (lib.mkIf cfg.systemdInitrdEnable systemd-initrd)
          ]
        );
    };
}
