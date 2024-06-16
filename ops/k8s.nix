{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    fluxcd
    kubectl
    kubernetes-helm
    kustomize
    jq
    yq
    k9s
  ];
}
