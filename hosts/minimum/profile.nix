{
  my = {
    users.efficacy38 = {
      type = "minimal";
      extraHomeConfig = import ./home.nix;
    };
    # system.impermanence.enable = true;
  };
}
