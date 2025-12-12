{ config, lib, ... }:
{
  # Merge all homeModules into a single default module (dendritic pattern)
  flake.homeModules.default = { ... }: {
    imports = builtins.attrValues (
      lib.filterAttrs (n: _: n != "default") config.flake.homeModules
    );
  };
}
