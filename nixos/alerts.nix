{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.alerts;

  ntfyUrl = "${cfg.ntfy.protocol}://${cfg.ntfy.domain}";
in {
  options.custom.alerts = let
    inherit (lib) mkEnableOption mkOption types;
  in {
    ntfy = {
      domain = mkOption {
        type = types.str;
        default = "ntfy.sun";
      };

      protocol = mkOption {
        type = types.enum ["http" "https"];
        default = "https";
      };
    };

    power = {
      enable = mkEnableOption "Enable alerts for when the system powers up/down";
    };

    disk-space = {
      enable = mkEnableOption "Enable alerts for when the system disk is full";
    };
  };

  config = {
    systemd = {
      timers.disk-space-alert = {
        description = "Run disk space check daily";

        wantedBy = ["timers.target"];

        timerConfig = {
          OnCalendar = "*-*-* 18:00:00";
        };
      };

      services = {
        power-alert = lib.mkIf cfg.power.enable {
          description = "Alerts when system powers up/down";

          wantedBy = ["multi-user.target"];

          after = [
            "network-online.target"
          ];

          wants = [
            "network-online.target"
          ];

          serviceConfig = let
            curl = lib.getExe pkgs.curl;
            uptime = lib.getExe' pkgs.procps "uptime";
          in {
            Type = "oneshot";
            RemainAfterExit = true;

            Restart = "on-failure";
            RestartSec = 5;

            ExecCondition = "${lib.getExe pkgs.unixtools.ping} -c 1 -W 5 ${cfg.ntfy.domain}";
            ExecStart = ''${curl} -d "Joepie" -H "Tags: green_circle" -H "Title: ${config.networking.hostName} starting up" ${ntfyUrl}/power'';
            ExecStop = pkgs.writeShellScript "power-alert-down" ''${curl} -d "System uptime: $(${uptime} -p)" -H "Tags: red_circle" -H "Title: ${config.networking.hostName} powering down" ${ntfyUrl}/power'';
          };
        };

        disk-space-alert = lib.mkIf cfg.disk-space.enable {
          description = "Alerts when system disk space is low";

          wantedBy = ["multi-user.target"];

          serviceConfig = {
            Type = "oneshot";

            Restart = "on-failure";
            RestartSec = 5;

            ExecCondition = "${lib.getExe pkgs.unixtools.ping} -c 1 -W 5 ${cfg.ntfy.domain}";
            ExecStart = lib.getExe (pkgs.writeShellApplication {
              name = "disk-space-alert";

              runtimeInputs = with pkgs; [procps curl gawk];

              text = ''
                THRESHOLD=90
                FILESYSTEM="/"

                USAGE=$(df -h "$FILESYSTEM" | awk 'NR==2 {print $5}' | sed 's/%//')

                if [ "$USAGE" -ge "$THRESHOLD" ]; then
                  curl \
                    -d "Disk usage at $USAGE%" \
                    -H "Tags: cd" \
                    -H "Title: Low disk space on ${config.networking.hostName}" \
                    ${ntfyUrl}/disk-space
                fi
              '';
            });
          };
        };
      };
    };
  };
}
