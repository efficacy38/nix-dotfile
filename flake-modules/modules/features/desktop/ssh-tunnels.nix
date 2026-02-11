# SSH tunnel service for persistent port forwarding
_: {
  flake.homeModules.desktop-ssh-tunnels =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.desktop.ssh-tunnels;

      wrapperScript = pkgs.writeShellScript "ssh-tunnel-wrapper" ''
        set -euo pipefail

        INSTANCE="$1"
        CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/ssh-tunnels"
        CONFIG_FILE="''${CONFIG_DIR}/''${INSTANCE}.yaml"

        if [[ ! -f "$CONFIG_FILE" ]]; then
          echo "Error: Config file not found: $CONFIG_FILE" >&2
          exit 1
        fi

        HOST=$(${pkgs.yq}/bin/yq -r '.host' "$CONFIG_FILE")

        if [[ -z "$HOST" || "$HOST" == "null" ]]; then
          echo "Error: Missing or invalid 'host' in $CONFIG_FILE" >&2
          exit 1
        fi

        mapfile -t PORT_FORWARDS < <(
          ${pkgs.yq}/bin/yq -r '.tunnels | to_entries[] | select(.value.enabled == true) | "-L \(.value.local_port):localhost:\(.value.remote_port)"' "$CONFIG_FILE"
        )

        if [[ ''${#PORT_FORWARDS[@]} -eq 0 ]]; then
          echo "Error: No enabled tunnels in $CONFIG_FILE" >&2
          exit 1
        fi

        get_free_port() {
          while :; do
            port=$((RANDOM % 10000 + 30000))
            if ! ${pkgs.iproute2}/bin/ss -tuln 2>/dev/null | grep -qE ":($port|$((port+1))) "; then
              echo "$port"
              return 0
            fi
          done
        }

        MONITOR_PORT=$(get_free_port)

        exec ${pkgs.autossh}/bin/autossh -M "$MONITOR_PORT" -N \
          -o "ServerAliveInterval=30" \
          -o "ServerAliveCountMax=3" \
          -o "ExitOnForwardFailure=yes" \
          ''${PORT_FORWARDS[@]} \
          "$HOST"
      '';
    in
    {
      options.my.desktop.ssh-tunnels = {
        enable = lib.mkEnableOption "SSH tunnel service";
      };

      config = lib.mkIf cfg.enable {
        xdg.configFile."ssh-tunnels/.keep".text = "";

        systemd.user.services."ssh-tunnel@" = {
          Unit = {
            Description = "SSH Tunnel to %i";
            After = [ "network-online.target" ];
            Wants = [ "network-online.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${wrapperScript} %i";
            Restart = "on-failure";
            RestartSec = "10";
          };
        };
      };
    };
}
