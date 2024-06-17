{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    podman
    podman-compose
  ];

  home.file.".config/containers/registries.conf".text = ''
    [registries.search]
    registries = ['docker.io', 'quay.io', "gcr.io"]
  '';
  # etc."containers/policy.json".text = import ./etc/containers/policy.nix { };
}
