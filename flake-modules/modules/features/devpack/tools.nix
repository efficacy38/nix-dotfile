# Dev tools: gpg, just, k8s, podman, utils
{ ... }:
{
  # Home-manager: GPG configuration
  flake.homeModules.devpack-gpg =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.devpack;
      my-gpg = [
        {
          usage = "personal";
          keyCapacity = "enc";
          subkeyId = "1722121F0FB35C6CDA7ABF9E680078CD836172D6";
        }
        {
          usage = "personal";
          keyCapacity = "sign";
          subkeyId = "5EAB3A07B1B5078585C1C5E938DFF1897150C309";
        }
        {
          usage = "personal";
          keyCapacity = "auth";
          subkeyId = "7964380B1866F94F09FBEE68F66D16FB0A1D33BB";
        }
      ];
      mkGPGScript =
        usage: keyCapacity: subkeyId:
        pkgs.writeShellScriptBin "gpg-${keyCapacity}-${usage}" ''
          gpg -r ${subkeyId}! $*
        '';

      aliasScript = lib.lists.forEach my-gpg (
        conf: mkGPGScript "${conf.usage}" "${conf.keyCapacity}" "${conf.subkeyId}"
      );
    in
    {
      config = lib.mkIf (cfg.enable && cfg.gpgEnable) {
        home.packages = [ pkgs.yubikey-manager ] ++ aliasScript;
        programs.zsh.initContent = lib.mkAfter (
          lib.concatStrings (lib.lists.forEach aliasScript (script: "compdef ${script.name}=gpg\n"))
        );
      };
    };

  # Home-manager: just command runner
  flake.homeModules.devpack-just =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.devpack;
    in
    {
      config = lib.mkIf (cfg.enable && cfg.justEnable) {
        home.file.".config/just/justfile".text = ''
          list:
            just -gl
          test:
            nh os test
          deploy:
            nh os switch
          update:
            nix flake update
          history:
            nix profile history --profile /nix/var/nix/profiles/system
        '';

        home.packages = with pkgs; [ just ];

        programs.zsh.shellAliases = {
          j = "just -g";
        };

        programs.zsh.initContent = ''
          source <(just --completions zsh)
        '';
      };
    };

  # Home-manager: Kubernetes tools
  flake.homeModules.devpack-k8s =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.devpack;
      gdk = pkgs.google-cloud-sdk.withExtraComponents (
        with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]
      );
    in
    {
      config = lib.mkIf (cfg.enable && cfg.k8sEnable) {
        programs.kubecolor = {
          enable = true;
          enableZshIntegration = true;
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
          gdk
          opentofu
        ];
      };
    };

  # Home-manager: podman container tools
  flake.homeModules.devpack-podman =
    {
      options,
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.devpack;
    in
    {
      config = lib.mkIf (cfg.enable && cfg.podmanEnable) {
        home.packages = with pkgs; [ podman-compose ];
        services.podman =
          {
            enable = true;
          }
          // lib.optionalAttrs (builtins.hasAttr "settings" options.services.podman) {
            settings = {
              policy = {
                "default" = [ { "type" = "insecureAcceptAnything"; } ];
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
      };
    };

  # Home-manager: utility packages
  flake.homeModules.devpack-utils =
    {
      pkgs,
      pkgs-unstable,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.devpack;
    in
    {
      config = lib.mkIf (cfg.enable && cfg.utilsEnable) {
        home.packages = with pkgs-unstable; [
          curl
          wget
          ripgrep
          boxes
          ctags
          flatpak
          openssl
          cfssl
          dnsutils
          ansible
          mosh
          gemini-cli
          claude-code
          claude-monitor

          wl-clipboard
          cachix
          statix
          entr

          pkgs.personal-script
          nixos-shell
        ];

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
          enableZshIntegration = true;
        };

        programs.emacs.enable = true;
      };
    };
}
