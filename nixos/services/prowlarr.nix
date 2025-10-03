{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.prowlarr;
in {
  options = {
    custom.services.prowlarr = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Prowlarr";

      webUIPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 7878;
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
      custom.services.restic.client.backups.prowlarr = {
        services = ["prowlarr"];

        files = [
          config.services.prowlarr.dataDir
        ];

        excluded = [
          "logs*"
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

        flaresolverr.enable = true;

        prowlarr = {
          enable = true;

          settings = {
            server.port = cfg.webUIPort;
          };
        };
      };
    };
}
