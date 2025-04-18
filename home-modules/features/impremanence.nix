{ ... }:
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
        ".nixops"
        # TODO: tmporary add .local/share, we should add data when using some
        # application
        # ".local/share"
        ".local/share/rime"
        ".local/share/zsh"
        ".local/share/direnv"
        ".local/share/dolphin"
        ".local/share/fcitx5"
        ".local/share/fish"
        ".local/share/kate"
        ".local/share/k9s"
        ".local/share/mc"
        ".local/share/nvim"
        ".local/share/pnpm"
        ".local/share/podman"
        ".local/share/PrismLauncher"
        ".local/share/remmina"
        ".local/share/sddm"
        ".local/share/tldr"
        ".local/share/Trash"
        ".local/share/yarn"
        ".local/share/zoxide"
        ".local/share/zsh"
        ".local/state"

        ".config/Moonlight\ Game\ Streaming\ Project"
        ".config/rambox"
        ".config/solaar"
        ".krew"
        ".kube"
        ".mozilla"
        ".thunderbird"
        ".config/fcitx5"
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
        ".local/share/Steam"
        ".local/share/containers"
      ]);

    files = [
    ];
  };

  # NOTICE: workaround of nix impermanence
  # ref: https://github.com/nix-community/impermanence/issues/233
  programs.zsh.history.path = "$HOME/.local/share/zsh/.zsh_history";
}
