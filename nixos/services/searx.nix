{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.searx;
in {
  options = {
    custom.services.searx = {
      enable = lib.mkEnableOption "Enable Searxng search engine";

      port = lib.mkOption {
        type = lib.types.int;
        description = "The port to run the service on";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        description = "The external domain the service can be reached from";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      nginx = lib.mkIf config.services.nginx.enable {
        virtualHosts = {
          "${cfg.domain}" = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://localhost:${toString cfg.port}/";
              recommendedProxySettings = true;
            };
          };
        };
      };

      searx = {
        enable = true;

        settings = {
          use_default_settings = true;

          server = {
            port = cfg.port;
            bind_address = "0.0.0.0";
            secret_key = "@SEARX_SECRET_KEY@";
          };

          ui = {
            infinite_scroll = true;
            center_alignment = true;
            query_in_title = true;
          };

          general = {
            instance_name = "SearX Search Engine";
          };
        };

        environmentFile = "/var/lib/searx.env";
      };
    };
  };
}
