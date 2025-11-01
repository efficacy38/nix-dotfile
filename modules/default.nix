{ inputs, lib, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./features/backup.nix
    ./features/main-user.nix
    ./features/common.nix
    ./features/steam.nix
    ./features/desktop.nix
    ./features/impremanence.nix
    ./features/tailscale.nix
    ./features/cscc-work.nix
    ./features/impremanence.nix
    ./features/fprintd.nix

    ./bundles/common.nix
    ./bundles/steam.nix
    ./bundles/desktop-hyprland.nix
    ./bundles/desktop-kde.nix
  ];

  options = {
    # Option declarations.
    # Declare what settings a user of this module can set.
    # Usually this includes a global "enable" option which defaults to false.
  };

  config = {
    # Option definitions.
    # Define what other settings, services and resources should be active.
    # Usually these depend on whether a user of this module chose to "enable" it
    # using the "option" above.
    # Options for modules imported in "imports" can be set here.

    myNixOS.common.enable = true;
  };
}
