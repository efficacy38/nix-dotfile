{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    podman
    podman-compose
  ];

  home.file.".config/containers/registries.conf".text = ''
    [registries.search]
    registries = ['docker.io', 'quay.io', "gcr.io"]

    # use cscc mirror when available
    [[registry]]
      prefix = "docker.io"
      location = "registry-1.docker.io"

      [[registry.mirror]]
        location = "docker.cccr.test.cc.cs.nctu.edu.tw"
  '';
}
