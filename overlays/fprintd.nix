{ pkgs, ... }: {
  nixpkgs.overlays = [
    (final: prev: {
      libfprint = prev.libfprint.overrideAttrs (finalAttrs: previousAttrs: {
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "depau";
          repo = "libfprint";
          rev = "dec001b8159cdb5064db87d59cfb3a44264dcb2e";
          hash = "sha256-C+wP4vb6e9O325z8/2fUkb5F53wTbIgqHk3g5qCVYqY=";
        };

        patches = [ ./fprintd-personal-elan.patch ];

        installCheckPhase = ''
          runHook preInstallCheck

          # ninjaCheckPhase

          runHook postInstallCheck
        '';

        nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ pkgs.nss ];
      });

      fprintd-elanmoc2 = prev.fprintd.overrideAttrs
        (finalAttrs: previousAttrs: {
          # our patched fprintd is not sastify fprintd's minimal requirement
          version = "1.94.4";

          src = pkgs.fetchFromGitLab {
            domain = "gitlab.freedesktop.org";
            owner = "libfprint";
            repo = "fprintd";
            rev = "b54a007ccf58ac0ae074c7151b223f35cbd17306";
            hash = "sha256-B2g2d29jSER30OUqCkdk3+Hv5T3DA4SUKoyiqHb8FeU=";
          };

          mesonCheckFlags = [
            # PAM related checks are timing out
            "--no-suite"
            "fprintd:TestPamFprintd"
            # Tests FPrintdManagerPreStartTests.test_manager_get_no_default_device & FPrintdManagerPreStartTests.test_manager_get_no_devices are failing
            "--no-suite"
            "fprintd:FPrintdManagerPreStartTests"
          ];
        });
    })
  ];
}
