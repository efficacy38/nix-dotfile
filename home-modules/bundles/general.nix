{ ... }:
{
  nixpkgs = {
    config = {
      # allowUnfree = true;
      experimental-features = "nix-command flakes";
    };
  };

  myHomeManager.bundles.minimal.enable = true;
  myHomeManager.backup.enable = true;
  myHomeManager.podman.enable = true;
  myHomeManager.utils.enable = true;
  myHomeManager.zsh.enable = true;
  myHomeManager.k8s.enable = true;
}
