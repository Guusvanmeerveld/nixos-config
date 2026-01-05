{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.services.ntfy-client;
in {
  options = {
    custom.services.ntfy-client = {
      enable = lib.mkEnableOption "Enable ntfy-client, a service that automatically subscribes to ntfy topics";

      servers = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule (_: {
          options = {
            url = lib.mkOption {
              type = lib.types.str;
              description = "The url to the ntfy server";
            };

            topics = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "List of topics to subscribe to";
            };
          };
        }));

        default = [];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services."ntfy-client" = {
      Unit = {
        Description = "Ntfy-client, auto subscribes to topics";
        Documentation = "https://ntfy.sh/";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };

      Service = {
        Restart = "on-failure";

        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "ntfy-client";

          runtimeInputs = with pkgs; [ntfy-sh libnotify];

          text = let
            notifyScript = pkgs.writeShellScript "ntfy-send-desktop-notification" ''
              notify-send --app-name="$topic" "$title" "$message"
            '';
          in ''
            ${lib.concatStringsSep "\n" (map (
                server:
                  lib.concatStringsSep "\n" (map (topic: ''
                      # shellcheck disable=SC2016
                      ntfy sub ${server.url}/${topic} ${notifyScript} &
                    '')
                    server.topics)
              )
              cfg.servers)}
            wait
          '';
        });
      };

      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
