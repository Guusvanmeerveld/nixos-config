{
  config,
  lib,
  ...
}: let
  cfg = config.custom.applications.services.vaultwarden;
in {
  options = {
    custom.applications.services.vaultwarden = {
      enable = lib.mkEnableOption "Enable Vaultwarden password store";

      port = lib.mkOption {
        type = lib.types.int;
        default = 8222;
        description = "The port to run the service on";
      };

      environmentFile = lib.mkOption {
        type = lib.types.path;
        description = "The path to the environment file";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        description = "The external domain used to connect to this service";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      vaultwarden = {
        enable = true;

        config = {
          DOMAIN = "https://${cfg.domain}";
          SIGNUPS_ALLOWED = false;

          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = cfg.port;

          ROCKET_LOG = "critical";

          SMTP_PORT = 587;
          SMTP_SECURITY = "starttls";
          SMTP_SSL = false;

          SMTP_FROM = "vaultwarden@guusvanmeerveld.dev";
          SMTP_FROM_NAME = "Guus' Vaultwarden server";
        };

        backupDir = "/var/backup/vaultwarden";
        environmentFile = cfg.environmentFile;
      };

      nginx = lib.mkIf config.services.nginx.enable {
        virtualHosts = {
          "${cfg.domain}" = {
            addSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://localhost:${toString cfg.port}/";
              proxyWebsockets = true;
              recommendedProxySettings = true;
            };
          };
        };
      };
    };
  };
}
