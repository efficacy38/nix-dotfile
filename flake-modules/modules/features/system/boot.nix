# Boot system configurations: systemd-initrd, impermanence
_: {
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
      pkgs,
      ...
    }:
    let
      cfg = config.my.system;
    in
    {
      options.my.system.impermanence.enable = lib.mkEnableOption "impermanence (btrfs snapshot rollback)";

      config =
        let
          impermanenceAudit = pkgs.writeShellApplication {
            name = "impermanence-audit";
            runtimeInputs = with pkgs; [
              coreutils
              findutils
              glibc.bin
              jq
            ];
            text = ''
              exec ${pkgs.bash}/bin/bash ${../../../../overlays/personal-scripts/impermanence_audit.sh} "$@"
            '';
          };

          common-impermanence = {
            # Mount /etc/ssh early in initrd for sops-nix decryption
            fileSystems."/etc/ssh" = {
              device = "/persistent/system/etc/ssh";
              fsType = "none";
              options = [ "bind" ];
              neededForBoot = true;
            };

            environment.persistence."/persistent/system" = {
              enable = true;
              hideMounts = true;
              directories = [
                "/etc/NetworkManager/system-connections"
                # /etc/ssh is mounted via fileSystems with neededForBoot for sops-nix
                "/etc/nixos"
                "/etc/wireguard/"
                "/var/db/sudo"
                "/var/log"
                "/var/lib/bluetooth"
                "/var/lib/docker"
                "/var/lib/fail2ban"
                "/var/lib/fprint"
                "/var/lib/fwupd"
                "/var/lib/NetworkManager"
                "/var/lib/nixos"
                "/var/lib/power-profiles-daemon"
                "/var/lib/sddm"
                "/var/lib/systemd/coredump"
                "/var/lib/tailscale/"
                "/var/lib/sops-nix"

                # workaround of systemd can't boot without /usr folder
                "/usr/systemd-placeholder"
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
                  ".config/syncthing"
                  ".local/state"
                  ".local/share/keyrings"

                  # Shell history and data
                  ".local/share/zsh"
                  ".local/share/fish"
                ];
              };
            };

            programs.fuse.userAllowOther = true;

            environment.systemPackages = [
              impermanenceAudit
            ];

            systemd.services.impermanence-audit-shutdown = {
              description = "Audit impermanence before shutdown";
              wantedBy = [ "shutdown.target" ];
              before = [ "shutdown.target" ];
              after = [ "local-fs.target" ];
              unitConfig.DefaultDependencies = "no";
              path = with pkgs; [
                coreutils
                jq
              ];
              serviceConfig = {
                Type = "oneshot";
                TimeoutStartSec = "60s";
              };
              script = ''
                set -u

                output_dir=/persistent/system/var/log/impermanence-audit
                timestamp="$(date -u '+%Y%m%dT%H%M%SZ')"
                tmp_file="$output_dir/.shutdown-$timestamp.tmp"
                report_file="$output_dir/shutdown-$timestamp.json"
                latest_file="$output_dir/shutdown-latest.json"

                mkdir -p "$output_dir"

                if ${impermanenceAudit}/bin/impermanence-audit \
                  efficacy38 \
                  > "$tmp_file"; then
                  :
                else
                  status=$?
                  jq -n \
                    --arg hostname ${lib.escapeShellArg config.networking.hostName} \
                    --arg user efficacy38 \
                    --arg error "impermanence-audit exited with status $status" \
                    '{
                      hostname: $hostname,
                      system: [],
                      users: {($user): []},
                      total: 0,
                      error: $error
                    }' > "$tmp_file"
                fi

                cp "$tmp_file" "$report_file"
                cp "$tmp_file" "$latest_file"
                rm -f "$tmp_file"
              '';
            };

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
