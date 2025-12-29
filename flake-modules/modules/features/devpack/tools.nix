# Dev tools: gpg, just, k8s, podman, utils
_: {
  # NixOS: Kubernetes tools persistence
  flake.nixosModules.devpack-k8s =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.devpack;
    in
    {
      config = lib.mkIf cfg.enable {
        # Persist Kubernetes tools data
        environment.persistence."/persistent/system".users."efficacy38" = {
          directories = [
            ".krew"
            ".kube"
            ".local/share/k9s"
            ".mc"
            ".local/share/mc"
          ];
        };
      };
    };

  # NixOS: podman persistence
  flake.nixosModules.devpack-podman =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.devpack;
    in
    {
      config = lib.mkIf cfg.enable {
        # Persist container data
        environment.persistence."/persistent/system".users."efficacy38" = {
          directories = [
            ".local/share/containers" # Container storage
            ".local/share/podman" # Podman data
          ];
        };
      };
    };

  # NixOS: dev utilities persistence
  flake.nixosModules.devpack-utils =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.devpack;
    in
    {
      config = lib.mkIf cfg.enable {
        # Persist AI/LLM tools and development utilities settings and data
        environment.persistence."/persistent/system".users."efficacy38" = {
          directories = [
            # AI/LLM Tools
            # Claude Code
            ".claude"
            ".local/share/claude"
            ".cache/claude"

            # Gemini CLI
            ".config/gemini"
            ".local/share/gemini"
            ".cache/gemini"

            # OpenSpec
            ".config/openspec"
            ".local/share/openspec"
            ".cache/openspec"

            # GitHub Copilot CLI
            ".config/copilot-cli"
            ".local/share/copilot-cli"
            ".cache/copilot-cli"

            # GitHub Copilot (VSCode/Editor)
            ".config/github-copilot"

            # Codex
            ".config/codex"
            ".local/share/codex"
            ".cache/codex"

            # Antigravity
            ".config/antigravity"
            ".local/share/antigravity"
            ".cache/antigravity"

            # Development Tools
            # direnv
            ".local/share/direnv"

            # zoxide
            ".local/share/zoxide"

            # lazygit
            ".config/lazygit"
            ".local/share/lazygit"

            # tldr command documentation
            ".local/share/tldr"
          ];
        };
      };
    };

  flake.homeModules = {
    # Home-manager: GPG configuration
    devpack-gpg =
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
        config = lib.mkIf (cfg.enable && cfg.gpg.enable) {
          home.packages = [ pkgs.yubikey-manager ] ++ aliasScript;
          programs.zsh.initContent = lib.mkAfter (
            lib.concatStrings (lib.lists.forEach aliasScript (script: "compdef ${script.name}=gpg\n"))
          );
        };
      };

    # Home-manager: just command runner
    devpack-just =
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
        config = lib.mkIf (cfg.enable && cfg.just.enable) {
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
    devpack-k8s =
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
        config = lib.mkIf (cfg.enable && cfg.k8s.enable) {
          programs.kubecolor = {
            enable = true;
            enableZshIntegration = true;
          };

          home.packages = with pkgs; [
            calicoctl
            fluxcd
            gdk
            jq
            k9s
            krew
            kube-capacity
            kube-linter
            kube-prompt
            kubelogin
            kubectl
            kubectl-doctor
            kubectl-images
            kubectl-neat
            kubectl-tree
            kubectl-validate
            kubectx
            kubepug
            kubernetes-helm
            kubeshark
            kustomize
            kyverno
            minio-client
            opentofu
            yq
          ];
        };
      };

    # Home-manager: podman container tools
    devpack-podman =
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
        config =
          lib.mkIf (cfg.enable && cfg.podman.enable) {
            home.packages = with pkgs; [ podman-compose ];

            services.podman = {
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

          }
          // lib.mkIf (cfg.enable) {
            home.file = {
              ".claude/skills" = {
                source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/nix-dotfile/dotfiles/claude/skills/";
              };
              ".claude/settings.json" = {
                source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/nix-dotfile/dotfiles/claude/settings.json";
              };
            };
          };
      };

    # Home-manager: utility packages
    devpack-utils =
      {
        inputs,
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
        config = lib.mkIf (cfg.enable && cfg.utils.enable) {
          home.packages =
            with pkgs-unstable;
            [
              ansible
              boxes
              cachix
              cfssl
              claude-monitor
              ctags
              curl
              dnsutils
              entr
              flatpak
              mosh
              nixos-shell
              openssl
              pkgs.personal-script
              ripgrep
              statix
              wl-clipboard
              wget
            ]
            ++ (with inputs.llm-agents.packages."${pkgs.system}"; [
              antigravity
              claude-code
              codex
              copilot-cli
              gemini-cli
              openspec
            ]);

          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
            enableZshIntegration = true;
          };

          programs.emacs.enable = true;
        };
      };
  };
}
