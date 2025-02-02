{...}: {
  nixpkgs = {
    config = {
      # allowUnfree = true;
      experimental-features = "nix-command flakes";
    };
  };

  myHomeManager.backup.enable = true;
  myHomeManager.git.enable = true;
  myHomeManager.gpg.enable = true;
  myHomeManager.incus.enable = true;
  myHomeManager.just.enable = true;
  myHomeManager.k8s.enable = true;
  myHomeManager.nvim.enable = true;
  myHomeManager.podman.enable = true;
  myHomeManager.tmux.enable = true;
  myHomeManager.utils.enable = true;
  myHomeManager.zsh.enable = true;
}
