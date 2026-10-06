{
  my = {
    bundles.desktop = {
      enable = true;
      session = "hyprland";
      steam.enable = true;
    };
    desktop.sunshine.enable = true;
    users = {
      efficacy38 = {
        type = "desktop-user";
        extraHomeConfig = import ./home.nix;
      };
      gaming = {
        type = "minimal";
        extraHomeConfig = {
          home.stateVersion = "24.11";
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
