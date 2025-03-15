{
  lib,
  config,
  ...
}: let
  dockerConfig = config.custom.virtualisation.docker;

  cfg = dockerConfig.searxng;
  inherit (dockerConfig) networking;
  inherit (dockerConfig) storage;
in {
  options = {
    custom.virtualisation.docker.searxng = {
      enable = lib.mkEnableOption "Enable SearXNG search engine";

      externalDomain = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."searxng" = {
      file = ./docker-compose.yaml;

      networks = [networking.defaultNetworkName];

      env = {
        BASE_URL = cfg.externalDomain;

        CONFIG_DIR = storage.storageDir + "/searxng/config";
      };
    };
  };
}
