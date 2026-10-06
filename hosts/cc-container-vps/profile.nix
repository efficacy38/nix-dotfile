{
  my = {
    users.efficacy38 = {
      type = "minimal";
      extraHomeConfig = import ./home.nix;
    };
    # system.impermanence.enable = true;
    devpack = {
      enable = true;
      podman.enable = true;
      # csccUtil.enable = true;
      tailscale.enable = true;
    };
  };
}
