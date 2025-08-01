{ pkgs, ... }:
let
  gdk = pkgs.google-cloud-sdk.withExtraComponents (
    with pkgs.google-cloud-sdk.components;
    [
      gke-gcloud-auth-plugin
    ]
  );
in
{

  programs = {
    kubecolor = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  home.packages = with pkgs; [
    kubectl
    fluxcd
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
    calicoctl

    # google cloud
    gdk
    opentofu
  ];
}
