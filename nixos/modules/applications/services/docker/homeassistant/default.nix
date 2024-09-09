{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.homeassistant;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;
in {
  options = {
    custom.applications.services.docker.homeassistant = {
      enable = lib.mkEnableOption "Enable homeassistant home management service";
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."homeassistant" = {
      file = ./docker-compose.yaml;

      env = {
        CONFIG_DIR = storage.storageDir + "/homeassistant/data";

        HOSTNAME = config.networking.hostName;

        VERSION = pkgs.home-assistant.version;

        INTERNAL_NETWORK_NAME = networking.internalNetworkName;
      };
    };
  };
}
