{ config, lib, ... }:
{
  # Merge all nixosModules from modules/ into a single default module
  flake.nixosModules.default =
    { ... }:
    {
      imports = builtins.attrValues (lib.filterAttrs (n: _: n != "default") config.flake.nixosModules);
    };
}
