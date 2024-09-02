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

      httpPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 80;
      };

      httpsPort = lib.mkOption {
        type = lib.types.ints.u16;
        default = 443;
      };

      openFirewall = lib.mkEnableOption "Open needed ports in firewall";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [cfg.httpPort cfg.httpsPort];

    services.docker-compose.projects."caddy" = {
      file = ./docker-compose.yaml;

      env = {
        CADDY_FILE = toString cfg.caddyFile;

        CERTS_DIR = cfg.certsDir;

        SITE_DIR = createCaddyDir "site";
        DATA_DIR = createCaddyDir "data";
        CONFIG_DIR = createCaddyDir "config";

        HTTP_PORT = cfg.httpPort;
        HTTPS_PORT = cfg.httpsPort;

        EXTERNAL_NETWORK_NAME = networking.externalNetworkName;
        INTERNAL_NETWORK_NAME = networking.internalNetworkName;
      };
    };
  };
}
