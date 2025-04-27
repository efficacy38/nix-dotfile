{ lib, ... }:
let
  symDirectory = dir: {
    directory = dir;
    method = "symlink";
  };
in
{
  home.persistence."/persistent/home/efficacy38" = {
    allowOther = true;

    directories =
      [
        "Postman"
        ".gnupg"
        ".ssh"
        ".mozilla"
        ".nixops"
        ".local/state"

        ".config/Moonlight\ Game\ Streaming\ Project"
        ".config/rambox"
        ".config/solaar"

        ".local/share/fcitx5"
        ".local/share/zoxide"
        ".local/share/zsh"
      ]
      ++ (map symDirectory [
        "Music"
        "Downloads"
        "Pictures"
        "Projects"
        "Documents"
        "Videos"
        "Sync"
        "Zotero"

        ".config/fcitx5"
        ".krew"
        ".kube"

        ".local/share/PrismLauncher"
        ".local/share/Steam"
        ".local/share/Trash"
        ".local/share/containers"
        ".local/share/direnv"
        ".local/share/dolphin"
        ".local/share/fish"
        ".local/share/kate"
        ".local/share/k9s"
        ".local/share/mc"
        ".local/share/nvim"
        ".local/share/pnpm"
        ".local/share/podman"
        ".local/share/sddm"
        ".local/share/tldr"
        ".local/share/rime"
        ".local/share/remmina"
        ".local/share/yarn"
        ".mc"
        ".thunderbird"
      ]);

    files = [
    ];
  };

  home.activation.fixPathForImpermanence = lib.hm.dag.entryBefore [ "cleanEmptyLinkTargets" ] ''
    PATH=$PATH:/run/wrappers/bin
  '';

  # NOTICE: workaround of nix impermanence
  # ref: https://github.com/nix-community/impermanence/issues/233
  programs.zsh.history.path = "$HOME/.local/share/zsh/.zsh_history";
}
