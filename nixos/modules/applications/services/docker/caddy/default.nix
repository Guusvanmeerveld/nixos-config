{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.caddy;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;

  createCaddyDir = dir: lib.concatStringsSep "/" [storage.storageDir "caddy" dir];
in {
  options = {
    custom.applications.services.docker.caddy = {
      enable = lib.mkEnableOption "Enable Caddy HTTP proxy";

      caddyFile = lib.mkOption {
        type = lib.types.path;

        default = pkgs.writeText "Caddyfile" '''';
      };

      certsDir = lib.mkOption {
        type = lib.types.str;

        default = createCaddyDir "certs";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."caddy" = {
      file = ./docker-compose.yaml;

      env = {
        CADDY_FILE = toString cfg.caddyFile;

        CERTS_DIR = cfg.certsDir;

        SITE_DIR = createCaddyDir "site";
        DATA_DIR = createCaddyDir "data";
        CONFIG_DIR = createCaddyDir "config";

        EXTERNAL_NETWORK_NAME = networking.externalNetworkName;
      };
    };
  };
}
