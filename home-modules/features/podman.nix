{
  ...
}:
{
  services.podman = {
    enable = true;
    settings = {
      policy = {
        "default" = [
          { "type" = "insecureAcceptAnything"; }
        ];
      };

      registries = {
        search = [
          "docker.io"
          "quay.io"
          "gcr.io"
        ];
      };
    };
  };
}
