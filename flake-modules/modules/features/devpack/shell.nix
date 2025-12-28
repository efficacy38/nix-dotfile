# Shell tools: zsh, tmux
_:
{
  # Home-manager: zsh configuration
  flake.homeModules.devpack-zsh =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.my.devpack;
    in
    {
      config = lib.mkIf (cfg.enable && cfg.zsh.enable) {
        home.packages = with pkgs; [
          fzf
          fzf-zsh
          zsh-defer
          ghostty
        ];

        programs = {
          zoxide = {
            enable = true;
            options = [ "--cmd cd" ];
            enableZshIntegration = true;
          };

          command-not-found.enable = false;

          zsh = {
            enable = true;
            completionInit = "";

            plugins = [
              {
                name = "zsh-completions";
                src = pkgs.zsh-completions;
              }
              {
                name = "powerlevel10k";
                src = pkgs.zsh-powerlevel10k;
                file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
              }
            ];
            autosuggestion.enable = true;
            history = {
              save = 1000000;
              size = 1000000;
            };
            syntaxHighlighting = {
              enable = true;
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
              plugins = [
                "git"
                "npm"
                "history"
                "node"
                "rust"
                "deno"
              ];
            };

            initContent = ''
              ZSH_DISABLE_COMPFIX=true

              source "${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh"
              [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
              if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
                source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
              fi
              # ------------------------ self defined functions ----------------------------
              function tat {
                name=$(basename $(pwd) | sed -e 's/\.//g')
                if [ $(pwd) = $HOME ]; then
                  name="default"
                fi

                if ! tmux ls 2>&1 | grep -E "^$name:"; then
                  if [ -f .envrc ]; then
                    direnv exec / tmux new-session -s "$name" -d
                  else
                    tmux new-session -s "$name" -d
                  fi
                fi

                if [ -z "$TMUX" ]; then
                  tmux attach -t "$name" -c "$(pwd)"
                else
                  tmux switch-client -t "$name"
                fi
              }

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

              function add-ssh-key() {
              for key in ~/.ssh/id_ed25519 ~/.ssh/id_sysadm; do
                if [[ -f "$key" ]]; then
                  ssh-add "$key"
                fi
              done
              }

              function aliasIfExist() {
                local alias_name="$1"
                local command_str="$2"
                local command_base="''${2%% *}"

                zsh-defer -c "
                  if command -v ''${command_base} >/dev/null; then
                    alias ''${alias_name}=\"''${command_str}\"
                  fi
                "
              }

              function gen-new-sshkey() {
                ssh_keyname="$1"
                user="''${2:-ansible}"
                ssh-keygen -f "''${HOME}/.ssh/id_''${ssh_keyname}" -C "$user@$ssh-key-name"
              }

              # ---------------------------- alias section ---------------------------
              aliasIfExist cat bat
              aliasIfExist cat batcat
              aliasIfExist godev 'incus exec --project default dev -- sudo -iu '
              aliasIfExist bye 'sudo poweroff'
              aliasIfExist k kubectl
              aliasIfExist reboot 'sudo reboot'
              aliasIfExist 'cdt' 'cd ~/Tmp'
              alias chproj='incus project switch'

              if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
                aliasIfExist 'copy' 'wl-copy'
              else
                aliasIfExist 'copy' 'xclip -sel clip'
              fi

              aliasIfExist vim nvim
              aliasIfExist vi vim
              aliasIfExist podman 'uwsm app -- podman'
              alias kreload='kquitapp5 plasmashell; plasmashell --replace &'
              export PATH=$HOME/.local/bin:$PATH:$HOME/.krew/bin
              alias s=systemctl
              alias chknix='pushd $(nix registry list | grep 'system flake:nixpkgs' | cut -d' ' -f 3 | cut -d':' -f 2) && vim . && popd'
              alias gen_meeting_minute='podman run -it --rm dockersource.cc.cs.nctu.edu.tw/csjhuang/gen_meeting_minute'

              zsh-defer -c "
                source <(fzf --zsh)
                complete -C tofu tofu
              "
            '';
          };
        };

        home.file = {
          ".p10k.zsh" = {
            source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/nix-dotfile/dotfiles/p10k.zsh";
          };
        };

        programs.zsh.history.path = "$HOME/.local/share/zsh/.zsh_history";
      };
    };

  # Home-manager: tmux configuration
  flake.homeModules.devpack-tmux =
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
      config = lib.mkIf (cfg.enable && cfg.tmux.enable) {
        programs.tmux = {
          enable = true;
          keyMode = "vi";
          mouse = true;
          terminal = "screen-256color";
          extraConfig = ''
            # Use Alt-arrow keys to switch panes
            bind -n M-h select-pane -L
            bind -n M-l select-pane -R
            bind -n M-k select-pane -U
            bind -n M-j select-pane -D

            # Shift arrow to switch windows
            bind -n S-Left previous-window
            bind -n S-Right next-window

            # Mouse mode
            setw -g mouse on

            # Set easier window split keys
            bind-key v split-window -h
            bind-key h split-window -v

            # Easy config reload
            bind-key r source-file ~/.config/tmux/tmux.conf \; display-message "~/.config/tmux/tmux.conf reloaded."

            # set my statusbar
            set -g status-position bottom
            set -g status-style bg=black,fg=white

            ## automatic change the current usage program
            set -g automatic-rename on
            set-option -g automatic-rename-format '#(basename "#{pane_current_path}")'
            set -g window-status-current-format '#[bold,fg=red]#(echo ":")#{window_name}#{window_flags}'
            set-option -ga terminal-overrides ",*256col*:Tc"
          '';
          plugins = with pkgs.tmuxPlugins; [
            {
              plugin = sysstat;
              extraConfig = ''
                set -g status-right '#{prefix_highlight} #[fg=white]| #{sysstat_cpu} #{sysstat_mem} #{sysstat_swap} | #{battery_percentage} | %Y-%m-%d %H:%M'
                set -g status-interval 1
                set -g status-left-length 30
                set -g status-right-length 60
                set -g status-left '#[fg=color140] #(echo "session: ")#{session_name} #[default]'
                set -g status-justify centre

                set -g @floax-bind '-n M-p'
                set -g @floax-bind-menu 'P'
              '';
            }
            continuum
            sensible
            yank
            battery
            prefix-highlight
            urlview
            tmux-floax
          ];
          newSession = true;
          prefix = "C-b";
        };
      };
    };
}
