{
  lib,
  config,
  ...
}:
let
  cfg = config.my-impermanence;
in
{
  options.my-impermanence = {
    enable = lib.mkEnableOption "enable impermanence";
  };

  config = lib.mkIf cfg.enable {

    boot.initrd.postDeviceCommands = lib.mkAfter ''
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

    environment.persistence."/persistent/system" = {
      enable = true; # NB: Defaults to true, not needed
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

          ".config/Moonlight\ Game\ Streaming\ Project"
          ".config/fcitx5"
          ".config/rambox"
          ".config/solaar"

          ".local/share/fcitx5"
          ".local/share/zoxide"
          ".local/share/zsh"
          ".local/state"
          ".local/share/PrismLauncher"
          ".local/share/Steam"
          ".local/share/Trash"
          ".local/share/containers"
          ".local/share/direnv"
          ".local/share/dolphin"
          ".local/share/fish"
          ".local/share/kate"
          ".local/share/k9s"
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
        ];
      };
    };

    fileSystems."/etc/ssh".neededForBoot = true;

    # make sure impermanence homemanager module can let root or other use
    # access home directories
    programs.fuse.userAllowOther = true;

    systemd.tmpfiles.rules = [
      "d /mnt 0770 root root -"
    ];
  };
}
