{
  lib,
  config,
  pkgs,
  ...
}: let
  dockerConfig = config.custom.virtualisation.docker;

  cfg = dockerConfig.uptime-kuma;
  inherit (dockerConfig) networking;
  inherit (dockerConfig) storage;
in {
  options = {
    custom.virtualisation.docker.uptime-kuma = {
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
