{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.jellyseerr;
in {
  options = {
    custom.services.jellyseerr = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Jellyseerr service";

      port = mkOption {
        type = types.ints.u16;
        default = 8097;
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
      custom.services.restic.client.backups.jellyseerr = {
        services = ["jellyseerr"];

        files = [
          "${config.services.jellyseerr.configDir}/settings.json"
          "${config.services.jellyseerr.configDir}/db"
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

        jellyseerr = {
          enable = true;

          inherit (cfg) port;
        };
      };
    };
}
