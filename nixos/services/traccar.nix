{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.traccar;
in {
  options = {
    custom.services.traccar = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Traccar service";

      port = mkOption {
        type = types.ints.u16;
        default = 8999;
        description = "The port to run the service on";
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
    dataDir = "/var/lib/traccar";
  in
    mkIf cfg.enable {
      custom.services.restic.client.backups.traccar = {
        files = [
          dataDir
        ];
      };

      systemd.services.traccar.serviceConfig = {
        DynamicUser = lib.mkForce false;
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

        traccar = {
          enable = true;

          settings = {
            web.port = toString cfg.port;

            database = {
              driver = "org.h2.Driver";
              url = "jdbc:h2:${dataDir}/db";
              user = "sa";
              password = "";
            };

            logger.console = "true";

            media.path = "${dataDir}/media";
            templates.root = "${dataDir}/templates";
          };
        };
      };
    };
}
