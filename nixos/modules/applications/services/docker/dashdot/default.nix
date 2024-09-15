{
  lib,
  config,
  ...
}: let
  dockerConfig = config.custom.applications.services.docker;

  cfg = dockerConfig.dashdot;
  networking = dockerConfig.networking;
in {
  options = {
    custom.applications.services.docker.dashdot = {
      enable = lib.mkEnableOption "Enable dashdot monitoring dashboard";
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."dashdot" = {
      file = ./docker-compose.yaml;

      env = {
        VERSION = "latest";

        DEFAULT_NETWORK_NAME = networking.defaultNetworkName;
      };
    };
  };
}
