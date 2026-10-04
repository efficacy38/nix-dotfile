{
  my = {
    bundles.common.enable = true;
    users = {
      efficacy38 = {
        type = "desktop-user";
        extraHomeConfig = {
          home.stateVersion = "24.11";
          my = {
            bundles.desktop.enable = true;
            bundles.general.enable = true;
            desktop.flowsurface.enable = true;
          };
        };
      };
    };
    devpack = {
      enable = true;
      podman.enable = true;
      csccUtil.enable = true;
      tailscale.enable = true;
    };
  };
}
