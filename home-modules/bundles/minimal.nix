_: {
  nixpkgs = {
    config = {
      # allowUnfree = true;
      experimental-features = "nix-command flakes";
    };
  };

  myHomeManager = {
    git.enable = true;
    gpg.enable = true;
    incus.enable = true;
    just.enable = true;
    tmux.enable = true;
    zsh.enable = true;
  };
}
