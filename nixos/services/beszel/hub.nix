{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.beszel.hub;
in {
  options = {
    custom.services.beszel.hub = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Beszel hub";

      port = lib.mkOption {
        type = lib.types.ints.u16;
        default = 5757;
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

        beszel.hub = {
          enable = true;

          inherit (cfg) port;

          environment = {
            APP_URL = cfg.caddy.url;
          };
        };
      };
    };
}
