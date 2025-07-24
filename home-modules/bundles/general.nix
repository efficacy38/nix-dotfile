_: {
  nixpkgs = {
    config = {
      # allowUnfree = true;
      experimental-features = "nix-command flakes";
    };
  };

  myHomeManager = {
    bundles.minimal.enable = true;

    backup.enable = true;
    podman.enable = true;
    utils.enable = true;
    zsh.enable = true;
    k8s.enable = true;
  };

}
