{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.mealie;
in {
  options = {
    custom.services.mealie = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Mealie service";

      port = mkOption {
        type = types.ints.u16;
        default = 8095;
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
      custom.services.restic.client.backups.mealie = {
        postgresDBs = [
          {
            dbName = "mealie";
            user = "mealie";
          }
        ];

        services = ["mealie"];

        files = [
          "/var/lib/mealie"
        ];
      };

      users.users.mealie = {
        group = "mealie";
        isSystemUser = true;
      };

      users.groups.mealie = {};

      systemd.services.mealie.serviceConfig = {
        DynamicUser = lib.mkForce false;
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

        mealie = {
          enable = true;

          inherit (cfg) port;

          settings = {
            ALLOW_SIGNUP = true;
          };

          database.createLocally = true;
        };
      };
    };
}
