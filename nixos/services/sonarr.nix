{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.sonarr;
in {
  options = {
    custom.services.sonarr = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Sonarr";

      webUIPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 6767;
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
      custom.services.restic.client.backups.sonarr = {
        services = ["sonarr"];

        files = [
          config.services.sonarr.dataDir
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

        sonarr = {
          enable = true;

          settings = {
            server.port = cfg.webUIPort;
          };
        };
      };
    };
}
