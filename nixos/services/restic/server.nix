{
  config,
  lib,
  ...
}: let
  cfg = config.custom.services.restic.server;
in {
  options = {
    custom.services.restic.server = let
      inherit (lib) mkEnableOption mkOption types;
    in {
      enable = mkEnableOption "Enable the Restic service";

      port = mkOption {
        type = types.ints.u16;
        default = 8000;
        description = "The port to run the service on";
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/restic";
        description = "The location to store the restic repositories";
      };

      passwordFile = mkOption {
        type = types.path;

        description = "The path to the htpasswd file";
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

        restic.server = {
          enable = true;

          inherit (cfg) dataDir;

          listenAddress = "127.0.0.1:${toString cfg.port}";

          htpasswd-file = cfg.passwordFile;
        };
      };
    };
}
