{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.atuin;
in {
  options = {
    custom.services.atuin = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Atuin service";

      port = mkOption {
        type = types.ints.u16;
        default = 8888;
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
      custom.services.restic.client.backups.atuin = {
        postgresDBs = [
          {
            dbName = "atuin";
            user = "atuin";
          }
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

        atuin = {
          enable = true;

          inherit (cfg) port;

          openRegistration = true;
        };
      };
    };
}
