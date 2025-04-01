{ ... }:
let
  symDirectory = dir: {
    directory = dir;
    method = "symlink";
  };
in
{
  home.persistence."/persistent/home/efficacy38" = {
    directories = [
      "Downloads"
      "Music"
      "Pictures"
      "Documents"
      "Videos"
      "Sync"
      "Postman"
      ".gnupg"
      ".ssh"
      ".nixops"
      # TODO: tmporary add .local/share, we should add data when using some
      # application
      ".local/share"
      # ".local/share/rime"
      # ".local/share/zsh"
      ".config/Moonlight\ Game\ Streaming\ Project"
      ".local/state"
      ".config/rambox"
      ".config/solaar"
      ".krew"
      ".kube"
      ".mozilla"
      "Projects"
      ".thunderbird"
      (symDirectory ".local/share/Steam")
    ];
    allowOther = true;

    files = [
    ];
  };

  # NOTICE: workaround of nix impermanence
  # ref: https://github.com/nix-community/impermanence/issues/233
  programs.zsh.history.path = "$HOME/.local/share/zsh/.zsh_history";
}
