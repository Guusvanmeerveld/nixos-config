{
  config,
  lib,
  ...
}: let
  cfg = config.custom.applications.services.miniflux;
in {
  options = {
    custom.applications.services.miniflux = {
      enable = lib.mkEnableOption "Enable the miniflux service";

      port = lib.mkOption {
        type = lib.types.int;
        default = 8082;
        description = "The port to run the service on";
      };

      adminCredentialsFile = lib.mkOption {
        type = lib.types.path;
        description = "The path to the admins credential file";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        description = "The external domain used to connect to this service";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      miniflux = {
        enable = true;

        config = {
          CLEANUP_FREQUENCY = "48";
          LISTEN_ADDR = "localhost:${toString cfg.port}";
          BASE_URL = "https://${cfg.domain}";
        };

        adminCredentialsFile = cfg.adminCredentialsFile;
      };

      nginx = lib.mkIf config.services.nginx.enable {
        virtualHosts = {
          "${cfg.domain}" = lib.mkIf config.services.miniflux.enable {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://localhost:${toString cfg.port}/";
              recommendedProxySettings = true;
            };
          };
        };
      };
    };
  };
}
