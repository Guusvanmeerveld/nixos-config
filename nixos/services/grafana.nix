{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.grafana;
in {
  options = {
    custom.services.grafana = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Grafana, a dashboard for statistics";

      port = lib.mkOption {
        type = lib.types.ints.u16;
        default = 8912;
        description = "The port to run the web ui on";
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

        prometheus = {
          enable = true;

          globalConfig.scrape_interval = "1m";

          scrapeConfigs = [
            {
              job_name = "smartctl";

              static_configs = [
                {
                  targets = ["localhost:${toString config.services.prometheus.exporters.smartctl.port}"];
                }
              ];
            }
            {
              job_name = "node";

              scrape_interval = "15s";

              static_configs = [
                {
                  targets = ["localhost:${toString config.services.prometheus.exporters.node.port}"];
                }
              ];
            }
            {
              job_name = "zfs";

              static_configs = [
                {
                  targets = ["localhost:${toString config.services.prometheus.exporters.zfs.port}"];
                }
              ];
            }
          ];

          exporters = {
            node = {
              enable = true;
              enabledCollectors = ["systemd"];
            };

            smartctl.enable = true;
            zfs.enable = true;
          };
        };

        grafana = {
          enable = true;

          provision.datasources.settings = {
            apiVersion = 1;

            datasources = [
              {
                name = "Prometheus";
                type = "prometheus";

                url = "http://localhost:${toString config.services.prometheus.port}";
              }
            ];

            deleteDatasources = [
              {
                name = "Prometheus";
                orgId = 1;
              }
            ];
          };

          settings = {
            server = {
              http_port = cfg.port;
            };

            security = {
              content_security_policy = true;
              cookie_secure = true;
            };
          };
        };
      };
    };
}
