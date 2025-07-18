{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.bazarr;
in {
  options = {
    custom.services.bazarr = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable Bazarr";

      webUIPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 9494;
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
                reverse_proxy http://localhost:${toString cfg.webUIPort}
                tls internal
              '';
            };
          };
        };

        bazarr = {
          enable = true;

          listenPort = cfg.webUIPort;
        };
      };
    };
}
