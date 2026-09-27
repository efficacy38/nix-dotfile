# Dotfiles source mode: out-of-store symlinks vs in-store copies
#
# Default ("out-of-store") symlinks into /etc/nixos/nix-dotfile/dotfiles so
# edits are effective immediately. In containers (e.g. stella-nspawn) that
# path does not exist, so hosts can flip `my.dotfiles.inStore = true` to
# copy dotfiles into the nix store instead -- self-contained and
# deterministic, at the cost of needing a switch after edits.
_: {
  flake.nixosModules.dotfiles =
    { lib, config, ... }:
    {
      options.my.dotfiles.inStore = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Copy dotfiles into the nix store instead of symlinking
          /etc/nixos/nix-dotfile/dotfiles. Enable on hosts that do not
          have the config repo mounted (e.g. nspawn containers).
        '';
      };

      # Mirror the value into every user's home-manager context (my.* options
      # are independent option trees on the NixOS and home-manager sides).
      config.home-manager.sharedModules = lib.mkIf config.my.dotfiles.inStore [
        { my.dotfiles.inStore = true; }
      ];
    };

  flake.homeModules.dotfiles = { lib, ... }: {
    options.my.dotfiles.inStore = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Copy dotfiles into the nix store instead of symlinking
        /etc/nixos/nix-dotfile/dotfiles. Enable on hosts that do not
        have the config repo mounted (e.g. nspawn containers).
      '';
    };
  };
}
