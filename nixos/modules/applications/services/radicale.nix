{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.services.radicale;
in {
  options = {
    custom.applications.services.radicale = {
      enable = lib.mkEnableOption "Enable Radicale WebDAV/WebCAL server";

      port = lib.mkOption {
        type = lib.types.int;
        default = 5232;
        description = "The port to run the service on";
      };

      htpasswdFile = lib.mkOption {
        type = lib.types.path;
        description = "The path to the htpassword file";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        description = "The external domain used to connect to this service";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      radicale = {
        enable = true;
        settings = {
          server = {
            hosts = ["0.0.0.0:${toString cfg.port}" "[::]:${toString cfg.port}"];
          };

          auth = {
            type = "htpasswd";
            htpasswd_filename = cfg.htpasswdFile;
            htpasswd_encryption = "bcrypt";
          };

          storage = {
            filesystem_folder = "/var/lib/radicale/collections";
          };
        };
      };

      nginx = lib.mkIf config.services.nginx.enable {
        virtualHosts = {
          "${cfg.domain}" = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://localhost:${toString cfg.port}/";
              extraConfig = ''
                proxy_set_header  X-Script-Name /;
                proxy_pass_header Authorization;
              '';
              recommendedProxySettings = true;
            };
          };
        };
      };
    };
  };
}
