{ config, pkgs, ... }: {

  home.packages = with pkgs; [
    fzf
    fzf-zsh
  ];

  programs.zoxide = {
    enable = true;
    options = [
      "--cmd cd"
    ];
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    plugins = [
      { name = "zsh-completions"; src = pkgs.zsh-completions; }
      { name = "powerlevel10k"; src = pkgs.zsh-powerlevel10k; file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme"; }
    ];
    autosuggestion.enable = true;
    completionInit = ''
      autoload -U +X bashcompinit && bashcompinit
      autoload -U compinit && compinit
      source <(incus completion zsh)

      # kubectl
      command -v kubectl > /dev/null && source <(kubectl completion zsh)
      command -v flux > /dev/null && source <(flux completion zsh)
      command -v helm > /dev/null && source <(helm completion zsh)
    '';
    # default 10000, maybe 1000000 is good for me to use fzf :>
    history = {
      save = 1000000;
      size = 1000000;
    };
    syntaxHighlighting = {
      enable = true;
      # check highlighters https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
      highlighters = [
        "main"
        "brackets"
        "pattern"
        "regexp"
        "line"
      ];
    };
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins =
        [
          "git"
          "npm"
          "history"
          "node"
          "rust"
          "deno"
        ];
    };

    initExtra = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      # ------------------------ self defined unctions ----------------------------
      # function to create a new tmux session with the name of the current directory
      function tat {
          name=$(basename $(pwd) | sed -e 's/\.//g')
          if [ $(pwd) = $HOME ]; then
              name="default"
          fi


          if ! tmux ls 2>&1 | grep -E "^$name:"; then
              if [ -f .envrc ]; then
                  direnv exec / tmux new-session -s "$name" -d
              else
                  # start tmux at detached mode
                  tmux new-session -s "$name" -d
              fi
          fi

          if [ -z "$TMUX" ]; then
              tmux attach -t "$name" -c "$(pwd)"
          else
              tmux switch-client -t "$name"
          fi
      }

      # attach to lxd container with username 
      function goincus(){
          if [[ $# -eq 0 ]]; then
              echo "Usage: $0 <container or vm name> [namespace] [username]" >&2
              echo ""
              echo "attach to lxd container with uid 1000"
              echo "    namespace: default is current namespace"
              echo "    uid: default is 1000" >&2
              return 1;
          fi
          instance="$1"; shift;
          project="";
          uid="efficacy38";

          if [[ $# -gt 0 ]]; then
              project=$1; shift;
          fi

          if [[ $# -gt 0 ]]; then
              uid=$1; shift;
          fi

          if [[ -z "$project" ]]; then
              echo "\nenter the $instance at current project\n"
              incus exec $instance -- sudo -iu "$uid"
          else
              echo "\nenter the $instance at project $project\n"
              incus exec --project $project $instance -- sudo -iu "$uid"
          fi
      }

      # ssh-agent
      function add-ssh-key() {
      for key in ~/.ssh/id_ed25519 ~/.ssh/id_sysadm; do
          # add ssh-key to ssh-agent if not yet added into
        if [[ -f "$key" ]]; then
          ssh-add "$key"
        fi
      done
      }

      # $1: alias
      # $2: command
      function aliasIfExist(){
          command_base="$(echo $2 | cut -d' ' -f1)"
          if command -v "$command_base" >/dev/null; then
              alias $1=$2
          fi
      }

      function gen-new-sshkey() {
        ssh_keyname="$1"
        user="''${2:-ansible}"
        ssh-keygen -f "''${HOME}/.ssh/id_''${ssh_keyname}" -C "$user@$ssh-key-name"
      }

      # ---------------------------- alias section ---------------------------
      # short cut alias
      aliasIfExist cat bat
      aliasIfExist cat batcat
      aliasIfExist godev 'incus exec --project default dev -- sudo -iu '
      aliasIfExist bye 'sudo poweroff'
      aliasIfExist k kubectl
      aliasIfExist reboot 'sudo reboot'
      # alias cscc_work='sudo $HOME/.local/bin/cscc_work'
      aliasIfExist 'cdt' 'cd ~/Tmp'
      alias chproj='incus project switch'
      # aliasIfExist ssh "kitty +kitten ssh"

      if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
          aliasIfExist 'copy' 'wl-copy'
      else
          aliasIfExist 'copy' 'xclip -sel clip'
      fi

      # overriding alias
      aliasIfExist vim nvim
      aliasIfExist vi vim
      aliasIfExist docker-compose podman-compose
      aliasIfExist docker podman
      alias kreload='kquitapp5 plasmashell; plasmashell --replace &'
      export PATH=$HOME/.local/bin:$PATH:$HOME/.krew/bin
      alias s=systemctl

      source <(fzf --zsh)
    '';
  };

  home.file = {
    ".p10k.zsh" = {
      source = ../dotfiles/p10k.zsh;
    };
  };
}
