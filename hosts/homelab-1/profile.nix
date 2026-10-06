{
  my = {
    bundles.homelab.enable = true;
    users.efficacy38.extraHomeConfig = import ./home.nix;
    devpack = {
      enable = true;
      tailscale.enable = true;
      tailscaleAsRouter = true;
    };
  };
}
