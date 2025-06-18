{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.vaultwarden;
in {
  options = {
    custom.services.vaultwarden = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Vaultwarden password store";

      port = mkOption {
        type = types.ints.u16;
        default = 8222;
        description = "The port to run the service on";
      };

      environmentFile = mkOption {
        type = types.path;
        description = "The path to the environment file";
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
                tls internal
              '';
            };
          };
        };

        postgresql = {
          enable = true;
          ensureUsers = [
            {
              name = "vaultwarden";
              ensureDBOwnership = true;
            }
          ];
          ensureDatabases = ["vaultwarden"];
        };

        vaultwarden = {
          enable = true;

          inherit (cfg) environmentFile;

          dbBackend = "postgresql";

          config = {
            DOMAIN = cfg.caddy.url;
            SIGNUPS_ALLOWED = false;

            DATABASE_URL = "postgresql://@/vaultwarden";

            ROCKET_ADDRESS = "127.0.0.1";
            ROCKET_PORT = cfg.port;

            ROCKET_LOG = "critical";

            SMTP_PORT = 587;
            SMTP_SECURITY = "starttls";
            SMTP_SSL = false;

            SMTP_FROM = "bitwarden@guusvanmeerveld.dev";
            SMTP_FROM_NAME = "Guus' Bitwarden server";
          };
        };
      };
    };
}
