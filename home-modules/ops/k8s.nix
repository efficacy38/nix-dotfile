{ config, pkgs, ... }: {
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
  ];
}
