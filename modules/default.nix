{ lib, config, pkgs, ... }:
{
  imports = [
    ./main-user.nix
    ./common-server-setting.nix
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

    # this is for nix-helper(nh)
    environment.sessionVariables = {
      # TODO: use main user module to control this
      FLAKE = "/home/efficacy38/Projects/Personal/nix-dotfile";
    };

    environment.systemPackages = with pkgs; [
      nh
      nix-output-monitor
      nvd
    ];
  };
}
