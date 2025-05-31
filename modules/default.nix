{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./main-user.nix
    ./common-server-setting.nix
    ./my-steam.nix
    ./my-desktop.nix
    ./my-impremanence.nix
    ./my-tailscale.nix
    ./cscc-work.nix
    ./my-impremanence.nix
    ./kopia
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

    services.kopia = {
      enabled = true;
      instances = {
        s3 = {
          name = "default";
          enabled = true;
          repository = {
            s3.password = "default-password-value";
            s3.endpoint = "default-bar-value";
            s3.accessKey = "accessKey";
            s3.secretKey = "secretKey";
          };
        };
      };
    };
  };
}
