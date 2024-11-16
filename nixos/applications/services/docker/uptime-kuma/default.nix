{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.uptime-kuma;
  networking = dockerConfig.networking;
  storage = dockerConfig.storage;
in {
  options = {
    custom.applications.services.docker.uptime-kuma = {
      enable = lib.mkEnableOption "Enable Uptime Kuma docker service";
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."uptime-kuma" = {
      file = ./docker-compose.yaml;

      networks = [networking.defaultNetworkName];

      env = {
        VERSION = pkgs.uptime-kuma.version;

        DATA_DIR = storage.storageDir + "/uptime-kuma";
      };
    };
  };
}
