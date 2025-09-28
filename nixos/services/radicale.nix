{
  lib,
  config,
  ...
}: let
  cfg = config.custom.services.radicale;
in {
  options = {
    custom.services.radicale = let
      inherit (lib) mkOption mkEnableOption types;
    in {
      enable = mkEnableOption "Enable Radicale WebDAV/WebCAL server";

      port = mkOption {
        type = types.int;
        default = 5666;
        description = "The port to run the service on";
      };

      htpasswdFile = mkOption {
        type = types.path;
        description = "The path to the htpassword file";
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
      custom.services.restic.client.backups.radicale = {
        files = [
          config.services.radicale.settings.storage.filesystem_folder
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
      };
    };
}
