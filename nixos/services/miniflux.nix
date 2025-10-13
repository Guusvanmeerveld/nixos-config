{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.miniflux;
in {
  options = {
    custom.services.miniflux = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Miniflux service";

      port = mkOption {
        type = types.ints.u16;
        default = 8082;
        description = "The port to run the service on";
      };

      adminCredentialsFile = mkOption {
        type = types.path;
        description = ''
          The path to the admins credential file
          File containing the ADMIN_USERNAME and ADMIN_PASSWORD (length >= 6) in the format of an EnvironmentFile=
        '';
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
      custom.services.restic.client.backups.miniflux = {
        postgresDBs = [
          {
            dbName = "miniflux";
            user = "miniflux";
          }
        ];
      };

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

        miniflux = {
          enable = true;

          config = {
            CLEANUP_FREQUENCY = "48";
            LISTEN_ADDR = "localhost:${toString cfg.port}";
            BASE_URL = cfg.caddy.url;
          };

          inherit (cfg) adminCredentialsFile;
        };
      };
    };
}
