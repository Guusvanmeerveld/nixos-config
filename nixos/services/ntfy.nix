{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.ntfy;
in {
  options = {
    custom.services.ntfy = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Ntfy service";

      port = mkOption {
        type = types.ints.u16;
        default = 3333;
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

        ntfy-sh = {
          enable = true;

          settings = {
            listen-http = ":${toString cfg.port}";
            base-url = cfg.caddy.url;
            behind-proxy = true;
            enable-signup = true;
            enable-login = true;
          };
        };
      };
    };
}
