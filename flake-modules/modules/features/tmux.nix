{ ... }:
{
  flake.homeModules.tmux =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.my.tmux;
    in
    {
      options.my.tmux = {
        enable = lib.mkEnableOption "tmux terminal multiplexer";
      };

      config = lib.mkIf cfg.enable {
        programs = {
          tmux = {
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
    };
}
