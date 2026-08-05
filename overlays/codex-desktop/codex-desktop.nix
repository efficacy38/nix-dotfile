{ inputs, ... }:
{
  nixpkgs.overlays = [
    (_final: prev: {
      codex-desktop = inputs.codex-desktop-linux.packages.${prev.stdenv.hostPlatform.system}.default;
    })
  ];
}
