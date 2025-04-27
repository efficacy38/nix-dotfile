{ ... }:
{
  nixpkgs = {
    config = {
      # allowUnfree = true;
      experimental-features = "nix-command flakes";
    };
  };

  myHomeManager.git.enable = true;
  myHomeManager.gpg.enable = true;
  myHomeManager.incus.enable = true;
  myHomeManager.just.enable = true;
  myHomeManager.tmux.enable = true;
  myHomeManager.zsh.enable = true;
}
