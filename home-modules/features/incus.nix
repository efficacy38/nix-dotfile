{ pkgs, ... }:
{
  # only use incus cli
  home.packages = with pkgs; [
    incus
    virt-viewer
  ];
}
