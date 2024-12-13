{ config, pkgs, ... }:
let
  gdk = pkgs.google-cloud-sdk.withExtraComponents (with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);
in
{
  home.packages = with pkgs; [
    fluxcd
    kubectl
    kubernetes-helm
    kustomize
    jq
    yq
    k9s
    krew
    kubectx
    kubepug
    kubelogin
    kubeshark
    kube-linter
    kubectl-tree
    kubectl-neat
    kube-capacity
    kubectl-images
    kubectl-doctor
    kubectl-validate
    kube-prompt
    kyverno

    # google cloud
    gdk
    opentofu
  ];
}
