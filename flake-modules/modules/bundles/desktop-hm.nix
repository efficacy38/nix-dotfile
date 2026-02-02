_: {
  flake.homeModules.bundles-desktop =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.bundles.desktop;
    in
    {
      options.my.bundles.desktop = {
        enable = lib.mkEnableOption "desktop bundle (minimal + hyprland, zen, nvim, ssh-tunnels)";
      };

      config = lib.mkIf cfg.enable {
        my = {
          bundles.minimal.enable = true;
          desktop = {
            enable = true;
            hyprland.enable = true;
            zen.enable = true;
            ssh-tunnels.enable = true;
          };
          devpack.nvim.enable = true;
        };
      };
    };
}
