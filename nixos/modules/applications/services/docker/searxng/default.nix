{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.searxng;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;
in {
  options = {
    custom.applications.services.docker.searxng = {
      enable = lib.mkEnableOption "Enable SearXNG search engine";

      externalDomain = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."searxng" = {
      file = ./docker-compose.yaml;

      env = {
        BASE_URL = cfg.externalDomain;

        CONFIG_DIR = storage.storageDir + "/searxng/config";

        DEFAULT_NETWORK_NAME = networking.defaultNetworkName;
      };
    };
  };
}
