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
      ".local/share"
      ".config/rambox"
      ".krew"
      ".kube"
      ".mozilla"
      "Projects"
      ".thunderbird"
      (symDirectory ".local/share/Steam")
    ];
    allowOther = true;
    files = [
      ".zsh_history"
    ];
  };
}
