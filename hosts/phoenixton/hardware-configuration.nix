# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "uas"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  environment.persistence."/persistent" = {
    enable = true; # NB: Defaults to true, not needed
    hideMounts = true;
    directories = [
      "/var/db/sudo"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/tailscale/"
      "/var/lib/sops-nix"
      "/etc/NetworkManager/system-connections"
      "/etc/ssh/"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.efficacy38 = {
      directories = [
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Nextcloud"
        "Videos"
        "Projects"
        "Postman"
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".nixops";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
        {
          directory = ".local/share/kwalletd";
          mode = "0700";
        }
        ".local/share/direnv"
        "Sync"
        "Zotero"
      ];
      files = [
        ".bash_history"
        ".zsh_history"
      ];
    };
  };

  boot.initrd.systemd = {
    enable = true;

    services.create-empty-btrfs-subvdir = {
      wantedBy = [ "initrd-root-device.target" ];
      after = [
        "sysroot.mount"
        "local-fs-pre.target"
      ];
      serviceConfig.Type = "oneshot";
      unitConfig.DefaultDependencies = false;
      script = ''
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
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/181a096d-2934-425f-ac9b-73095e8678fa";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/181a096d-2934-425f-ac9b-73095e8678fa";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/181a096d-2934-425f-ac9b-73095e8678fa";
    fsType = "btrfs";
    options = [ "subvol=@nix" ];
  };

  fileSystems."/persistent" = {
    device = "/dev/disk/by-uuid/181a096d-2934-425f-ac9b-73095e8678fa";
    fsType = "btrfs";
    options = [ "subvol=persistent" ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FAF5-A0F7";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/etc/ssh".neededForBoot = true;

  swapDevices = [
    {
      label = "swap";
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s0f4u1u3u2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
}
