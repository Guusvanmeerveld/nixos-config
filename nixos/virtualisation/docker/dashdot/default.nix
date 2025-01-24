{
  lib,
  config,
  ...
}: let
  dockerConfig = config.custom.virtualisation.docker;

  cfg = dockerConfig.dashdot;
  networking = dockerConfig.networking;
in {
  options = {
    custom.virtualisation.docker.dashdot = {
      enable = lib.mkEnableOption "Enable dashdot monitoring dashboard";
    };
  };

  config = lib.mkIf cfg.enable {
    services.docker-compose.projects."dashdot" = {
      file = ./docker-compose.yaml;

      networks = [networking.defaultNetworkName];

      env = {
        VERSION = "latest";
      };
    };
  };
}
