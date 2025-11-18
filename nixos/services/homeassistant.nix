{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.services.homeassistant;
in {
  options = {
    custom.services.homeassistant = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the HomeAssistant service";

      port = mkOption {
        type = types.ints.u16;
        default = 8123;
        description = "The port to run the service on";
      };

      ntfy.url = mkOption {
        type = types.str;
        description = "The ntfy url to use for notifications";
      };

      caddy.url = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The external domain the service can be reached from";
      };
    };
  };

  config = let
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      custom.services.restic.client.backups.home-assistant = {
        services = ["home-assistant"];

        files = [
          config.services.home-assistant.configDir
        ];

        excluded = [
          "*.log*"
        ];
      };

      services = {
        caddy = mkIf (cfg.caddy.url != null) {
          virtualHosts = {
            "${cfg.caddy.url}" = {
              extraConfig = ''
                reverse_proxy http://localhost:${toString cfg.port}
                
              '';
            };
          };
        };

        postgresql = {
          enable = true;
          ensureDatabases = ["hass"];
          ensureUsers = [
            {
              name = "hass";
              ensureDBOwnership = true;
            }
          ];
        };

        home-assistant = {
          enable = true;

          config = let
            writableMediaDir = "/var/lib/hass/media";
          in {
            homeassistant = {
              name = "Guus' home";

              unit_system = "metric";
            };

            http = {
              server_port = cfg.port;
              use_x_forwarded_for = true;
              trusted_proxies = ["::1"];
            };

            # Configure PostgreSQL as backend for history and logger.
            recorder.db_url = "postgresql://@/hass";

            mobile_app = {};

            evohome = {
              username = "!secret honeywell_username";
              password = "!secret honeywell_password";
            };

            notify = [
              {
                name = "ntfy";
                platform = "ntfy";
                inherit (cfg.ntfy) url;
                topic = "homeassistant";
                verify_ssl = false;
                allow_topic_override = true;
              }
            ];

            allowlist_external_dirs = [writableMediaDir];

            automation = [
              {
                alias = "Send notification on doorbell ring";
                triggers = [
                  {
                    trigger = "state";
                    entity_id = ["event.deurbel_ding"];
                  }
                ];

                actions = let
                  snapshotPath = "${writableMediaDir}/deurbel-snapshot.png";
                in [
                  {
                    action = "camera.snapshot";
                    metadata = {};
                    data = {
                      filename = snapshotPath;
                    };
                    target = {
                      entity_id = "camera.deurbel_live_view";
                    };
                  }
                  {
                    action = "notify.ntfy";
                    data = {
                      title = "The doorbell is ringing!";
                      message = "Check the attachments to see who it was";

                      data = {
                        topic = "deurbel";

                        attach_file = snapshotPath;
                        attachment_filename = "ring.jpg";
                        attachment_compress_image = 80;
                      };
                    };
                  }
                ];
              }
            ];
          };

          customComponents = with pkgs.home-assistant-custom-components; [
            localtuya
            ntfy
          ];

          extraPackages = python3Packages:
            with python3Packages; [
              zlib-ng
              isal
              aiolyric
              gtts
              aiontfy
              psycopg2
            ];

          extraComponents = [
            "default_config"
            "met"
            "esphome"
            "hue"
            "ring"
            "wiz"
            "solaredge"
            "traccar"
            "unifi"
            "evohome"
            "tplink"
            "tplink_tapo"
            "mobile_app"
          ];
        };
      };
    };
}
