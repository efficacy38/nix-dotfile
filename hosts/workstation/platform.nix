{
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    # Include the default lxd configuration.
    "${modulesPath}/virtualisation/incus-virtual-machine.nix"
  ];

  boot.initrd.systemd.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
