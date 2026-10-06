{
  my = {
    common-server.enable = true;
    users.efficacy38 = {
      type = "developing";
      isAdmin = true;
      extraHomeConfig = import ./home.nix;
    };
    devpack = {
      enable = true;
      podman.enable = true;
      csccUtil.enable = true;
      tailscale.enable = true;
    };
  };
}
