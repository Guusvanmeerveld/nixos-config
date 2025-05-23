{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.virtualisation.docker;

  cfg = dockerConfig.caddy;
  inherit (dockerConfig) networking;
  inherit (dockerConfig) storage;

  createCaddyDir = dir: lib.concatStringsSep "/" [storage.storageDir "caddy" dir];
in {
  options = {
    custom.virtualisation.docker.caddy = {
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

      networks = [networking.defaultNetworkName];

      env = {
        CADDY_FILE = toString cfg.caddyFile;

        CERTS_DIR = cfg.certsDir;

        SITE_DIR = createCaddyDir "site";
        DATA_DIR = createCaddyDir "data";
        CONFIG_DIR = createCaddyDir "config";

        HTTP_PORT = cfg.httpPort;
        HTTPS_PORT = cfg.httpsPort;

        VERSION = pkgs.caddy.version;
      };
    };
  };
}
