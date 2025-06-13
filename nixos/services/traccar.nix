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

        traccar = {
          enable = true;

          settings = {
            webPort = toString cfg.port;

            databaseDriver = "org.h2.Driver";
            databaseUrl = "jdbc:h2:/var/lib/traccar/db";
            databaseUser = "sa";
            databasePassword = "";

            loggerConsole = "true";

            mediaPath = "/var/lib/traccar/media";
            templatesRoot = "/var/lib/traccar/templates";
          };
        };
      };
    };
}
