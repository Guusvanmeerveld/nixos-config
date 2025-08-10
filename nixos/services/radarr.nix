{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.radarr;
in {
  options = {
    custom.services.radarr = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Radarr";

      webUIPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 5656;
        description = "The port to run the web ui on";
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
      custom.services.restic.client.backups.radarr = {
        services = ["radarr"];

        files = [
          config.services.radarr.dataDir
        ];
      };

      services = {
        caddy = mkIf (cfg.caddy.url != null) {
          virtualHosts = {
            "${cfg.caddy.url}" = {
              extraConfig = ''
                reverse_proxy http://localhost:${toString cfg.webUIPort}
                tls internal
              '';
            };
          };
        };

        radarr = {
          enable = true;

          settings = {
            server.port = cfg.webUIPort;
          };
        };
      };
    };
}
