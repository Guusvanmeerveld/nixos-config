{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.dawarich;
in {
  options = {
    custom.services.dawarich = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Dawarich, a location tracking service";

      port = mkOption {
        type = types.ints.u16;
        default = 8999;
        description = "The port to run the service on";
      };

      caddy = {
        protocol = mkOption {
          type = with types; enum ["https" "http"];
          default = "https";
          description = "The protocol used to connect to this service externally";
        };

        domain = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "The external domain the service can be reached from";
        };
      };
    };
  };

  config = let
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      custom.services.restic.client.backups.dawarich = {
        files = [
          "/var/lib/dawarich"
        ];
      };

      services = {
        caddy = mkIf (cfg.caddy.domain != null) {
          virtualHosts = {
            "${cfg.caddy.protocol}://${cfg.caddy.domain}" = {
              extraConfig = ''
                reverse_proxy http://localhost:${toString cfg.port}
              '';
            };
          };
        };

        dawarich = {
          enable = true;

          configureNginx = false;

          localDomain = cfg.caddy.domain;

          environment = {
            ALLOW_EMAIL_PASSWORD_REGISTRATION = "true";
          };

          webPort = cfg.port;
        };
      };
    };
}
